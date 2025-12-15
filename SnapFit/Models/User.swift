import Foundation

/// Represents a user in the BreatheSafe system
struct User: Codable {
    let id: Int
    let email: String
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// Represents a managed user (someone managed by the current user)
struct ManagedUser: Codable {
    let id: Int?
    let managerId: Int?
    let managedId: Int?
    let user: User?
    let profile: UserProfile?
    
    // Additional fields that might be present in the complex response
    let managerEmail: String?
    let firstName: String?
    let lastName: String?
    let email: String?
    let fmPercentComplete: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case managerId = "manager_id"
        case managedId = "managed_id"
        case user
        case profile
        case managerEmail = "manager_email"
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case fmPercentComplete = "fm_percent_complete"
    }
    
    /// Get display name for the managed user
    var displayName: String {
        if let firstName = firstName, let lastName = lastName {
            return "\(firstName) \(lastName)"
        } else if let email = email {
            return email
        } else if let user = user {
            return user.email
        } else {
            return "User \(managedId ?? 0)"
        }
    }
}

/// Represents a user profile
struct UserProfile: Codable {
    let id: Int
    let userId: Int
    let firstName: String
    let lastName: String
    let measurementSystem: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case measurementSystem = "measurement_system"
    }
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
}

/// Authentication response from the server
struct AuthResponse: Codable {
    let currentUser: User?
    let messages: [String]?
    let updateSignedIn: Bool?
    
    enum CodingKeys: String, CodingKey {
        case currentUser = "currentUser"
        case messages
        case updateSignedIn = "updateSignedIn"
    }
}

/// Login request payload
struct LoginRequest: Codable {
    let user: LoginCredentials
    
    struct LoginCredentials: Codable {
        let email: String
        let password: String
    }
}

/// Managed users response
struct ManagedUsersResponse: Codable {
    let managedUsers: [ManagedUser]
    let messages: [String]
    
    enum CodingKeys: String, CodingKey {
        case managedUsers = "managed_users"
        case messages
    }
}