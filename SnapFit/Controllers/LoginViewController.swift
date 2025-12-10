import UIKit

/// View controller for user authentication
class LoginViewController: UIViewController {

    // MARK: - UI Elements
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var firstParagraphTextView: UITextView!
    private var recommendMasksButton: UIButton!
    private var contributeDataButton: UIButton!
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
    private var isShowingLoginForm = false
    private var contributeButtonBottomConstraint: NSLayoutConstraint!

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
            showLoginForm()
            loadManagedUsers()
        }
    }

    // MARK: - Setup Methods
    private func setupUI() {
        title = "SnapFit"
        view.backgroundColor = UIColor.systemBackground

        // Create scroll view
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        // Create content view
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        // Create first paragraph text view (supports clickable links)
        firstParagraphTextView = UITextView()
        firstParagraphTextView.isEditable = false
        firstParagraphTextView.isScrollEnabled = false
        firstParagraphTextView.backgroundColor = .clear
        firstParagraphTextView.textContainerInset = .zero
        firstParagraphTextView.textContainer.lineFragmentPadding = 0
        firstParagraphTextView.font = UIFont.systemFont(ofSize: 17)
        firstParagraphTextView.textColor = UIColor.label
        firstParagraphTextView.text = "Welcome to SnapFit! Find masks that would most likely fit your face — in a snap. Developed by Breathesafe LLC."
        firstParagraphTextView.linkTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        firstParagraphTextView.delegate = self
        firstParagraphTextView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(firstParagraphTextView)

        // Create Recommend Me Masks button
        recommendMasksButton = UIButton(type: .system)
        recommendMasksButton.setTitle("Recommend Me Masks", for: .normal)
        recommendMasksButton.backgroundColor = UIColor.systemGreen
        recommendMasksButton.setTitleColor(UIColor.white, for: .normal)
        recommendMasksButton.layer.cornerRadius = 8
        recommendMasksButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        recommendMasksButton.translatesAutoresizingMaskIntoConstraints = false
        recommendMasksButton.addTarget(self, action: #selector(recommendMasksButtonTapped), for: .touchUpInside)
        contentView.addSubview(recommendMasksButton)

        // Create Contribute Data button
        contributeDataButton = UIButton(type: .system)
        contributeDataButton.setTitle("Contribute Facial Measurement Data", for: .normal)
        contributeDataButton.backgroundColor = UIColor.systemBlue
        contributeDataButton.setTitleColor(UIColor.white, for: .normal)
        contributeDataButton.layer.cornerRadius = 8
        contributeDataButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        contributeDataButton.translatesAutoresizingMaskIntoConstraints = false
        contributeDataButton.addTarget(self, action: #selector(contributeDataButtonTapped), for: .touchUpInside)
        contentView.addSubview(contributeDataButton)

        // Create email text field
        emailTextField = UITextField()
        emailTextField.placeholder = "Email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emailTextField)

        // Create password text field
        passwordTextField = UITextField()
        passwordTextField.placeholder = "Password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(passwordTextField)

        // Create login button
        loginButton = UIButton(type: .system)
        loginButton.setTitle("Login", for: .normal)
        loginButton.backgroundColor = UIColor.systemBlue
        loginButton.setTitleColor(UIColor.white, for: .normal)
        loginButton.layer.cornerRadius = 8
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.addTarget(self, action: #selector(loginButtonTapped(_:)), for: .touchUpInside)
        contentView.addSubview(loginButton)

        // Create activity indicator
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(activityIndicator)

        // Create error label
        errorLabel = UILabel()
        errorLabel.textColor = UIColor.systemRed
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .center
        errorLabel.font = UIFont.systemFont(ofSize: 14)
        errorLabel.isHidden = true
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(errorLabel)

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
        contentView.addSubview(managedUsersButton)

        // Hide login form initially
        emailTextField.isHidden = true
        passwordTextField.isHidden = true
        loginButton.isHidden = true

        setupConstraints()
    }

    private func setupConstraints() {
        // Create the bottom constraint for contribute button (used when main menu is shown)
        contributeButtonBottomConstraint = contributeDataButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        
        NSLayoutConstraint.activate([
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Content view constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // First paragraph text view
            firstParagraphTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            firstParagraphTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            firstParagraphTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Recommend Masks button
            recommendMasksButton.topAnchor.constraint(equalTo: firstParagraphTextView.bottomAnchor, constant: 40),
            recommendMasksButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            recommendMasksButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            recommendMasksButton.heightAnchor.constraint(equalToConstant: 50),

            // Contribute Data button
            contributeDataButton.topAnchor.constraint(equalTo: recommendMasksButton.bottomAnchor, constant: 16),
            contributeDataButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contributeDataButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            contributeDataButton.heightAnchor.constraint(equalToConstant: 50),
            contributeButtonBottomConstraint,

            // Email text field (positioned after first paragraph when login form is shown)
            emailTextField.topAnchor.constraint(equalTo: firstParagraphTextView.bottomAnchor, constant: 30),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),

            // Password text field
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),

            // Login button
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 24),
            loginButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            loginButton.heightAnchor.constraint(equalToConstant: 50),

            // Activity indicator
            activityIndicator.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor),

            // Error label
            errorLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 16),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Managed users button
            managedUsersButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 24),
            managedUsersButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            managedUsersButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            managedUsersButton.heightAnchor.constraint(equalToConstant: 50),
            managedUsersButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    private func setupDelegates() {
        authService.delegate = self
        apiClient.delegate = self
        offlineSyncManager.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // Add tap gesture to dismiss keyboard when tapping outside text fields
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Actions
    @objc private func recommendMasksButtonTapped() {
        let alert = UIAlertController(
            title: "Coming Soon",
            message: "This functionality will be added in the near future. Stay tuned! Questions? Please email info@breathesafe.xyz.",
            preferredStyle: .alert
        )
        
        // Add email action
        alert.addAction(UIAlertAction(title: "Email Us", style: .default) { _ in
            if let url = URL(string: "mailto:info@breathesafe.xyz") {
                UIApplication.shared.open(url)
            }
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func contributeDataButtonTapped() {
        showLoginForm()
    }

    @objc private func loginButtonTapped(_ sender: UIButton) {
        // Dismiss keyboard when login button is tapped
        view.endEditing(true)
        
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

    private func showLoginForm() {
        isShowingLoginForm = true
        
        // Update welcome text with clickable links
        let loginText = "Fit testers: please contribute your data to improve this mask recommender. For more information, see the consent form at https://breathesafe.xyz/#/consent_form. If you have not registered, please register here: https://www.breathesafe.xyz/#/signin"
        let attributedString = NSMutableAttributedString(string: loginText)
        
        // Make consent form URL clickable
        let consentFormUrlRange = (loginText as NSString).range(of: "https://breathesafe.xyz/#/consent_form")
        if consentFormUrlRange.location != NSNotFound {
            attributedString.addAttribute(.link, value: "https://breathesafe.xyz/#/consent_form", range: consentFormUrlRange)
        }
        
        // Make registration URL clickable
        let registrationUrlRange = (loginText as NSString).range(of: "https://www.breathesafe.xyz/#/signin")
        if registrationUrlRange.location != NSNotFound {
            attributedString.addAttribute(.link, value: "https://www.breathesafe.xyz/#/signin", range: registrationUrlRange)
        }
        
        firstParagraphTextView.attributedText = attributedString
        
        // Deactivate contribute button bottom constraint
        contributeButtonBottomConstraint.isActive = false
        
        // Hide main menu buttons
        recommendMasksButton.isHidden = true
        contributeDataButton.isHidden = true
        
        // Show login form
        emailTextField.isHidden = false
        passwordTextField.isHidden = false
        loginButton.isHidden = false
        
        // Add back button to navigation bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: self,
            action: #selector(backToMainMenuTapped)
        )
        
        // Animate the transition
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func backToMainMenuTapped() {
        showMainMenu()
    }

    private func showMainMenu() {
        isShowingLoginForm = false
        
        // Restore welcome text
        firstParagraphTextView.text = "Welcome to SnapFit! Find masks that would most likely fit your face — in a snap. Developed by Breathesafe LLC."
        
        // Activate contribute button bottom constraint
        contributeButtonBottomConstraint.isActive = true
        
        // Show main menu buttons
        recommendMasksButton.isHidden = false
        contributeDataButton.isHidden = false
        
        // Hide login form
        emailTextField.isHidden = true
        passwordTextField.isHidden = true
        loginButton.isHidden = true
        errorLabel.isHidden = true
        managedUsersButton.isHidden = true
        
        // Remove back button from navigation bar
        navigationItem.leftBarButtonItem = nil
        
        // Clear fields
        emailTextField.text = ""
        passwordTextField.text = ""
        
        // Dismiss keyboard
        view.endEditing(true)
        
        // Animate the transition
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
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

// MARK: - UITextViewDelegate
extension LoginViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            // Move to password field when return is pressed on email field
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            // Dismiss keyboard and attempt login when return is pressed on password field
            textField.resignFirstResponder()
            loginButtonTapped(loginButton)
        }
        return true
    }
}
