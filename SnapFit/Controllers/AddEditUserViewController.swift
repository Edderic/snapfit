import UIKit
import SafariServices

/// View controller for adding or editing a managed user
class AddEditUserViewController: UIViewController {
    
    // MARK: - Section enum
    enum Section: Int, CaseIterable {
        case name = 0
        case demographics = 1
        case facialMeasurements = 2
        
        var title: String {
            switch self {
            case .name: return "Name"
            case .demographics: return "Demographics"
            case .facialMeasurements: return "Facial Measurements"
            }
        }
    }
    
    // MARK: - Properties
    private let authService: AuthenticationService
    private let apiClient: APIClient
    private var managedUser: ManagedUser?
    private var currentSection: Section = .name
    private var userId: Int?
    private var profileId: Int?
    
    // User data
    private var firstName: String = ""
    private var lastName: String = ""
    private var raceEthnicity: String?
    private var genderAndSex: String?
    private var otherGender: String?
    private var yearOfBirth: Int?
    
    // MARK: - UI Elements
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var progressBar: UIProgressView!
    private var progressLabel: UILabel!
    private var sectionTitleLabel: UILabel!
    private var messageLabel: UILabel!
    private var contentStackView: UIStackView!
    private var saveButton: UIButton!
    private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Initialization
    init(authService: AuthenticationService, apiClient: APIClient, managedUser: ManagedUser? = nil) {
        self.authService = authService
        self.apiClient = apiClient
        self.managedUser = managedUser
        super.init(nibName: nil, bundle: nil)
        
        // If editing existing user, populate data
        if let user = managedUser {
            self.userId = user.managedId
            self.profileId = user.profile?.id
            self.firstName = user.firstName ?? ""
            self.lastName = user.lastName ?? ""
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUIForCurrentSection()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = managedUser == nil ? "Add User" : "Edit User"
        view.backgroundColor = UIColor(red: 47/255, green: 128/255, blue: 237/255, alpha: 1.0)
        
        // Add cancel button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .white
        
        // Create scroll view
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Create content view
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Progress bar
        progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.progressTintColor = .green
        progressBar.trackTintColor = .white
        contentView.addSubview(progressBar)
        
        // Progress label
        progressLabel = UILabel()
        progressLabel.font = UIFont.systemFont(ofSize: 14)
        progressLabel.textColor = .white
        progressLabel.textAlignment = .center
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(progressLabel)
        
        // Section title
        sectionTitleLabel = UILabel()
        sectionTitleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        sectionTitleLabel.textColor = .white
        sectionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(sectionTitleLabel)
        
        // Message label
        messageLabel = UILabel()
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(messageLabel)
        
        // Content stack view
        contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.spacing = 16
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contentStackView)
        
        // Save button
        saveButton = UIButton(type: .system)
        saveButton.setTitle("Save & Continue", for: .normal)
        saveButton.backgroundColor = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 0.8)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 8
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        contentView.addSubview(saveButton)
        
        // Activity indicator
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(activityIndicator)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            progressBar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            progressBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            progressBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            progressLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 8),
            progressLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            progressLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            sectionTitleLabel.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 24),
            sectionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            sectionTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            messageLabel.topAnchor.constraint(equalTo: sectionTitleLabel.bottomAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            contentStackView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 24),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            saveButton.topAnchor.constraint(equalTo: contentStackView.bottomAnchor, constant: 24),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            activityIndicator.centerXAnchor.constraint(equalTo: saveButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor)
        ])
    }
    
    // MARK: - UI Updates
    private func updateUIForCurrentSection() {
        // Update progress
        let progress = Float(currentSection.rawValue + 1) / Float(Section.allCases.count)
        progressBar.setProgress(progress, animated: true)
        progressLabel.text = "\(currentSection.rawValue + 1) of \(Section.allCases.count): \(currentSection.title)"
        
        // Update section title
        sectionTitleLabel.text = currentSection.title
        
        // Clear content stack view
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Update content based on section
        switch currentSection {
        case .name:
            setupNameSection()
        case .demographics:
            setupDemographicsSection()
        case .facialMeasurements:
            setupFacialMeasurementsSection()
        }
        
        // Update save button text
        if currentSection == .facialMeasurements {
            saveButton.setTitle("Save & Continue", for: .normal)
        } else {
            saveButton.setTitle("Save & Continue", for: .normal)
        }
    }
    
    // MARK: - Section Setup
    private func setupNameSection() {
        messageLabel.text = "A user could input data on behalf of other users (e.g. a parent inputting data of their children). Adding names could help you distinguish among individuals who you'd be inputting data for. This data will not be shared publicly."
        
        // First name
        let firstNameLabel = createLabel(text: "What is the first name of the individual you'll be adding data for?")
        let firstNameField = createTextField(placeholder: "First name", text: firstName)
        firstNameField.tag = 100
        
        // Last name
        let lastNameLabel = createLabel(text: "What is the last name of the individual you'll be adding data for?")
        let lastNameField = createTextField(placeholder: "Last name", text: lastName)
        lastNameField.tag = 101
        
        contentStackView.addArrangedSubview(firstNameLabel)
        contentStackView.addArrangedSubview(firstNameField)
        contentStackView.addArrangedSubview(lastNameLabel)
        contentStackView.addArrangedSubview(lastNameField)
    }
    
    private func setupDemographicsSection() {
        messageLabel.text = "Demographic data will be used to assess sampling bias and this data will only be reported in aggregate. If a category has less than 5 types of people, individuals will be grouped in a \"not enough data/prefer not to disclose\" group to preserve privacy."
        
        let displayName = !firstName.isEmpty ? firstName : "the individual"
        
        // Race/Ethnicity
        let raceLabel = createLabel(text: "Which race or ethnicity best describes \(displayName)?")
        contentStackView.addArrangedSubview(raceLabel)
        
        let raceOptions = [
            "American Indian or Alaskan Native",
            "Asian / Pacific Islander",
            "Black or African American",
            "Hispanic",
            "White / Caucasian",
            "Multiple ethnicity / Other",
            "Prefer not to disclose"
        ]
        
        for (index, option) in raceOptions.enumerated() {
            let button = createRadioButton(title: option, tag: 200 + index, isSelected: raceEthnicity == option)
            contentStackView.addArrangedSubview(button)
        }
        
        // Gender
        let genderLabel = createLabel(text: "What is \(displayName)'s gender?")
        contentStackView.addArrangedSubview(genderLabel)
        
        let genderOptions = [
            "Cisgender male",
            "Cisgender female",
            "MTF transgender",
            "FTM transgender",
            "Intersex",
            "Prefer not to disclose",
            "Other"
        ]
        
        for (index, option) in genderOptions.enumerated() {
            let button = createRadioButton(title: option, tag: 300 + index, isSelected: genderAndSex == option)
            contentStackView.addArrangedSubview(button)
            
            // Add "Other" text field if "Other" is selected
            if option == "Other" && genderAndSex == "Other" {
                let otherField = createTextField(placeholder: "Please specify", text: otherGender ?? "")
                otherField.tag = 399
                contentStackView.addArrangedSubview(otherField)
            }
        }
        
        // Year of birth
        let yearLabel = createLabel(text: "What is \(displayName)'s year of birth? (Leave blank if \(displayName) prefers not to disclose)")
        let yearPicker = createYearPicker(selectedYear: yearOfBirth)
        yearPicker.tag = 400
        
        contentStackView.addArrangedSubview(yearLabel)
        contentStackView.addArrangedSubview(yearPicker)
    }
    
    private func setupFacialMeasurementsSection() {
        messageLabel.text = "Facial measurements help determine which masks will fit best."
        
        // Check if user has measurements
        if let user = managedUser, let fmPercent = user.fmPercentComplete, fmPercent >= 100 {
            // Show aggregated measurements table
            let tableLabel = createLabel(text: "Aggregated Measurements")
            tableLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
            contentStackView.addArrangedSubview(tableLabel)
            
            // TODO: Fetch and display actual measurements
            let measurements = [
                ("Nose", "Incomplete"),
                ("Strap", "Incomplete"),
                ("Top Cheek", "Incomplete"),
                ("Mid Cheek", "Incomplete"),
                ("Chin", "Incomplete")
            ]
            
            for (name, value) in measurements {
                let row = createMeasurementRow(name: name, value: value)
                contentStackView.addArrangedSubview(row)
            }
        } else {
            let noDataLabel = createLabel(text: "No facial measurements yet.")
            contentStackView.addArrangedSubview(noDataLabel)
        }
        
        // Add Facial Measurements button
        let addMeasurementsButton = UIButton(type: .system)
        addMeasurementsButton.setTitle("Add Facial Measurements", for: .normal)
        addMeasurementsButton.backgroundColor = UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)
        addMeasurementsButton.setTitleColor(.white, for: .normal)
        addMeasurementsButton.layer.cornerRadius = 8
        addMeasurementsButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        addMeasurementsButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        addMeasurementsButton.addTarget(self, action: #selector(addMeasurementsTapped), for: .touchUpInside)
        contentStackView.addArrangedSubview(addMeasurementsButton)
    }
    
    // MARK: - Helper Methods
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }
    
    private func createTextField(placeholder: String, text: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.text = text
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .white
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        textField.delegate = self
        return textField
    }
    
    private func createRadioButton(title: String, tag: Int, isSelected: Bool) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.tag = tag
        
        let image = isSelected ? UIImage(systemName: "circle.fill") : UIImage(systemName: "circle")
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        
        button.addTarget(self, action: #selector(radioButtonTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    private func createYearPicker(selectedYear: Int?) -> UIPickerView {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = .white
        picker.layer.cornerRadius = 8
        picker.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        // Select current year or provided year
        let currentYear = Calendar.current.component(.year, from: Date())
        if let year = selectedYear, year >= 1900, year < currentYear {
            let row = currentYear - year - 1
            picker.selectRow(row, inComponent: 0, animated: false)
        }
        
        return picker
    }
    
    private func createMeasurementRow(name: String, value: String) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        container.layer.cornerRadius = 8
        container.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.textColor = .white
        valueLabel.font = UIFont.systemFont(ofSize: 16)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(nameLabel)
        container.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            valueLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func radioButtonTapped(_ sender: UIButton) {
        let baseTag = (sender.tag / 100) * 100
        
        // Update selection for this group
        for view in contentStackView.arrangedSubviews {
            if let button = view as? UIButton, button.tag >= baseTag && button.tag < baseTag + 100 {
                let isSelected = button.tag == sender.tag
                let image = isSelected ? UIImage(systemName: "circle.fill") : UIImage(systemName: "circle")
                button.setImage(image, for: .normal)
            }
        }
        
        // Handle "Other" gender option
        if sender.tag >= 300 && sender.tag < 400 {
            // Remove existing "Other" text field if present
            if let otherFieldIndex = contentStackView.arrangedSubviews.firstIndex(where: { ($0 as? UITextField)?.tag == 399 }) {
                contentStackView.arrangedSubviews[otherFieldIndex].removeFromSuperview()
            }
            
            // Add "Other" text field if "Other" was selected
            if sender.tag == 306 { // "Other" button
                let otherField = createTextField(placeholder: "Please specify", text: otherGender ?? "")
                otherField.tag = 399
                
                // Insert after the "Other" button
                if let buttonIndex = contentStackView.arrangedSubviews.firstIndex(of: sender) {
                    contentStackView.insertArrangedSubview(otherField, at: buttonIndex + 1)
                }
            }
        }
    }
    
    @objc private func addMeasurementsTapped() {
        guard let userId = self.userId else {
            showError("User ID not available")
            return
        }
        
        // Navigate to FaceMeasurementViewController
        let faceMeasurementVC = FaceMeasurementViewController()
        
        // Create a temporary ManagedUser object
        let tempUser = ManagedUser(
            id: nil,
            managerId: authService.currentUser?.id,
            managedId: userId,
            user: nil,
            profile: nil,
            managerEmail: nil,
            firstName: firstName,
            lastName: lastName,
            email: nil,
            fmPercentComplete: nil,
            demogPercentComplete: nil
        )
        
        faceMeasurementVC.selectedUser = tempUser
        faceMeasurementVC.authService = authService
        faceMeasurementVC.apiClient = apiClient
        faceMeasurementVC.offlineSyncManager = OfflineSyncManager(apiClient: apiClient, authService: authService)
        
        let navController = UINavigationController(rootViewController: faceMeasurementVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    @objc private func saveButtonTapped() {
        // Collect data from current section
        switch currentSection {
        case .name:
            guard saveNameData() else { return }
        case .demographics:
            guard saveDemographicsData() else { return }
        case .facialMeasurements:
            // Just close and return to list
            dismiss(animated: true)
            return
        }
        
        // Move to next section or save
        if let nextSection = Section(rawValue: currentSection.rawValue + 1) {
            currentSection = nextSection
            updateUIForCurrentSection()
            scrollView.setContentOffset(.zero, animated: true)
        }
    }
    
    private func saveNameData() -> Bool {
        // Get text fields
        guard let firstNameField = contentStackView.arrangedSubviews.first(where: { ($0 as? UITextField)?.tag == 100 }) as? UITextField,
              let lastNameField = contentStackView.arrangedSubviews.first(where: { ($0 as? UITextField)?.tag == 101 }) as? UITextField else {
            return false
        }
        
        let newFirstName = firstNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let newLastName = lastNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        guard !newFirstName.isEmpty && !newLastName.isEmpty else {
            showError("Please enter both first and last name")
            return false
        }
        
        firstName = newFirstName
        lastName = newLastName
        
        // If this is a new user, create it first
        if userId == nil {
            createManagedUser()
            return false // Don't proceed yet, wait for API response
        } else {
            // Update existing user
            updateProfile()
            return false // Don't proceed yet, wait for API response
        }
    }
    
    private func saveDemographicsData() -> Bool {
        // Get selected race/ethnicity
        for view in contentStackView.arrangedSubviews {
            if let button = view as? UIButton, button.tag >= 200 && button.tag < 300 {
                if button.imageView?.image == UIImage(systemName: "circle.fill") {
                    raceEthnicity = button.title(for: .normal)
                }
            }
        }
        
        // Get selected gender
        for view in contentStackView.arrangedSubviews {
            if let button = view as? UIButton, button.tag >= 300 && button.tag < 400 {
                if button.imageView?.image == UIImage(systemName: "circle.fill") {
                    genderAndSex = button.title(for: .normal)
                }
            }
        }
        
        // Get other gender if specified
        if genderAndSex == "Other" {
            if let otherField = contentStackView.arrangedSubviews.first(where: { ($0 as? UITextField)?.tag == 399 }) as? UITextField {
                otherGender = otherField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        // Get year of birth
        if let picker = contentStackView.arrangedSubviews.first(where: { ($0 as? UIPickerView)?.tag == 400 }) as? UIPickerView {
            let currentYear = Calendar.current.component(.year, from: Date())
            let selectedRow = picker.selectedRow(inComponent: 0)
            yearOfBirth = currentYear - selectedRow - 1
        }
        
        // Validate
        guard raceEthnicity != nil else {
            showError("Please select a race/ethnicity")
            return false
        }
        
        guard genderAndSex != nil else {
            showError("Please select a gender")
            return false
        }
        
        if genderAndSex == "Other" && (otherGender?.isEmpty ?? true) {
            showError("Please specify other gender")
            return false
        }
        
        // Update profile with demographics
        updateProfile()
        return false // Don't proceed yet, wait for API response
    }
    
    // MARK: - API Calls
    private func createManagedUser() {
        setLoading(true)
        
        // First get CSRF token
        getCSRFToken { [weak self] csrfToken in
            guard let self = self else { return }
            
            guard let url = URL(string: "https://www.breathesafe.xyz/managed_users") else {
                self.setLoading(false)
                self.showError("Invalid URL")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            // Add CSRF token header
            if let token = csrfToken {
                request.setValue(token, forHTTPHeaderField: "X-CSRF-Token")
            }
            
            // Get session cookies
            if let cookies = HTTPCookieStorage.shared.cookies(for: url) {
                let cookieHeader = HTTPCookie.requestHeaderFields(with: cookies)
                for (key, value) in cookieHeader {
                    request.setValue(value, forHTTPHeaderField: key)
                }
            }
            
            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                DispatchQueue.main.async {
                    self?.setLoading(false)
                    
                    if let error = error {
                        self?.showError("Failed to create user: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        self?.showError("Invalid response")
                        return
                    }
                    
                    if httpResponse.statusCode == 201 || httpResponse.statusCode == 200 {
                        // Parse response to get user ID
                        if let data = data,
                           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let managedUser = json["managed_user"] as? [String: Any],
                           let managedId = managedUser["managed_id"] as? Int,
                           let profileId = managedUser["profile_id"] as? Int {
                            self?.userId = managedId
                            self?.profileId = profileId
                            
                            // Now update the profile with the name
                            self?.updateProfile()
                        } else {
                            self?.showError("Failed to parse response")
                        }
                    } else {
                        self?.showError("Failed to create user: Status \(httpResponse.statusCode)")
                    }
                }
            }.resume()
        }
    }
    
    private func updateProfile() {
        guard let userId = self.userId else {
            showError("User ID not available")
            return
        }
        
        setLoading(true)
        
        // First get CSRF token
        getCSRFToken { [weak self] csrfToken in
            guard let self = self else { return }
            
            guard let url = URL(string: "https://www.breathesafe.xyz/users/\(userId)/profile") else {
                self.setLoading(false)
                self.showError("Invalid URL")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            // Add CSRF token header
            if let token = csrfToken {
                request.setValue(token, forHTTPHeaderField: "X-CSRF-Token")
            }
            
            // Build profile data
            var profileData: [String: Any] = [
                "first_name": self.firstName,
                "last_name": self.lastName
            ]
            
            if let race = self.raceEthnicity {
                profileData["race_ethnicity"] = race
            }
            
            if let gender = self.genderAndSex {
                profileData["gender_and_sex"] = gender
            }
            
            if let other = self.otherGender, !other.isEmpty {
                profileData["other_gender"] = other
            }
            
            if let year = self.yearOfBirth {
                profileData["year_of_birth"] = year
            }
            
            let body: [String: Any] = ["profile": profileData]
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
            } catch {
                self.setLoading(false)
                self.showError("Failed to encode data")
                return
            }
            
            // Get session cookies
            if let cookies = HTTPCookieStorage.shared.cookies(for: url) {
                let cookieHeader = HTTPCookie.requestHeaderFields(with: cookies)
                for (key, value) in cookieHeader {
                    request.setValue(value, forHTTPHeaderField: key)
                }
            }
            
            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                DispatchQueue.main.async {
                    self?.setLoading(false)
                    
                    if let error = error {
                        self?.showError("Failed to update profile: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        self?.showError("Invalid response")
                        return
                    }
                    
                    if httpResponse.statusCode == 200 {
                        // Success - move to next section
                        if let nextSection = Section(rawValue: (self?.currentSection.rawValue ?? 0) + 1) {
                            self?.currentSection = nextSection
                            self?.updateUIForCurrentSection()
                            self?.scrollView.setContentOffset(.zero, animated: true)
                        }
                    } else {
                        self?.showError("Failed to update profile: Status \(httpResponse.statusCode)")
                    }
                }
            }.resume()
        }
    }
    
    // MARK: - Helper Methods
    private func getCSRFToken(completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://www.breathesafe.xyz/csrf_token") else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let token = json["csrf_token"] as? String {
                completion(token)
            } else {
                completion(nil)
            }
        }.resume()
    }
    
    private func setLoading(_ loading: Bool) {
        if loading {
            activityIndicator.startAnimating()
            saveButton.setTitle("", for: .normal)
            saveButton.isEnabled = false
        } else {
            activityIndicator.stopAnimating()
            saveButton.setTitle("Save & Continue", for: .normal)
            saveButton.isEnabled = true
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension AddEditUserViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UIPickerViewDelegate & UIPickerViewDataSource
extension AddEditUserViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let currentYear = Calendar.current.component(.year, from: Date())
        return currentYear - 1900 // Years from 1900 to current year - 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let currentYear = Calendar.current.component(.year, from: Date())
        let year = currentYear - row - 1
        return "\(year)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let currentYear = Calendar.current.component(.year, from: Date())
        yearOfBirth = currentYear - row - 1
    }
}
