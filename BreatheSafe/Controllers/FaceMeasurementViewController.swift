import UIKit
import ARKit
import SceneKit

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
    
    // MARK: - Properties
    private let measurementEngine = MeasurementEngine()
    private let dataExportManager = DataExportManager()
    private var isMeasuring = false
    private var measurementCount = 0
    private let requiredMeasurements = 30 // Number of measurements to collect
    
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        title = "Face Measurement"
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
        measurementLabel.text = "Measurements will appear here"
        measurementLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        measurementLabel.backgroundColor = UIColor.systemBackground
        measurementLabel.isEditable = false
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
            measurementLabel.heightAnchor.constraint(equalToConstant: 200),
            
            // Start button
            startButton.topAnchor.constraint(equalTo: measurementLabel.bottomAnchor, constant: 16),
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            startButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Export button
            exportButton.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 16),
            exportButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            exportButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            exportButton.heightAnchor.constraint(equalToConstant: 50),
            exportButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
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
    }
    
    private func setupFaceGeometry() {
        // Create a simple face geometry visualization
        let faceGeometry = ARSCNFaceGeometry(device: sceneView.device!)
        let material = faceGeometry?.firstMaterial
        material?.diffuse.contents = UIColor.systemBlue.withAlphaComponent(0.3)
        material?.isDoubleSided = true
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
        var measurementText = "Average Measurements:\n\n"
        
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
        
        alert.addAction(UIAlertAction(title: "Share via System", style: .default) { _ in
            self.dataExportManager.shareMeasurements(measurements, from: self)
        })
        
        alert.addAction(UIAlertAction(title: "Save to Files", style: .default) { _ in
            if let fileURL = self.dataExportManager.saveToLocalFile(measurements) {
                self.showSuccess("Data saved to: \(fileURL.lastPathComponent)")
            }
        })
        
        alert.addAction(UIAlertAction(title: "Send to Server", style: .default) { _ in
            self.sendToServer(measurements)
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
        
        alert.addAction(UIAlertAction(title: "Share via System", style: .default) { _ in
            self.dataExportManager.shareMeasurements(measurements, from: self)
        })
        
        alert.addAction(UIAlertAction(title: "Save to Files", style: .default) { _ in
            if let fileURL = self.dataExportManager.saveToLocalFile(measurements) {
                self.showSuccess("Data saved to: \(fileURL.lastPathComponent)")
            }
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
        // You can set your webapp server URL here
        dataExportManager.setServerURL("https://your-webapp-server.com/api/measurements")
        
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
        let faceGeometry = ARSCNFaceGeometry(device: sceneView.device!)
        let faceNode = SCNNode(geometry: faceGeometry)
        
        let material = faceGeometry?.firstMaterial
        material?.diffuse.contents = UIColor.systemBlue.withAlphaComponent(0.3)
        material?.isDoubleSided = true
        
        node.addChildNode(faceNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor,
              let faceGeometry = node.geometry as? ARSCNFaceGeometry else { return }
        
        faceGeometry.update(from: faceAnchor.geometry)
        
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
