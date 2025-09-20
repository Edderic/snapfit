import Foundation
import ARKit

/// Protocol for receiving measurement updates
protocol MeasurementEngineDelegate: AnyObject {
    func measurementEngine(_ engine: MeasurementEngine, didUpdateMeasurements measurements: [String: Float])
    func measurementEngine(_ engine: MeasurementEngine, didEncounterError error: Error)
}

/// Engine responsible for calculating facial measurements from ARKit data
class MeasurementEngine {
    weak var delegate: MeasurementEngineDelegate?
    
    /// Custom measurement pairs defined by the user
    private var customMeasurementPairs: [(Int, Int)] = []
    
    /// Measurement history for analysis
    private var measurementHistory: [[String: Float]] = []
    
    /// Maximum number of measurements to keep in history
    private let maxHistoryCount = 100
    
    init() {
        // Initialize with common measurement pairs
        customMeasurementPairs = FacialMeasurementPairs.commonPairs
    }
    
    /// Update custom measurement pairs
    func updateMeasurementPairs(_ pairs: [(Int, Int)]) {
        customMeasurementPairs = pairs
    }
    
    /// Process facial landmarks and calculate measurements
    func processLandmarks(_ landmarks: FacialLandmarks) {
        do {
            let measurements = landmarks.distances(between: customMeasurementPairs)
            
            // Add to history
            addToHistory(measurements)
            
            // Notify delegate
            delegate?.measurementEngine(self, didUpdateMeasurements: measurements)
            
        } catch {
            delegate?.measurementEngine(self, didEncounterError: error)
        }
    }
    
    /// Add measurements to history
    private func addToHistory(_ measurements: [String: Float]) {
        measurementHistory.append(measurements)
        
        // Keep only the most recent measurements
        if measurementHistory.count > maxHistoryCount {
            measurementHistory.removeFirst()
        }
    }
    
    /// Get average measurements from recent history
    func getAverageMeasurements(fromLast count: Int = 10) -> [String: Float] {
        let recentMeasurements = Array(measurementHistory.suffix(count))
        
        guard !recentMeasurements.isEmpty else {
            return [:]
        }
        
        var averages: [String: Float] = [:]
        
        // Get all measurement keys
        let allKeys = Set(recentMeasurements.flatMap { $0.keys })
        
        for key in allKeys {
            let values = recentMeasurements.compactMap { $0[key] }
            if !values.isEmpty {
                averages[key] = values.reduce(0, +) / Float(values.count)
            }
        }
        
        return averages
    }
    
    /// Get measurement statistics
    func getMeasurementStatistics() -> [String: (min: Float, max: Float, avg: Float, count: Int)] {
        var statistics: [String: (min: Float, max: Float, avg: Float, count: Int)] = [:]
        
        let allKeys = Set(measurementHistory.flatMap { $0.keys })
        
        for key in allKeys {
            let values = measurementHistory.compactMap { $0[key] }
            
            if !values.isEmpty {
                let min = values.min() ?? 0
                let max = values.max() ?? 0
                let avg = values.reduce(0, +) / Float(values.count)
                
                statistics[key] = (min: min, max: max, avg: avg, count: values.count)
            }
        }
        
        return statistics
    }
    
    /// Clear measurement history
    func clearHistory() {
        measurementHistory.removeAll()
    }
    
    /// Export measurements for webapp integration
    func exportMeasurements() -> [String: Any] {
        let averageMeasurements = getAverageMeasurements()
        let statistics = getMeasurementStatistics()
        
        return [
            "timestamp": Date().timeIntervalSince1970,
            "average_measurements": averageMeasurements,
            "statistics": statistics,
            "total_samples": measurementHistory.count,
            "measurement_pairs": customMeasurementPairs.map { ["from": $0.0, "to": $0.1] }
        ]
    }
}