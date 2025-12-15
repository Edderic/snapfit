import UIKit
import SafariServices

/// View controller for user authentication
class LoginViewController: UIViewController {

    // MARK: - UI Elements
    private var backgroundImageView: UIImageView!
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var aboutButton: UIButton!
    private var recommendMasksButton: UIButton!
    private var contributeDataButton: UIButton!
    private var emailTextField: UITextField!
    private var passwordTextField: UITextField!
    private var termsCheckbox: UIButton!
    private var termsTextView: UITextView!
    private var loginButton: UIButton!
    private var signUpButton: UIButton!
    private var activityIndicator: UIActivityIndicatorView!
    private var signUpActivityIndicator: UIActivityIndicatorView!
    private var errorLabel: UILabel!
    private var managedUsersButton: UIButton!
    private var logoutButton: UIButton!

    // MARK: - Properties
    private let authService = AuthenticationService()
    private let apiClient: APIClient
    private let offlineSyncManager: OfflineSyncManager

    private var managedUsers: [ManagedUser] = []
    private var isShowingLoginForm = false
    private var contributeButtonBottomConstraint: NSLayoutConstraint!
    private var isTermsAgreed = false

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
        // Note: We don't automatically show the login form here anymore
        // because it's confusing when a user is already logged in
        if authService.isAuthenticated {
            // Just load managed users in the background
            // User can tap "Contribute Data" to see the authenticated state
            loadManagedUsers()
        }
    }

    // MARK: - Setup Methods
    private func setupUI() {
        title = "SnapFit"
        // Set background color using hex #2F80ED
        view.backgroundColor = UIColor(red: 47/255, green: 128/255, blue: 237/255, alpha: 1.0)
        
        // Set navigation bar title text color to white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        // Create background image view
        backgroundImageView = UIImageView()
        backgroundImageView.image = UIImage(named: "HomeScreenBackgroundImage")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundImageView)

        // Create scroll view
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        // Create content view
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        // Create About button with semi-transparent background
        aboutButton = UIButton(type: .system)
        aboutButton.setTitle("About", for: .normal)
        aboutButton.backgroundColor = UIColor(white: 0.5, alpha: 0.7)
        aboutButton.setTitleColor(UIColor.white, for: .normal)
        aboutButton.layer.cornerRadius = 8
        aboutButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        aboutButton.translatesAutoresizingMaskIntoConstraints = false
        aboutButton.addTarget(self, action: #selector(aboutButtonTapped), for: .touchUpInside)
        contentView.addSubview(aboutButton)

        // Create Recommend Me Masks button with semi-transparent background
        recommendMasksButton = UIButton(type: .system)
        recommendMasksButton.setTitle("Recommend Me Masks", for: .normal)
        recommendMasksButton.backgroundColor = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 0.8)
        recommendMasksButton.setTitleColor(UIColor.white, for: .normal)
        recommendMasksButton.layer.cornerRadius = 8
        recommendMasksButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        recommendMasksButton.translatesAutoresizingMaskIntoConstraints = false
        recommendMasksButton.addTarget(self, action: #selector(recommendMasksButtonTapped), for: .touchUpInside)
        contentView.addSubview(recommendMasksButton)

        // Create Contribute Data button with orange semi-transparent background
        contributeDataButton = UIButton(type: .system)
        contributeDataButton.setTitle("Contribute Facial Measurement Data", for: .normal)
        contributeDataButton.backgroundColor = UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 0.85)
        contributeDataButton.setTitleColor(UIColor.white, for: .normal)
        contributeDataButton.layer.cornerRadius = 8
        contributeDataButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        contributeDataButton.titleLabel?.numberOfLines = 1
        contributeDataButton.titleLabel?.adjustsFontSizeToFitWidth = true
        contributeDataButton.titleLabel?.minimumScaleFactor = 0.7
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

        // Create terms checkbox (styled as a button)
        termsCheckbox = UIButton(type: .custom)
        termsCheckbox.setImage(UIImage(systemName: "square"), for: .normal)
        termsCheckbox.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        termsCheckbox.tintColor = .white
        termsCheckbox.translatesAutoresizingMaskIntoConstraints = false
        termsCheckbox.addTarget(self, action: #selector(termsCheckboxTapped), for: .touchUpInside)
        contentView.addSubview(termsCheckbox)

        // Create terms text view with clickable links
        termsTextView = UITextView()
        termsTextView.isEditable = false
        termsTextView.isScrollEnabled = false
        termsTextView.backgroundColor = .clear
        termsTextView.textColor = .white
        termsTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        termsTextView.textContainer.lineFragmentPadding = 0
        termsTextView.font = UIFont.systemFont(ofSize: 14)
        termsTextView.linkTextAttributes = [
            .foregroundColor: UIColor.white,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        termsTextView.delegate = self
        termsTextView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set up the attributed text with links
        let termsText = "By signing up, you agree to our Terms of Service, Consent form, Disclaimer, and Privacy Policy."
        let attributedString = NSMutableAttributedString(string: termsText)
        
        // Set default attributes
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14), range: NSRange(location: 0, length: termsText.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: termsText.count))
        
        // Define links
        let links: [(text: String, url: String)] = [
            ("Terms of Service", "https://www.breathesafe.xyz/#/terms_of_service"),
            ("Consent form", "https://www.breathesafe.xyz/#/consent_form"),
            ("Disclaimer", "https://www.breathesafe.xyz/#/disclaimer"),
            ("Privacy Policy", "https://www.breathesafe.xyz/#/privacy")
        ]
        
        // Apply link styling
        for link in links {
            let range = (termsText as NSString).range(of: link.text)
            if range.location != NSNotFound {
                attributedString.addAttribute(.link, value: link.url, range: range)
                attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: range)
                attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
            }
        }
        
        termsTextView.attributedText = attributedString
        contentView.addSubview(termsTextView)

        // Create login button with orange background
        loginButton = UIButton(type: .system)
        loginButton.setTitle("Login", for: .normal)
        loginButton.backgroundColor = UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)
        loginButton.setTitleColor(UIColor.white, for: .normal)
        loginButton.layer.cornerRadius = 8
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.addTarget(self, action: #selector(loginButtonTapped(_:)), for: .touchUpInside)
        contentView.addSubview(loginButton)

        // Create activity indicator for login button
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(activityIndicator)

        // Create sign up button with green background
        signUpButton = UIButton(type: .system)
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.backgroundColor = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 0.8)
        signUpButton.setTitleColor(UIColor.white, for: .normal)
        signUpButton.layer.cornerRadius = 8
        signUpButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped(_:)), for: .touchUpInside)
        signUpButton.isEnabled = false
        signUpButton.alpha = 0.5 // Visual indication that it's disabled
        contentView.addSubview(signUpButton)

        // Create activity indicator for sign up button
        signUpActivityIndicator = UIActivityIndicatorView(style: .medium)
        signUpActivityIndicator.hidesWhenStopped = true
        signUpActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(signUpActivityIndicator)

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

        // Create logout button
        logoutButton = UIButton(type: .system)
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.backgroundColor = UIColor.systemRed
        logoutButton.setTitleColor(UIColor.white, for: .normal)
        logoutButton.layer.cornerRadius = 8
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        logoutButton.isHidden = true
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        contentView.addSubview(logoutButton)

        // Hide login form initially
        emailTextField.isHidden = true
        passwordTextField.isHidden = true
        termsCheckbox.isHidden = true
        termsTextView.isHidden = true
        loginButton.isHidden = true
        signUpButton.isHidden = true

        setupConstraints()
    }

    private func setupConstraints() {
        // Create the bottom constraint for contribute button (used when main menu is shown)
        contributeButtonBottomConstraint = contributeDataButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        
        NSLayoutConstraint.activate([
            // Background image view - fills entire screen
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

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
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),

            // Contribute Data button - positioned at bottom
            contributeDataButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contributeDataButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            contributeDataButton.heightAnchor.constraint(equalToConstant: 44),
            contributeButtonBottomConstraint,

            // Recommend Masks button - above Contribute button
            recommendMasksButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            recommendMasksButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            recommendMasksButton.heightAnchor.constraint(equalToConstant: 44),
            recommendMasksButton.bottomAnchor.constraint(equalTo: contributeDataButton.topAnchor, constant: -16),

            // About button - above Recommend Masks button
            aboutButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            aboutButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            aboutButton.heightAnchor.constraint(equalToConstant: 44),
            aboutButton.bottomAnchor.constraint(equalTo: recommendMasksButton.topAnchor, constant: -16),

            // Email text field - positioned at top of login form
            emailTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),

            // Password text field - below Email field
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),

            // Terms checkbox - below Password field
            termsCheckbox.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 16),
            termsCheckbox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            termsCheckbox.widthAnchor.constraint(equalToConstant: 30),
            termsCheckbox.heightAnchor.constraint(equalToConstant: 30),

            // Terms text view - next to checkbox
            termsTextView.leadingAnchor.constraint(equalTo: termsCheckbox.trailingAnchor, constant: 8),
            termsTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            termsTextView.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 16),

            // Login button - below Terms section
            loginButton.topAnchor.constraint(equalTo: termsTextView.bottomAnchor, constant: 16),
            loginButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            loginButton.heightAnchor.constraint(equalToConstant: 50),

            // Activity indicator for login button
            activityIndicator.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor),

            // Sign Up button - below Login button
            signUpButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 16),
            signUpButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            signUpButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            signUpButton.heightAnchor.constraint(equalToConstant: 50),

            // Activity indicator for sign up button
            signUpActivityIndicator.centerXAnchor.constraint(equalTo: signUpButton.centerXAnchor),
            signUpActivityIndicator.centerYAnchor.constraint(equalTo: signUpButton.centerYAnchor),

            // Error label - hidden, errors now shown in alerts
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            errorLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),

            // Managed users button
            managedUsersButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            managedUsersButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            managedUsersButton.heightAnchor.constraint(equalToConstant: 50),
            managedUsersButton.bottomAnchor.constraint(equalTo: logoutButton.topAnchor, constant: -16),

            // Logout button
            logoutButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            logoutButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            logoutButton.heightAnchor.constraint(equalToConstant: 50),
            logoutButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
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
    @objc private func aboutButtonTapped() {
        let aboutVC = AboutViewController()
        navigationController?.pushViewController(aboutVC, animated: true)
    }

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
        // If user is already authenticated, show the authenticated state
        // Otherwise, show the login form
        if authService.isAuthenticated {
            // User is already logged in, show the authenticated state
            showLoginForm()
            updateManagedUsersButton()
            showAuthenticatedState()
        } else {
            // Show fresh login form
            showLoginForm()
        }
    }

    @objc private func termsCheckboxTapped() {
        isTermsAgreed.toggle()
        termsCheckbox.isSelected = isTermsAgreed
        
        // Enable/disable sign up button based on checkbox state
        signUpButton.isEnabled = isTermsAgreed
        signUpButton.alpha = isTermsAgreed ? 1.0 : 0.5
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

    @objc private func signUpButtonTapped(_ sender: UIButton) {
        // Dismiss keyboard when sign up button is tapped
        view.endEditing(true)
        
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showError("Please enter both email and password")
            return
        }

        guard isTermsAgreed else {
            showError("Please check the box saying that you agree with the Terms of Service, Consent Form, Disclaimer, and Privacy Policy")
            return
        }

        signUp(email: email, password: password)
    }

    @objc private func managedUsersButtonTapped(_ sender: UIButton) {
        showManagedUsersSelection()
    }

    @objc private func logoutButtonTapped() {
        // Perform logout
        authService.logout { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Successfully logged out")
                case .failure(let error):
                    print("Logout error: \(error)")
                }
                
                // Clear managed users
                self?.managedUsers = []
                
                // Return to main menu
                self?.showMainMenu()
            }
        }
    }

    // MARK: - Authentication Methods
    private func login(email: String, password: String) {
        setLoading(true, isSignUp: false)
        hideError()

        // Clear any old managed users before logging in
        managedUsers = []
        managedUsersButton.isHidden = true

        // Add some debugging
        print("Attempting login with email: \(email)")
        print("Using endpoint: https://www.breathesafe.xyz/users/log_in")

        authService.login(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.setLoading(false, isSignUp: false)

                switch result {
                case .success(let user):
                    print("Successfully logged in as: \(user.email) with ID: \(user.id)")
                    self?.loadManagedUsers()
                case .failure(let error):
                    print("Login failed with error: \(error)")
                    self?.showError("Login failed: \(error.localizedDescription)")
                }
            }
        }
    }

    private func signUp(email: String, password: String) {
        setLoading(true, isSignUp: true)
        hideError()

        print("Attempting sign up with email: \(email)")
        print("Using endpoint: https://www.breathesafe.xyz/users")

        // Create the request
        guard let url = URL(string: "https://www.breathesafe.xyz/users") else {
            setLoading(false, isSignUp: true)
            showError("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let body: [String: Any] = [
            "user": [
                "email": email,
                "password": password,
                "accept_consent": true
            ]
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            setLoading(false, isSignUp: true)
            showError("Failed to encode request: \(error.localizedDescription)")
            return
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.setLoading(false, isSignUp: true)

                if let error = error {
                    print("Sign up error: \(error)")
                    self?.showError("Sign up failed: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.showError("Invalid response from server")
                    return
                }

                print("Sign up response status code: \(httpResponse.statusCode)")

                if httpResponse.statusCode == 201 {
                    // Success
                    self?.showConfirmation("Sent a confirmation email to \(email). Please check your email.")
                    // Clear the form
                    self?.emailTextField.text = ""
                    self?.passwordTextField.text = ""
                    self?.isTermsAgreed = false
                    self?.termsCheckbox.isSelected = false
                    self?.signUpButton.isEnabled = false
                    self?.signUpButton.alpha = 0.5
                } else {
                    // Parse error message if available
                    if let data = data,
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let errors = json["errors"] as? [String: [String]] {
                        let errorMessages = errors.values.flatMap { $0 }.joined(separator: ", ")
                        self?.showError("Sign up failed: \(errorMessages)")
                    } else {
                        self?.showError("Sign up failed with status code: \(httpResponse.statusCode)")
                    }
                }
            }
        }.resume()
    }

    private func loadManagedUsers() {
        // Clear old managed users first
        managedUsers = []
        managedUsersButton.isHidden = true
        
        print("Loading managed users for current user: \(authService.currentUser?.email ?? "unknown") (ID: \(authService.currentUser?.id ?? -1))")
        
        authService.loadManagedUsers { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    print("Successfully loaded \(users.count) managed users for user ID: \(self?.authService.currentUser?.id ?? -1)")
                    if users.count > 0 {
                        print("First managed user: \(users[0].displayName) (managed_id: \(users[0].managedId))")
                    }
                    self?.managedUsers = users
                    self?.updateManagedUsersButton()
                    self?.showAuthenticatedState()
                case .failure(let error):
                    print("Failed to load managed users: \(error)")
                    // Still show authenticated state even if loading managed users fails
                    self?.showAuthenticatedState()
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

    private func showAuthenticatedState() {
        // Hide login form
        emailTextField.isHidden = true
        passwordTextField.isHidden = true
        termsCheckbox.isHidden = true
        termsTextView.isHidden = true
        loginButton.isHidden = true
        signUpButton.isHidden = true
        errorLabel.isHidden = true
        
        // Show logout button
        logoutButton.isHidden = false
        
        // Keep the "Fit testers" text and back button visible
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
    private func setLoading(_ loading: Bool, isSignUp: Bool) {
        if isSignUp {
            if loading {
                signUpActivityIndicator.startAnimating()
                signUpButton.setTitle("", for: .normal)
                signUpButton.isEnabled = false
            } else {
                signUpActivityIndicator.stopAnimating()
                signUpButton.setTitle("Sign Up", for: .normal)
                signUpButton.isEnabled = isTermsAgreed
            }
        } else {
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
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func showConfirmation(_ message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func hideError() {
        // No longer needed as errors are shown in alerts
    }

    private func showLoginForm() {
        isShowingLoginForm = true
        
        // Hide background image to show solid #2F80ED color
        backgroundImageView.isHidden = true
        
        // Deactivate contribute button bottom constraint
        contributeButtonBottomConstraint.isActive = false
        
        // Hide main menu buttons
        aboutButton.isHidden = true
        recommendMasksButton.isHidden = true
        contributeDataButton.isHidden = true
        
        // Check if already authenticated - if so, show authenticated state
        // Otherwise show the login/signup form
        if authService.isAuthenticated {
            // User is already logged in, show authenticated state
            emailTextField.isHidden = true
            passwordTextField.isHidden = true
            termsCheckbox.isHidden = true
            termsTextView.isHidden = true
            loginButton.isHidden = true
            signUpButton.isHidden = true
            
            // Load managed users for the currently authenticated user
            loadManagedUsers()
        } else {
            // Clear any old managed users data
            managedUsers = []
            managedUsersButton.isHidden = true
            logoutButton.isHidden = true
            
            // Show login form
            emailTextField.isHidden = false
            passwordTextField.isHidden = false
            termsCheckbox.isHidden = false
            termsTextView.isHidden = false
            loginButton.isHidden = false
            signUpButton.isHidden = false
        }
        
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
        // If user is authenticated, don't clear anything
        // If user is not authenticated, we can optionally clear cookies here
        // but it's better to do it on explicit logout
        showMainMenu()
    }

    private func showMainMenu() {
        isShowingLoginForm = false
        
        // Show background image again
        backgroundImageView.isHidden = false
        
        // Activate contribute button bottom constraint
        contributeButtonBottomConstraint.isActive = true
        
        // Show main menu buttons
        aboutButton.isHidden = false
        recommendMasksButton.isHidden = false
        contributeDataButton.isHidden = false
        
        // Hide login form and authenticated state
        emailTextField.isHidden = true
        passwordTextField.isHidden = true
        termsCheckbox.isHidden = true
        termsTextView.isHidden = true
        loginButton.isHidden = true
        signUpButton.isHidden = true
        errorLabel.isHidden = true
        managedUsersButton.isHidden = true
        logoutButton.isHidden = true
        
        // Remove back button from navigation bar
        navigationItem.leftBarButtonItem = nil
        
        // Clear fields
        emailTextField.text = ""
        passwordTextField.text = ""
        isTermsAgreed = false
        termsCheckbox.isSelected = false
        signUpButton.isEnabled = false
        signUpButton.alpha = 0.5
        
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
        // Open link in SFSafariViewController
        let safariVC = SFSafariViewController(url: URL)
        safariVC.preferredControlTintColor = UIColor(red: 47/255, green: 128/255, blue: 237/255, alpha: 1.0)
        present(safariVC, animated: true)
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
