import UIKit

/// View controller for user authentication
class LoginViewController: UIViewController {
    
    // MARK: - UI Elements
    private var emailTextField: UITextField!
    private var passwordTextField: UITextField!
    private var loginButton: UIButton!
    private var activityIndicator: UIActivityIndicatorView!
    private var errorLabel: UILabel!
    private var managedUsersButton: UIButton!
    
    // MARK: - Properties
    private let authService = AuthenticationService()
    private let apiClient: APIClient
    private let offlineSyncManager: OfflineSyncManager
    
    private var managedUsers: [ManagedUser] = []
    
    init() {
        self.apiClient = APIClient(authService: authService)
        self.offlineSyncManager = OfflineSyncManager(apiClient: apiClient, authService: authService)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDelegates()
        
        // Check if user is already authenticated
        if authService.isAuthenticated {
            loadManagedUsers()
        }
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        title = "BreatheSafe Login"
        view.backgroundColor = UIColor.systemBackground
        
        // Create email text field
        emailTextField = UITextField()
        emailTextField.placeholder = "Email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emailTextField)
        
        // Create password text field
        passwordTextField = UITextField()
        passwordTextField.placeholder = "Password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(passwordTextField)
        
        // Create login button
        loginButton = UIButton(type: .system)
        loginButton.setTitle("Login", for: .normal)
        loginButton.backgroundColor = UIColor.systemBlue
        loginButton.setTitleColor(UIColor.white, for: .normal)
        loginButton.layer.cornerRadius = 8
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.addTarget(self, action: #selector(loginButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(loginButton)
        
        // Create activity indicator
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        // Create error label
        errorLabel = UILabel()
        errorLabel.textColor = UIColor.systemRed
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .center
        errorLabel.font = UIFont.systemFont(ofSize: 14)
        errorLabel.isHidden = true
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorLabel)
        
        // Create managed users button
        managedUsersButton = UIButton(type: .system)
        managedUsersButton.setTitle("Select User for Measurement", for: .normal)
        managedUsersButton.backgroundColor = UIColor.systemGreen
        managedUsersButton.setTitleColor(UIColor.white, for: .normal)
        managedUsersButton.layer.cornerRadius = 8
        managedUsersButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        managedUsersButton.isHidden = true
        managedUsersButton.translatesAutoresizingMaskIntoConstraints = false
        managedUsersButton.addTarget(self, action: #selector(managedUsersButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(managedUsersButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Email text field
            emailTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Password text field
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Login button
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 24),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Activity indicator
            activityIndicator.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor),
            
            // Error label
            errorLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 16),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Managed users button
            managedUsersButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 24),
            managedUsersButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            managedUsersButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            managedUsersButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupDelegates() {
        authService.delegate = self
        apiClient.delegate = self
        offlineSyncManager.delegate = self
    }
    
    // MARK: - Actions
    @objc private func loginButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showError("Please enter both email and password")
            return
        }

        login(email: email, password: password)
    }

    @objc private func managedUsersButtonTapped(_ sender: UIButton) {
        showManagedUsersSelection()
    }

    // MARK: - Authentication Methods
    private func login(email: String, password: String) {
        setLoading(true)
        hideError()

        // Add some debugging
        print("Attempting login with email: \(email)")
        print("Using endpoint: https://www.breathesafe.xyz/users/log_in")

        authService.login(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.setLoading(false)

                switch result {
                case .success(let user):
                    print("Successfully logged in as: \(user.email)")
                    self?.loadManagedUsers()
                case .failure(let error):
                    print("Login failed with error: \(error)")
                    self?.showError("Login failed: \(error.localizedDescription)")
                }
            }
        }
    }

    private func loadManagedUsers() {
        authService.loadManagedUsers { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    print("Successfully loaded \(users.count) managed users")
                    self?.managedUsers = users
                    self?.updateManagedUsersButton()
                case .failure(let error):
                    print("Failed to load managed users: \(error)")
                }
            }
        }
    }

    private func updateManagedUsersButton() {
        if !managedUsers.isEmpty {
            managedUsersButton.isHidden = false
            managedUsersButton.setTitle("Select User for Measurement (\(managedUsers.count) users)", for: .normal)
        } else {
            managedUsersButton.isHidden = true
        }
    }

    private func showManagedUsersSelection() {
        let alert = UIAlertController(title: "Select User", message: "Choose a user to capture measurements for:", preferredStyle: .actionSheet)

        for user in managedUsers {
            alert.addAction(UIAlertAction(title: user.displayName, style: .default) { [weak self] _ in
                self?.navigateToFaceMeasurement(for: user)
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // For iPad
        if let popover = alert.popoverPresentationController {
            popover.sourceView = managedUsersButton
            popover.sourceRect = managedUsersButton.bounds
        }

        present(alert, animated: true)
    }

    private func navigateToFaceMeasurement(for user: ManagedUser) {
        let faceMeasurementVC = FaceMeasurementViewController()
        faceMeasurementVC.selectedUser = user
        faceMeasurementVC.authService = authService
        faceMeasurementVC.apiClient = apiClient
        faceMeasurementVC.offlineSyncManager = offlineSyncManager

        let navigationController = UINavigationController(rootViewController: faceMeasurementVC)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }

    // MARK: - UI Helper Methods
    private func setLoading(_ loading: Bool) {
        if loading {
            activityIndicator.startAnimating()
            loginButton.setTitle("", for: .normal)
            loginButton.isEnabled = false
        } else {
            activityIndicator.stopAnimating()
            loginButton.setTitle("Login", for: .normal)
            loginButton.isEnabled = true
        }
    }

    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }

    private func hideError() {
        errorLabel.isHidden = true
    }
}

// MARK: - AuthenticationServiceDelegate
extension LoginViewController: AuthenticationServiceDelegate {
    func authenticationService(_ service: AuthenticationService, didLogin user: User) {
        // Handle successful login
        print("User logged in: \(user.email)")
    }

    func authenticationService(_ service: AuthenticationService, didLogout user: User?) {
        // Handle logout
        managedUsers = []
        updateManagedUsersButton()
        print("User logged out")
    }

    func authenticationService(_ service: AuthenticationService, didEncounterError error: AuthenticationError) {
        showError(error.localizedDescription)
    }

    func authenticationService(_ service: AuthenticationService, didLoadManagedUsers users: [ManagedUser]) {
        managedUsers = users
        updateManagedUsersButton()
    }
}

// MARK: - APIClientDelegate
extension LoginViewController: APIClientDelegate {
    func apiClient(_ client: APIClient, didExportMeasurementsFor user: ManagedUser) {
        // Handle successful export
        print("Successfully exported measurements for user: \(user.managedId)")
    }

    func apiClient(_ client: APIClient, didEncounterError error: APIError) {
        showError(error.localizedDescription)
    }
}

// MARK: - OfflineSyncManagerDelegate
extension LoginViewController: OfflineSyncManagerDelegate {
    func offlineSyncManager(_ manager: OfflineSyncManager, didSyncPendingMeasurements count: Int) {
        if count > 0 {
            print("Synced \(count) pending measurements")
        }
    }
    
    func offlineSyncManager(_ manager: OfflineSyncManager, didEncounterError error: OfflineSyncError) {
        print("Offline sync error: \(error.localizedDescription)")
    }
}