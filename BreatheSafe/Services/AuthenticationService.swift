import Foundation
import Security

/// Protocol for handling authentication events
protocol AuthenticationServiceDelegate: AnyObject {
    func authenticationService(_ service: AuthenticationService, didLogin user: User)
    func authenticationService(_ service: AuthenticationService, didLogout user: User?)
    func authenticationService(_ service: AuthenticationService, didEncounterError error: AuthenticationError)
    func authenticationService(_ service: AuthenticationService, didLoadManagedUsers users: [ManagedUser])
}

/// Service responsible for handling authentication with the Rails backend
class AuthenticationService {
    weak var delegate: AuthenticationServiceDelegate?
    
    /// Base URL for the Rails backend
    private let baseURL = "https://breathesafe.xyz"
    
    /// Current authenticated user
    private(set) var currentUser: User?
    
    /// Current session token (if using token-based auth)
    private(set) var sessionToken: String?
    
    /// URLSession for network requests
    private let urlSession: URLSession
    
    init() {
        // Configure URLSession with appropriate timeout and caching
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.urlSession = URLSession(configuration: config)
        
        // Try to restore session from keychain
        restoreSession()
    }
    
    // MARK: - Authentication Methods
    
    /// Login with email and password
    func login(email: String, password: String, completion: @escaping (Result<User, AuthenticationError>) -> Void) {
        let loginRequest = LoginRequest(user: LoginRequest.LoginCredentials(email: email, password: password))
        
        guard let url = URL(string: "\(baseURL)/users/log_in"),
              let jsonData = try? JSONEncoder().encode(loginRequest) else {
            completion(.failure(.invalidRequest))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        urlSession.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.networkError(error)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.invalidResponse))
                    return
                }
                
                // Handle different response codes
                switch httpResponse.statusCode {
                case 200, 201:
                    // Success - get current user
                    self?.getCurrentUser { result in
                        switch result {
                        case .success(let user):
                            self?.currentUser = user
                            self?.saveCredentials(email: email, password: password)
                            self?.delegate?.authenticationService(self!, didLogin: user)
                            completion(.success(user))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                case 401:
                    completion(.failure(.invalidCredentials))
                case 422:
                    completion(.failure(.validationError))
                default:
                    completion(.failure(.serverError(httpResponse.statusCode)))
                }
            }
        }.resume()
    }
    
    /// Logout current user
    func logout(completion: @escaping (Result<Void, AuthenticationError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/log_out") else {
            completion(.failure(.invalidRequest))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        // Add session cookie if available
        if let sessionToken = sessionToken {
            request.setValue("Bearer \(sessionToken)", forHTTPHeaderField: "Authorization")
        }
        
        urlSession.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.networkError(error)))
                    return
                }
                
                let user = self?.currentUser
                self?.currentUser = nil
                self?.sessionToken = nil
                self?.clearCredentials()
                
                self?.delegate?.authenticationService(self!, didLogout: user)
                completion(.success(()))
            }
        }.resume()
    }
    
    /// Get current user information
    func getCurrentUser(completion: @escaping (Result<User, AuthenticationError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/get_current_user") else {
            completion(.failure(.invalidRequest))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Add session cookie if available
        if let sessionToken = sessionToken {
            request.setValue("Bearer \(sessionToken)", forHTTPHeaderField: "Authorization")
        }
        
        urlSession.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.networkError(error)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.invalidResponse))
                    return
                }
                
                switch httpResponse.statusCode {
                case 200:
                    guard let data = data else {
                        completion(.failure(.invalidResponse))
                        return
                    }
                    
                    do {
                        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                        if let user = authResponse.currentUser {
                            self?.currentUser = user
                            completion(.success(user))
                        } else {
                            completion(.failure(.notAuthenticated))
                        }
                    } catch {
                        completion(.failure(.decodingError(error)))
                    }
                case 401:
                    completion(.failure(.notAuthenticated))
                default:
                    completion(.failure(.serverError(httpResponse.statusCode)))
                }
            }
        }.resume()
    }
    
    /// Load managed users for the current user
    func loadManagedUsers(completion: @escaping (Result<[ManagedUser], AuthenticationError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/managed_users") else {
            completion(.failure(.invalidRequest))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Add session cookie if available
        if let sessionToken = sessionToken {
            request.setValue("Bearer \(sessionToken)", forHTTPHeaderField: "Authorization")
        }
        
        urlSession.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.networkError(error)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.invalidResponse))
                    return
                }
                
                switch httpResponse.statusCode {
                case 200:
                    guard let data = data else {
                        completion(.failure(.invalidResponse))
                        return
                    }
                    
                    do {
                        let managedUsersResponse = try JSONDecoder().decode(ManagedUsersResponse.self, from: data)
                        self?.delegate?.authenticationService(self!, didLoadManagedUsers: managedUsersResponse.managedUsers)
                        completion(.success(managedUsersResponse.managedUsers))
                    } catch {
                        completion(.failure(.decodingError(error)))
                    }
                case 401:
                    completion(.failure(.notAuthenticated))
                case 422:
                    completion(.failure(.validationError))
                default:
                    completion(.failure(.serverError(httpResponse.statusCode)))
                }
            }
        }.resume()
    }
    
    /// Check if user is currently authenticated
    var isAuthenticated: Bool {
        return currentUser != nil
    }
    
    // MARK: - Credential Management
    
    /// Save credentials securely to Keychain
    private func saveCredentials(email: String, password: String) {
        let emailData = email.data(using: .utf8)!
        let passwordData = password.data(using: .utf8)!
        
        // Save email
        let emailQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "breathesafe_email",
            kSecValueData as String: emailData
        ]
        
        // Delete existing email
        SecItemDelete(emailQuery as CFDictionary)
        
        // Add new email
        SecItemAdd(emailQuery as CFDictionary, nil)
        
        // Save password
        let passwordQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "breathesafe_password",
            kSecValueData as String: passwordData
        ]
        
        // Delete existing password
        SecItemDelete(passwordQuery as CFDictionary)
        
        // Add new password
        SecItemAdd(passwordQuery as CFDictionary, nil)
    }
    
    /// Restore session from saved credentials
    private func restoreSession() {
        // Try to get saved credentials
        guard let email = getSavedEmail(),
              let password = getSavedPassword() else {
            return
        }
        
        // Attempt to login with saved credentials
        login(email: email, password: password) { [weak self] result in
            switch result {
            case .success(let user):
                print("Successfully restored session for user: \(user.email)")
            case .failure(let error):
                print("Failed to restore session: \(error)")
                // Clear invalid credentials
                self?.clearCredentials()
            }
        }
    }
    
    /// Get saved email from Keychain
    private func getSavedEmail() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "breathesafe_email",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let email = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return email
    }
    
    /// Get saved password from Keychain
    private func getSavedPassword() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "breathesafe_password",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let password = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return password
    }
    
    /// Clear saved credentials from Keychain
    private func clearCredentials() {
        let emailQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "breathesafe_email"
        ]
        
        let passwordQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "breathesafe_password"
        ]
        
        SecItemDelete(emailQuery as CFDictionary)
        SecItemDelete(passwordQuery as CFDictionary)
    }
}

/// Authentication errors
enum AuthenticationError: Error, LocalizedError {
    case invalidCredentials
    case notAuthenticated
    case invalidRequest
    case invalidResponse
    case networkError(Error)
    case serverError(Int)
    case validationError
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .notAuthenticated:
            return "User is not authenticated"
        case .invalidRequest:
            return "Invalid request"
        case .invalidResponse:
            return "Invalid response from server"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let code):
            return "Server error: \(code)"
        case .validationError:
            return "Validation error"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}