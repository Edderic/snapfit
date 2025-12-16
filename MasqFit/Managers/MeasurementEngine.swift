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
    
    /// Landmark coordinates history for analysis
    private var landmarkCoordinatesHistory: [[String: [String: Float]]] = []
    
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
        let measurements = landmarks.distances(between: customMeasurementPairs)
        
        // Extract unique landmark indices from measurement pairs
        let uniqueIndices = Set(customMeasurementPairs.flatMap { [$0.0, $0.1] })
        let coordinates = landmarks.exportCoordinates(for: Array(uniqueIndices))
        
        // Add to history
        addToHistory(measurements)
        addCoordinatesToHistory(coordinates)
        
        // Notify delegate
        delegate?.measurementEngine(self, didUpdateMeasurements: measurements)
    }
    
    /// Add measurements to history
    private func addToHistory(_ measurements: [String: Float]) {
        measurementHistory.append(measurements)
        
        // Keep only the most recent measurements
        if measurementHistory.count > maxHistoryCount {
            measurementHistory.removeFirst()
        }
    }
    
    /// Add landmark coordinates to history
    private func addCoordinatesToHistory(_ coordinates: [String: [String: Float]]) {
        landmarkCoordinatesHistory.append(coordinates)
        
        // Keep only the most recent coordinates
        if landmarkCoordinatesHistory.count > maxHistoryCount {
            landmarkCoordinatesHistory.removeFirst()
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
        landmarkCoordinatesHistory.removeAll()
    }
    
    /// Get average landmark coordinates from recent history
    func getAverageLandmarkCoordinates(fromLast count: Int = 10) -> [String: [String: Float]] {
        let recentCoordinates = Array(landmarkCoordinatesHistory.suffix(count))
        
        guard !recentCoordinates.isEmpty else {
            return [:]
        }
        
        var averageCoordinates: [String: [String: Float]] = [:]
        
        // Get all landmark indices
        let allIndices = Set(recentCoordinates.flatMap { $0.keys })
        
        for index in allIndices {
            let xValues = recentCoordinates.compactMap { $0[index]?["x"] }
            let yValues = recentCoordinates.compactMap { $0[index]?["y"] }
            let zValues = recentCoordinates.compactMap { $0[index]?["z"] }
            
            if !xValues.isEmpty && !yValues.isEmpty && !zValues.isEmpty {
                averageCoordinates[index] = [
                    "x": xValues.reduce(0, +) / Float(xValues.count),
                    "y": yValues.reduce(0, +) / Float(yValues.count),
                    "z": zValues.reduce(0, +) / Float(zValues.count)
                ]
            }
        }
        
        return averageCoordinates
    }
    
    /// Export measurements for webapp integration
    func exportMeasurements() -> [String: Any] {
        let averageMeasurements = getAverageMeasurements()
        let statistics = getMeasurementStatistics()
        let averageCoordinates = getAverageLandmarkCoordinates()
        
        // Convert statistics to JSON-compatible format
        var jsonStatistics: [String: [String: Any]] = [:]
        for (key, stats) in statistics {
            jsonStatistics[key] = [
                "min": stats.min,
                "max": stats.max,
                "avg": stats.avg,
                "count": stats.count
            ]
        }
        
        // Create measurement pairs with descriptions
        let measurementPairsWithDescriptions = customMeasurementPairs.map { pair in
            let key = "\(pair.0)-\(pair.1)"
            let description = FacialMeasurementPairs.pairDescriptions[key] ?? "Landmark \(pair.0) to \(pair.1)"
            return [
                "from": pair.0,
                "to": pair.1,
                "description": description,
                "key": key
            ]
        }
        
        // Create average measurements with descriptions
        var averageMeasurementsWithDescriptions: [String: Any] = [:]
        for (key, value) in averageMeasurements {
            let description = FacialMeasurementPairs.pairDescriptions[key] ?? "Landmark \(key)"
            averageMeasurementsWithDescriptions[key] = [
                "value": value * 1000,  // Convert to millimeters
                "description": description
            ]
        }
        
        // Create landmark coordinates with descriptions
        var landmarkCoordinatesWithDescriptions: [String: Any] = [:]
        for (index, coordinates) in averageCoordinates {
            landmarkCoordinatesWithDescriptions[index] = [
                "x": (coordinates["x"] ?? 0) * 1000,  // Convert to millimeters
                "y": (coordinates["y"] ?? 0) * 1000,
                "z": (coordinates["z"] ?? 0) * 1000
            ]
        }
        
        return [
            "timestamp": Date().timeIntervalSince1970,
            "average_measurements": averageMeasurementsWithDescriptions,
            "landmark_coordinates": landmarkCoordinatesWithDescriptions,
            "statistics": jsonStatistics,
            "total_samples": measurementHistory.count,
            "measurement_pairs": measurementPairsWithDescriptions,
            "units": [
                "primary": "millimeters"
            ]
        ]
    }
}