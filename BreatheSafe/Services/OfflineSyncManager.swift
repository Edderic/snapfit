import Foundation
import UIKit

/// Protocol for handling offline sync events
protocol OfflineSyncManagerDelegate: AnyObject {
    func offlineSyncManager(_ manager: OfflineSyncManager, didSyncPendingMeasurements count: Int)
    func offlineSyncManager(_ manager: OfflineSyncManager, didEncounterError error: OfflineSyncError)
}

/// Manager for handling offline data storage and synchronization
class OfflineSyncManager {
    weak var delegate: OfflineSyncManagerDelegate?
    
    /// File manager for local storage
    private let fileManager = FileManager.default
    
    /// Documents directory URL
    private var documentsDirectory: URL {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    /// Directory for storing pending measurements
    private var pendingMeasurementsDirectory: URL {
        let url = documentsDirectory.appendingPathComponent("PendingMeasurements")
        if !fileManager.fileExists(atPath: url.path) {
            try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        }
        return url
    }
    
    /// API client for syncing data
    private let apiClient: APIClient
    
    /// Authentication service for checking login status
    private let authService: AuthenticationService
    
    init(apiClient: APIClient, authService: AuthenticationService) {
        self.apiClient = apiClient
        self.authService = authService
        
        // Start monitoring network connectivity
        startNetworkMonitoring()
    }
    
    // MARK: - Offline Storage
    
    /// Save measurements offline for later sync
    func saveMeasurementsOffline(_ measurements: [String: Any], for userId: Int) {
        let timestamp = Date().timeIntervalSince1970
        let filename = "measurements_\(userId)_\(timestamp).json"
        let fileURL = pendingMeasurementsDirectory.appendingPathComponent(filename)
        
        let offlineData: [String: Any] = [
            "measurements": measurements,
            "userId": userId,
            "timestamp": timestamp,
            "retryCount": 0
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: offlineData, options: .prettyPrinted)
            try jsonData.write(to: fileURL)
            print("Saved measurements offline: \(filename)")
        } catch {
            print("Failed to save measurements offline: \(error)")
            delegate?.offlineSyncManager(self, didEncounterError: .storageError(error))
        }
    }
    
    /// Get all pending measurements
    func getPendingMeasurements() -> [PendingMeasurement] {
        var pendingMeasurements: [PendingMeasurement] = []
        
        do {
            let files = try fileManager.contentsOfDirectory(at: pendingMeasurementsDirectory, includingPropertiesForKeys: nil)
            
            for fileURL in files {
                if fileURL.pathExtension == "json" {
                    let data = try Data(contentsOf: fileURL)
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let measurements = json["measurements"] as? [String: Any],
                       let userId = json["userId"] as? Int,
                       let timestamp = json["timestamp"] as? TimeInterval,
                       let retryCount = json["retryCount"] as? Int {
                        
                        let pendingMeasurement = PendingMeasurement(
                            measurements: measurements,
                            userId: userId,
                            timestamp: timestamp,
                            retryCount: retryCount,
                            fileURL: fileURL
                        )
                        pendingMeasurements.append(pendingMeasurement)
                    }
                }
            }
        } catch {
            print("Failed to read pending measurements: \(error)")
            delegate?.offlineSyncManager(self, didEncounterError: .storageError(error))
        }
        
        return pendingMeasurements.sorted { $0.timestamp < $1.timestamp }
    }
    
    /// Remove a pending measurement file
    private func removePendingMeasurement(at fileURL: URL) {
        do {
            try fileManager.removeItem(at: fileURL)
        } catch {
            print("Failed to remove pending measurement file: \(error)")
        }
    }
    
    // MARK: - Synchronization
    
    /// Sync all pending measurements
    func syncPendingMeasurements() {
        guard authService.isAuthenticated else {
            print("Not authenticated, skipping sync")
            return
        }
        
        let pendingMeasurements = getPendingMeasurements()
        guard !pendingMeasurements.isEmpty else {
            print("No pending measurements to sync")
            return
        }
        
        print("Syncing \(pendingMeasurements.count) pending measurements")
        
        let syncGroup = DispatchGroup()
        var syncedCount = 0
        
        for pendingMeasurement in pendingMeasurements {
            syncGroup.enter()
            
            apiClient.exportFacialMeasurements(pendingMeasurement.measurements, for: pendingMeasurement.userId) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        syncedCount += 1
                        self?.removePendingMeasurement(at: pendingMeasurement.fileURL)
                        print("Successfully synced measurement for user \(pendingMeasurement.userId)")
                    case .failure(let error):
                        print("Failed to sync measurement for user \(pendingMeasurement.userId): \(error)")
                        
                        // Increment retry count
                        self?.incrementRetryCount(for: pendingMeasurement)
                        
                        // If retry count exceeds limit, remove the file
                        if pendingMeasurement.retryCount >= 3 {
                            self?.removePendingMeasurement(at: pendingMeasurement.fileURL)
                            print("Removed measurement after 3 failed attempts")
                        }
                    }
                    
                    syncGroup.leave()
                }
            }
        }
        
        syncGroup.notify(queue: .main) { [weak self] in
            self?.delegate?.offlineSyncManager(self!, didSyncPendingMeasurements: syncedCount)
        }
    }
    
    /// Increment retry count for a pending measurement
    private func incrementRetryCount(for pendingMeasurement: PendingMeasurement) {
        let updatedData: [String: Any] = [
            "measurements": pendingMeasurement.measurements,
            "userId": pendingMeasurement.userId,
            "timestamp": pendingMeasurement.timestamp,
            "retryCount": pendingMeasurement.retryCount + 1
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: updatedData, options: .prettyPrinted)
            try jsonData.write(to: pendingMeasurement.fileURL)
        } catch {
            print("Failed to update retry count: \(error)")
        }
    }
    
    /// Clear all pending measurements (use with caution)
    func clearAllPendingMeasurements() {
        do {
            let files = try fileManager.contentsOfDirectory(at: pendingMeasurementsDirectory, includingPropertiesForKeys: nil)
            for fileURL in files {
                try fileManager.removeItem(at: fileURL)
            }
            print("Cleared all pending measurements")
        } catch {
            print("Failed to clear pending measurements: \(error)")
            delegate?.offlineSyncManager(self, didEncounterError: .storageError(error))
        }
    }
    
    // MARK: - Network Monitoring
    
    private func startNetworkMonitoring() {
        // Monitor network reachability
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged),
            name: .reachabilityChanged,
            object: nil
        )
        
        // Try to sync when app becomes active
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func networkStatusChanged() {
        // Check if we have network connectivity and sync if needed
        syncPendingMeasurements()
    }
    
    @objc private func appDidBecomeActive() {
        // Try to sync when app becomes active
        syncPendingMeasurements()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

/// Represents a pending measurement waiting to be synced
struct PendingMeasurement {
    let measurements: [String: Any]
    let userId: Int
    let timestamp: TimeInterval
    let retryCount: Int
    let fileURL: URL
}

/// Offline sync errors
enum OfflineSyncError: Error, LocalizedError {
    case storageError(Error)
    case syncError(Error)
    
    var errorDescription: String? {
        switch self {
        case .storageError(let error):
            return "Storage error: \(error.localizedDescription)"
        case .syncError(let error):
            return "Sync error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Network Reachability Extension
extension Notification.Name {
    static let reachabilityChanged = Notification.Name("ReachabilityChanged")
}