import Foundation
import UIKit

/// Protocol for handling data export events
protocol DataExportManagerDelegate: AnyObject {
    func dataExportManager(_ manager: DataExportManager, didCompleteExport data: [String: Any])
    func dataExportManager(_ manager: DataExportManager, didEncounterError error: Error)
}

/// Manager responsible for exporting facial measurement data
class DataExportManager {
    weak var delegate: DataExportManagerDelegate?
    
    /// Webapp server URL for data submission
    private var serverURL: String?
    
    /// User consent for data sharing
    var hasUserConsent: Bool = false
    
    init() {
        // Load saved consent status
        hasUserConsent = UserDefaults.standard.bool(forKey: "hasUserConsent")
    }
    
    /// Set the webapp server URL
    func setServerURL(_ url: String) {
        serverURL = url
    }
    
    /// Request user consent for data sharing
    func requestUserConsent(from viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(
            title: "Data Sharing Consent",
            message: "This app can help improve mask fitting recommendations by sharing anonymous facial measurements with our research team. Your data will be used to develop better mask fitting algorithms. No personal information will be collected.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Share Data", style: .default) { _ in
            self.hasUserConsent = true
            UserDefaults.standard.set(true, forKey: "hasUserConsent")
            completion(true)
        })
        
        alert.addAction(UIAlertAction(title: "Keep Data Private", style: .cancel) { _ in
            self.hasUserConsent = false
            UserDefaults.standard.set(false, forKey: "hasUserConsent")
            completion(false)
        })
        
        viewController.present(alert, animated: true)
    }
    
    /// Export measurements to JSON format
    func exportToJSON(_ measurements: [String: Any]) -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: measurements, options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            delegate?.dataExportManager(self, didEncounterError: error)
            return nil
        }
    }
    
    /// Share measurements via system share sheet
    func shareMeasurements(_ measurements: [String: Any], from viewController: UIViewController) {
        guard let jsonString = exportToJSON(measurements) else {
            return
        }
        
        let activityViewController = UIActivityViewController(
            activityItems: [jsonString],
            applicationActivities: nil
        )
        
        // For iPad
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        viewController.present(activityViewController, animated: true)
    }
    
    /// Send measurements to webapp server
    func sendToServer(_ measurements: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        guard hasUserConsent else {
            completion(.failure(DataExportError.noConsent))
            return
        }
        
        guard let serverURL = serverURL,
              let url = URL(string: serverURL) else {
            completion(.failure(DataExportError.invalidServerURL))
            return
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: measurements)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse,
                          (200...299).contains(httpResponse.statusCode) else {
                        completion(.failure(DataExportError.serverError))
                        return
                    }
                    
                    completion(.success(()))
                }
            }.resume()
            
        } catch {
            completion(.failure(error))
        }
    }
    
    /// Generate CSV format for measurements
    func exportToCSV(_ measurements: [String: Any]) -> String? {
        guard let averageMeasurements = measurements["average_measurements"] as? [String: Float] else {
            return nil
        }
        
        var csv = "Measurement,Value\n"
        
        for (key, value) in averageMeasurements {
            let description = FacialMeasurementPairs.pairDescriptions[key] ?? key
            csv += "\"\(description)\",\(value)\n"
        }
        
        return csv
    }
    
    /// Save measurements to local file
    func saveToLocalFile(_ measurements: [String: Any], filename: String = "facial_measurements") -> URL? {
        guard let jsonString = exportToJSON(measurements) else {
            return nil
        }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent("\(filename).json")
        
        do {
            try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            delegate?.dataExportManager(self, didEncounterError: error)
            return nil
        }
    }
}

/// Errors that can occur during data export
enum DataExportError: Error, LocalizedError {
    case noConsent
    case invalidServerURL
    case serverError
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .noConsent:
            return "User has not consented to data sharing"
        case .invalidServerURL:
            return "Invalid server URL"
        case .serverError:
            return "Server error occurred"
        case .invalidData:
            return "Invalid measurement data"
        }
    }
}