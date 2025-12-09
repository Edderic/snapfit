import UIKit
import ARKit
import SceneKit
import SafariServices

@available(iOS 13.0, *)
class FaceMeasurementViewController: UIViewController {

    // MARK: - UI Elements
    var sceneView: ARSCNView!
    var instructionLabel: UILabel!
    var measurementLabel: UITextView!
    var startButton: UIButton!
    var exportButton: UIButton!
    var statusLabel: UILabel!
    var progressView: UIProgressView!
    var logoutButton: UIButton!
    var toggleMeasurementsButton: UIButton!
    var otherOptionsButton: UIButton!

    // MARK: - Properties
    private let measurementEngine = MeasurementEngine()
    private let dataExportManager = DataExportManager()
    private var isMeasuring = false
    private var measurementCount = 0
    private let requiredMeasurements = 30 // Number of measurements to collect
    private var isMeasurementsVisible = false
    private var managedUsers: [ManagedUser] = []

    // Authentication and API properties
    // TODO: Uncomment these once the new model files are added to the Xcode project
    var selectedUser: ManagedUser?
    var authService: AuthenticationService?
    var apiClient: APIClient?
    var offlineSyncManager: OfflineSyncManager?

    // MARK: - Overlay Properties
    private var landmarkNodes: [Int: SCNNode] = [:]
    private var measurementLineNodes: [String: SCNNode] = [:]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupARKit()
        setupDelegates()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startARSession()
        loadManagedUsers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    // MARK: - Setup Methods
    private func setupUI() {
        // Update title to show selected user
        if let user = selectedUser {
            title = "Face Measurement - \(user.displayName)"
        } else {
            title = "Face Measurement"
        }
        view.backgroundColor = UIColor.systemBackground

        // Create ARSCNView
        sceneView = ARSCNView()
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sceneView)

        // Create instruction label
        instructionLabel = UILabel()
        instructionLabel.text = "Position your face close to the camera (less than 12 inches away) in portrait mode. Remove glasses, hats, or anything covering your face."
        instructionLabel.numberOfLines = 0
        instructionLabel.textAlignment = .center
        instructionLabel.font = UIFont.systemFont(ofSize: 16)
        instructionLabel.textColor = UIColor.label
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionLabel)

        // Create progress view
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.progress = 0.0
        progressView.isHidden = true
        progressView.progressTintColor = UIColor.systemBlue
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)

        // Create status label
        statusLabel = UILabel()
        statusLabel.text = "Ready to start"
        statusLabel.textAlignment = .center
        statusLabel.font = UIFont.systemFont(ofSize: 14)
        statusLabel.textColor = UIColor.secondaryLabel
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)

        // Create measurement label (using UITextView for better text display)
        measurementLabel = UITextView()
        measurementLabel.text = "Measurements will appear here after you start a measurement.\n\nPress 'Start Measurement' to begin collecting facial measurement data."
        measurementLabel.font = UIFont.systemFont(ofSize: 14)
        measurementLabel.backgroundColor = UIColor.secondarySystemBackground
        measurementLabel.textColor = UIColor.label
        measurementLabel.isEditable = false
        measurementLabel.isScrollEnabled = true
        measurementLabel.layer.cornerRadius = 8
        measurementLabel.layer.borderWidth = 1
        measurementLabel.layer.borderColor = UIColor.separator.cgColor
        measurementLabel.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        measurementLabel.isHidden = true
        measurementLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(measurementLabel)

        // Create start button
        startButton = UIButton(type: .system)
        startButton.setTitle("Start Measurement", for: .normal)
        startButton.backgroundColor = UIColor.systemBlue
        startButton.setTitleColor(UIColor.white, for: .normal)
        startButton.layer.cornerRadius = 8
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.addTarget(self, action: #selector(startButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(startButton)

        // Create export button
        exportButton = UIButton(type: .system)
        exportButton.setTitle("Export Data", for: .normal)
        exportButton.backgroundColor = UIColor.systemGreen
        exportButton.setTitleColor(UIColor.white, for: .normal)
        exportButton.layer.cornerRadius = 8
        exportButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        exportButton.isEnabled = false
        exportButton.translatesAutoresizingMaskIntoConstraints = false
        exportButton.addTarget(self, action: #selector(exportButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(exportButton)

        // Create logout button (hidden, accessed via Other Options)
        logoutButton = UIButton(type: .system)
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.backgroundColor = UIColor.systemRed
        logoutButton.setTitleColor(UIColor.white, for: .normal)
        logoutButton.layer.cornerRadius = 8
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        logoutButton.isHidden = true
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(logoutButton)

        // Create toggle measurements button (hidden, accessed via Other Options)
        toggleMeasurementsButton = UIButton(type: .system)
        toggleMeasurementsButton.setTitle("Show Measurements", for: .normal)
        toggleMeasurementsButton.backgroundColor = UIColor.systemGray
        toggleMeasurementsButton.setTitleColor(UIColor.white, for: .normal)
        toggleMeasurementsButton.layer.cornerRadius = 8
        toggleMeasurementsButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        toggleMeasurementsButton.isHidden = true
        toggleMeasurementsButton.translatesAutoresizingMaskIntoConstraints = false
        toggleMeasurementsButton.addTarget(self, action: #selector(toggleMeasurementsButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(toggleMeasurementsButton)

        // Create other options button
        otherOptionsButton = UIButton(type: .system)
        otherOptionsButton.setTitle("Other Options", for: .normal)
        otherOptionsButton.backgroundColor = UIColor.systemIndigo
        otherOptionsButton.setTitleColor(UIColor.white, for: .normal)
        otherOptionsButton.layer.cornerRadius = 8
        otherOptionsButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        otherOptionsButton.translatesAutoresizingMaskIntoConstraints = false
        otherOptionsButton.addTarget(self, action: #selector(otherOptionsButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(otherOptionsButton)

        // Set up constraints
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // ARSCNView fills the entire view
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Instruction label
            instructionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Progress view
            progressView.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 16),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Status label
            statusLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Measurement label
            measurementLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16),
            measurementLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            measurementLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            measurementLabel.heightAnchor.constraint(equalToConstant: 100),
            measurementLabel.bottomAnchor.constraint(lessThanOrEqualTo: startButton.topAnchor, constant: -20),

            // Other Options button (bottom button)
            otherOptionsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            otherOptionsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            otherOptionsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            otherOptionsButton.heightAnchor.constraint(equalToConstant: 50),

            // Export button (above other options)
            exportButton.bottomAnchor.constraint(equalTo: otherOptionsButton.topAnchor, constant: -12),
            exportButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            exportButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            exportButton.heightAnchor.constraint(equalToConstant: 50),

            // Start button (above export)
            startButton.bottomAnchor.constraint(equalTo: exportButton.topAnchor, constant: -12),
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            startButton.heightAnchor.constraint(equalToConstant: 50),

            // Hidden buttons (for reference, but not visible)
            logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            logoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),

            toggleMeasurementsButton.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -12),
            toggleMeasurementsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            toggleMeasurementsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            toggleMeasurementsButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func setupARKit() {
        // Check if device supports ARKit and True Depth
        guard ARFaceTrackingConfiguration.isSupported else {
            showError("ARKit face tracking is not supported on this device")
            return
        }

        // Configure ARSCNView
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.automaticallyUpdatesLighting = true

        // Add face geometry visualization
        setupFaceGeometry()

        // Setup measurement overlays
        setupMeasurementOverlays()
    }

    private func setupFaceGeometry() {
        // Create a simple face geometry visualization
        let faceGeometry = ARSCNFaceGeometry(device: sceneView.device!)
        let material = faceGeometry?.firstMaterial
        material?.diffuse.contents = UIColor.systemBlue.withAlphaComponent(0.3)
        material?.isDoubleSided = true
    }

    private func setupMeasurementOverlays() {
        // Create landmark point nodes for each measurement pair
        let allIndices = Set(FacialMeasurementPairs.commonPairs.flatMap { [$0.0, $0.1] })

        for index in allIndices {
            let pointNode = createLandmarkPointNode(index: index)
            landmarkNodes[index] = pointNode
        }

        // Create line nodes for each measurement pair
        for (index1, index2) in FacialMeasurementPairs.commonPairs {
            let lineNode = createMeasurementLineNode(from: index1, to: index2)
            let key = "\(index1)-\(index2)"
            measurementLineNodes[key] = lineNode
        }
    }

    private func createLandmarkPointNode(index: Int) -> SCNNode {
        // Create a small white sphere for the landmark point
        let sphere = SCNSphere(radius: 0.001) // 1mm radius
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white
        material.emission.contents = UIColor.white.withAlphaComponent(0.5)
        sphere.materials = [material]

        let pointNode = SCNNode(geometry: sphere)
        pointNode.name = "landmark_\(index)"

        // Add text label for the landmark index
        let textGeometry = SCNText(string: "\(index)", extrusionDepth: 0.0001)
        textGeometry.font = UIFont.systemFont(ofSize: 0.002)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.white
        textGeometry.firstMaterial?.emission.contents = UIColor.white.withAlphaComponent(0.8)

        let textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(0, 0.002, 0) // Position text above the point
        pointNode.addChildNode(textNode)

        return pointNode
    }

    private func createMeasurementLineNode(from index1: Int, to index2: Int) -> SCNNode {
        // Create a red line between two landmarks
        let lineGeometry = SCNCylinder(radius: 0.0002, height: 1.0) // 0.2mm radius
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        material.emission.contents = UIColor.red.withAlphaComponent(0.3)
        lineGeometry.materials = [material]

        let lineNode = SCNNode(geometry: lineGeometry)
        lineNode.name = "line_\(index1)_\(index2)"

        return lineNode
    }

    private func addMeasurementOverlays(to faceNode: SCNNode, faceGeometry: ARFaceGeometry) {
        // Add landmark point nodes
        for (index, pointNode) in landmarkNodes {
            if index < faceGeometry.vertices.count {
                let vertex = faceGeometry.vertices[index]
                pointNode.position = SCNVector3(vertex.x, vertex.y, vertex.z)
                faceNode.addChildNode(pointNode)
            }
        }

        // Add measurement line nodes
        for (key, lineNode) in measurementLineNodes {
            let components = key.split(separator: "-")
            if components.count == 2,
               let index1 = Int(components[0]),
               let index2 = Int(components[1]),
               index1 < faceGeometry.vertices.count,
               index2 < faceGeometry.vertices.count {

                let vertex1 = faceGeometry.vertices[index1]
                let vertex2 = faceGeometry.vertices[index2]

                // Position the line between the two vertices
                positionLineNode(lineNode, from: vertex1, to: vertex2)
                faceNode.addChildNode(lineNode)
            }
        }
    }

    private func positionLineNode(_ lineNode: SCNNode, from vertex1: SIMD3<Float>, to vertex2: SIMD3<Float>) {
        // Calculate the midpoint
        let midpoint = SIMD3<Float>(
            (vertex1.x + vertex2.x) / 2,
            (vertex1.y + vertex2.y) / 2,
            (vertex1.z + vertex2.z) / 2
        )

        // Calculate the distance between vertices
        let distance = sqrt(
            pow(vertex2.x - vertex1.x, 2) +
            pow(vertex2.y - vertex1.y, 2) +
            pow(vertex2.z - vertex1.z, 2)
        )

        // Position the line at the midpoint
        lineNode.position = SCNVector3(midpoint.x, midpoint.y, midpoint.z)

        // Scale the line to the correct length
        lineNode.scale = SCNVector3(1, distance, 1)

        // Orient the line to point from vertex1 to vertex2
        let direction = SIMD3<Float>(
            vertex2.x - vertex1.x,
            vertex2.y - vertex1.y,
            vertex2.z - vertex1.z
        )

        // Calculate rotation to align the line
        let up = SIMD3<Float>(0, 1, 0)
        let right = cross(up, direction)
        let forward = cross(right, up)

        // Create rotation matrix
        let rotationMatrix = simd_float4x4(
            SIMD4<Float>(right.x, right.y, right.z, 0),
            SIMD4<Float>(up.x, up.y, up.z, 0),
            SIMD4<Float>(forward.x, forward.y, forward.z, 0),
            SIMD4<Float>(0, 0, 0, 1)
        )

        lineNode.transform = SCNMatrix4(rotationMatrix)
    }

    private func updateMeasurementOverlays(faceGeometry: ARFaceGeometry) {
        // Update landmark point positions
        for (index, pointNode) in landmarkNodes {
            if index < faceGeometry.vertices.count {
                let vertex = faceGeometry.vertices[index]
                pointNode.position = SCNVector3(vertex.x, vertex.y, vertex.z)
            }
        }

        // Update measurement line positions
        for (key, lineNode) in measurementLineNodes {
            let components = key.split(separator: "-")
            if components.count == 2,
               let index1 = Int(components[0]),
               let index2 = Int(components[1]),
               index1 < faceGeometry.vertices.count,
               index2 < faceGeometry.vertices.count {

                let vertex1 = faceGeometry.vertices[index1]
                let vertex2 = faceGeometry.vertices[index2]
                positionLineNode(lineNode, from: vertex1, to: vertex2)
            }
        }
    }

    private func setupDelegates() {
        measurementEngine.delegate = self
        dataExportManager.delegate = self
    }

    private func startARSession() {
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        configuration.maximumNumberOfTrackedFaces = 1

        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    // MARK: - Actions
    @objc func startButtonTapped(_ sender: UIButton) {
        if isMeasuring {
            stopMeasurement()
        } else {
            startMeasurement()
        }
    }

    @objc func exportButtonTapped(_ sender: UIButton) {
        exportData()
    }

    private func openViewDataPage() {
        // Check if user is authenticated
        guard let authService = authService, authService.isAuthenticated else {
            // User not authenticated, dismiss and return to login
            dismiss(animated: true)
            return
        }
        
        // Check if user is selected
        guard let selectedUser = selectedUser,
              let managedId = selectedUser.managedId else {
            showError("No user selected")
            return
        }
        
        // Construct URL
        let urlString = "http://www.breathesafe.xyz/#/respirator_user/\(managedId)?tabToShow=Facial+Measurements"
        
        guard let url = URL(string: urlString) else {
            showError("Invalid URL")
            return
        }
        
        // Open in Safari
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @objc func logoutButtonTapped(_ sender: UIButton) {
        logout()
    }

    @objc func otherOptionsButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Other Options",
            message: nil,
            preferredStyle: .actionSheet
        )

        // Switch Respirator User
        if authService?.isAuthenticated == true {
            alert.addAction(UIAlertAction(title: "Switch Respirator User", style: .default) { [weak self] _ in
                self?.showManagedUsersSelection()
            })
        }

        // Show/Hide Measurements View
        let measurementsTitle = isMeasurementsVisible ? "Hide Measurements View" : "Show Measurements View"
        alert.addAction(UIAlertAction(title: measurementsTitle, style: .default) { [weak self] _ in
            self?.toggleMeasurements()
        })

        // View data on Breathesafe
        if authService?.isAuthenticated == true && selectedUser != nil {
            alert.addAction(UIAlertAction(title: "View data on Breathesafe", style: .default) { [weak self] _ in
                self?.openViewDataPage()
            })
        }

        // Logout
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            self?.logout()
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // For iPad
        if let popover = alert.popoverPresentationController {
            popover.sourceView = otherOptionsButton
            popover.sourceRect = otherOptionsButton.bounds
        }

        present(alert, animated: true)
    }

    @objc func switchUserButtonTapped(_ sender: UIButton) {
        showManagedUsersSelection()
    }

    private func toggleMeasurements() {
        isMeasurementsVisible.toggle()
        measurementLabel.isHidden = !isMeasurementsVisible
        
        // If showing measurements again, refresh the display
        if isMeasurementsVisible {
            let averageMeasurements = measurementEngine.getAverageMeasurements()
            displayMeasurements(averageMeasurements)
        }
    }

    @objc func toggleMeasurementsButtonTapped(_ sender: UIButton) {
        toggleMeasurements()
    }

    // MARK: - Measurement Control
    private func startMeasurement() {
        isMeasuring = true
        measurementCount = 0
        measurementEngine.clearHistory()

        startButton.setTitle("Stop Measurement", for: .normal)
        startButton.backgroundColor = UIColor.systemRed
        exportButton.isEnabled = false
        progressView.isHidden = false
        progressView.progress = 0.0

        instructionLabel.text = "Keep your face steady and centered in the camera view. Measurements are being collected..."
        statusLabel.text = "Collecting measurements..."

        // Update UI to show measurement is active
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        }
    }

    private func stopMeasurement() {
        isMeasuring = false

        startButton.setTitle("Start Measurement", for: .normal)
        startButton.backgroundColor = UIColor.systemBlue
        exportButton.isEnabled = true
        progressView.isHidden = true

        instructionLabel.text = "Measurement complete! You can now export your data."
        statusLabel.text = "Measurement complete"

        // Reset background color
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = UIColor.systemBackground
        }

        // Show final measurements
        let averageMeasurements = measurementEngine.getAverageMeasurements()
        displayMeasurements(averageMeasurements)
    }

    // MARK: - Data Display
    private func displayMeasurements(_ measurements: [String: Float]) {
        guard isMeasurementsVisible else { return }
        
        if measurements.isEmpty {
            measurementLabel.text = "Collecting measurements...\n\nMeasurements will appear here as they are collected."
            return
        }
        
        let title = isMeasuring ? "Current Measurements (Live):\n\n" : "Average Measurements:\n\n"
        var measurementText = title

        for (key, value) in measurements.sorted(by: { $0.key < $1.key }) {
            let description = FacialMeasurementPairs.pairDescriptions[key] ?? key
            measurementText += "\(description): \(String(format: "%.3f", value))\n"
        }

        measurementLabel.text = measurementText
    }

    // MARK: - Data Export
    private func exportData() {
        let measurements = measurementEngine.exportMeasurements()

        // Request user consent if not already given
        if !dataExportManager.hasUserConsent {
            dataExportManager.requestUserConsent(from: self) { [weak self] consented in
                if consented {
                    self?.performExport(measurements)
                } else {
                    self?.showLocalExportOptions(measurements)
                }
            }
        } else {
            performExport(measurements)
        }
    }

    private func performExport(_ measurements: [String: Any]) {
        let alert = UIAlertController(title: "Export Data", message: "Choose how to export your measurements", preferredStyle: .actionSheet)

        // Prioritize server export if authenticated
        if authService?.isAuthenticated == true && selectedUser != nil {
            alert.addAction(UIAlertAction(title: "Send to BreatheSafe Server", style: .default) { _ in
                self.sendToServer(measurements)
            })
        }

        alert.addAction(UIAlertAction(title: "Share JSON via System", style: .default) { _ in
            self.dataExportManager.shareMeasurements(measurements, from: self)
        })

        alert.addAction(UIAlertAction(title: "Share CSV via System", style: .default) { _ in
            self.shareCSVData(measurements)
        })

        alert.addAction(UIAlertAction(title: "Save JSON to Files", style: .default) { _ in
            if let fileURL = self.dataExportManager.saveToLocalFile(measurements) {
                self.showSuccess("Data saved to: \(fileURL.lastPathComponent)")
            }
        })

        alert.addAction(UIAlertAction(title: "Save CSV to Files", style: .default) { _ in
            self.saveCSVToFiles(measurements)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // For iPad
        if let popover = alert.popoverPresentationController {
            popover.sourceView = exportButton
            popover.sourceRect = exportButton.bounds
        }

        present(alert, animated: true)
    }

    private func showLocalExportOptions(_ measurements: [String: Any]) {
        let alert = UIAlertController(title: "Export Data (Local Only)", message: "Your data will not be shared with external servers", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Share JSON via System", style: .default) { _ in
            self.dataExportManager.shareMeasurements(measurements, from: self)
        })

        alert.addAction(UIAlertAction(title: "Share CSV via System", style: .default) { _ in
            self.shareCSVData(measurements)
        })

        alert.addAction(UIAlertAction(title: "Save JSON to Files", style: .default) { _ in
            if let fileURL = self.dataExportManager.saveToLocalFile(measurements) {
                self.showSuccess("Data saved to: \(fileURL.lastPathComponent)")
            }
        })

        alert.addAction(UIAlertAction(title: "Save CSV to Files", style: .default) { _ in
            self.saveCSVToFiles(measurements)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // For iPad
        if let popover = alert.popoverPresentationController {
            popover.sourceView = exportButton
            popover.sourceRect = exportButton.bounds
        }

        present(alert, animated: true)
    }

    private func sendToServer(_ measurements: [String: Any]) {
        // TODO: Uncomment this once the new model files are added to the Xcode project
        guard let selectedUser = selectedUser,
              let apiClient = apiClient else {
            showError("No user selected or API client not available")
            return
        }

        // // Check if user is authenticated
        guard let authService = authService, authService.isAuthenticated else {
            showError("User is not authenticated. Please login first.")
            return
        }

        // Export to Rails backend
        apiClient.exportFacialMeasurements(measurements, for: selectedUser.managedId ?? 0) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.showSuccess("Data sent to server successfully!")
                case .failure(let error):
                    self?.showError("Failed to send data: \(error.localizedDescription)")

                    // If there's a network error, save offline
                    if case APIError.networkError = error {
                        self?.saveOffline(measurements)
                    }
                }
            }
        }

        // Temporary fallback to original functionality
        dataExportManager.setServerURL("https://breathesafe.xyz/users/1/facial_measurements_from_arkit")

        dataExportManager.sendToServer(measurements) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.showSuccess("Data sent to server successfully!")
                case .failure(let error):
                    self.showError("Failed to send data: \(error.localizedDescription)")
                }
            }
        }
    }

    // TODO: Uncomment these methods once the new model files are added to the Xcode project
    private func saveOffline(_ measurements: [String: Any]) {
        guard let selectedUser = selectedUser,
              let offlineSyncManager = offlineSyncManager else {
            return
        }

        offlineSyncManager.saveMeasurementsOffline(measurements, for: selectedUser.managedId ?? 0)
        showSuccess("Data saved offline and will sync when connected")
    }

    private func loadManagedUsers() {
        guard let authService = authService, authService.isAuthenticated else {
            return
        }

        authService.loadManagedUsers { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    self?.managedUsers = users
                case .failure(let error):
                    self?.showError("Failed to load managed users: \(error.localizedDescription)")
                }
            }
        }
    }

    private func showManagedUsersSelection() {
        // Check if we have managed users
        if managedUsers.isEmpty {
            let alert = UIAlertController(
                title: "No Managed Users",
                message: "There are no managed (respirator) users currently. Please create at least one.",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.openRespiratorUsersPage()
            })
            
            present(alert, animated: true)
            return
        }

        let alert = UIAlertController(
            title: "Switch Respirator User",
            message: "Choose a user to switch to:",
            preferredStyle: .actionSheet
        )

        for user in managedUsers {
            let title: String
            if let selectedUser = selectedUser,
               user.managedId == selectedUser.managedId {
                // Mark currently selected user with checkmark
                title = "✓ \(user.displayName)"
            } else {
                title = user.displayName
            }
            
            alert.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.switchToUser(user)
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // For iPad
        if let popover = alert.popoverPresentationController {
            popover.sourceView = otherOptionsButton
            popover.sourceRect = otherOptionsButton.bounds
        }

        present(alert, animated: true)
    }

    private func switchToUser(_ user: ManagedUser) {
        // Stop measurement if currently measuring
        if isMeasuring {
            isMeasuring = false
            measurementEngine.clearHistory()
        }
        
        // Clear/reset current measurements
        measurementEngine.clearHistory()
        measurementCount = 0
        
        // Update selected user
        selectedUser = user
        
        // Update title
        title = "Face Measurement - \(user.displayName)"
        
        // Reset UI
        startButton.setTitle("Start Measurement", for: .normal)
        startButton.backgroundColor = UIColor.systemBlue
        exportButton.isEnabled = false
        progressView.isHidden = true
        progressView.progress = 0.0
        statusLabel.text = "Ready to start"
        instructionLabel.text = "Position your face close to the camera (less than 12 inches away) in portrait mode. Remove glasses, hats, or anything covering your face."
        
        // Clear measurements display
        measurementLabel.text = "Measurements will appear here after you start a measurement.\n\nPress 'Start Measurement' to begin collecting facial measurement data."
        
        // Reset background color
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = UIColor.systemBackground
        }
    }

    private func openRespiratorUsersPage() {
        guard let url = URL(string: "https://www.breathesafe.xyz/#/respirator_users") else {
            showError("Invalid URL")
            return
        }
        
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }

    private func logout() {
        guard let authService = authService else {
            return
        }

        let alert = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to logout?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            authService.logout { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        // Dismiss the current view controller and return to login
                        self?.dismiss(animated: true)
                    case .failure(let error):
                        self?.showError("Logout failed: \(error.localizedDescription)")
                    }
                }
            }
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func shareCSVData(_ measurements: [String: Any]) {
        guard let csvString = dataExportManager.exportToCSV(measurements) else {
            showError("Failed to generate CSV data")
            return
        }

        let activityViewController = UIActivityViewController(
            activityItems: [csvString],
            applicationActivities: nil
        )

        // For iPad
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = exportButton
            popover.sourceRect = exportButton.bounds
            popover.permittedArrowDirections = []
        }

        present(activityViewController, animated: true)
    }

    private func saveCSVToFiles(_ measurements: [String: Any]) {
        guard let csvString = dataExportManager.exportToCSV(measurements) else {
            showError("Failed to generate CSV data")
            return
        }

        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent("facial_measurements.csv")

        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            showSuccess("CSV data saved to: \(fileURL.lastPathComponent)")
        } catch {
            showError("Failed to save CSV file: \(error.localizedDescription)")
        }
    }

    // MARK: - Helper Methods
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func showSuccess(_ message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - ARSCNViewDelegate
extension FaceMeasurementViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }

        // Create face geometry visualization
        guard let device = sceneView.device else {
            return
        }

        let faceGeometry = ARSCNFaceGeometry(device: device)
        let faceNode = SCNNode(geometry: faceGeometry)

        let material = faceGeometry?.firstMaterial
        material?.diffuse.contents = UIColor.systemBlue.withAlphaComponent(0.3)
        material?.isDoubleSided = true

        node.addChildNode(faceNode)

        // Add measurement overlays to the face node
        addMeasurementOverlays(to: node, faceGeometry: faceAnchor.geometry)
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }

        // Update the face geometry visualization if it exists
        if let faceGeometry = node.geometry as? ARSCNFaceGeometry {
            faceGeometry.update(from: faceAnchor.geometry)
        }

        // Update measurement overlays
        updateMeasurementOverlays(faceGeometry: faceAnchor.geometry)

        // Process facial landmarks for measurement
        if isMeasuring {
            let landmarks = FacialLandmarks(from: faceAnchor.geometry, timestamp: CACurrentMediaTime())
            measurementEngine.processLandmarks(landmarks)
        }
    }
}

// MARK: - ARSessionDelegate
extension FaceMeasurementViewController: ARSessionDelegate {
    func session(_ session: ARSession, didFailWithError error: Error) {
        showError("ARKit session failed: \(error.localizedDescription)")
    }

    func sessionWasInterrupted(_ session: ARSession) {
        statusLabel.text = "Session interrupted"
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        statusLabel.text = "Session resumed"
        startARSession()
    }
}

// MARK: - MeasurementEngineDelegate
extension FaceMeasurementViewController: MeasurementEngineDelegate {
    func measurementEngine(_ engine: MeasurementEngine, didUpdateMeasurements measurements: [String: Float]) {
        DispatchQueue.main.async {
            self.measurementCount += 1
            let progress = Float(self.measurementCount) / Float(self.requiredMeasurements)
            self.progressView.progress = min(progress, 1.0)

            // Update status
            self.statusLabel.text = "Collected \(self.measurementCount) measurements"

            // Show current measurements
            self.displayMeasurements(measurements)

            // Auto-stop when enough measurements collected
            if self.measurementCount >= self.requiredMeasurements {
                self.stopMeasurement()
            }
        }
    }

    func measurementEngine(_ engine: MeasurementEngine, didEncounterError error: Error) {
        DispatchQueue.main.async {
            self.showError("Measurement error: \(error.localizedDescription)")
        }
    }
}

// MARK: - DataExportManagerDelegate
extension FaceMeasurementViewController: DataExportManagerDelegate {
    func dataExportManager(_ manager: DataExportManager, didCompleteExport data: [String: Any]) {
        DispatchQueue.main.async {
            self.showSuccess("Data exported successfully!")
        }
    }

    func dataExportManager(_ manager: DataExportManager, didEncounterError error: Error) {
        DispatchQueue.main.async {
            self.showError("Export error: \(error.localizedDescription)")
        }
    }
}
