import Foundation
import ARKit

/// Represents a facial landmark with its index and 3D position
struct FacialLandmark {
    let index: Int
    let position: SIMD3<Float>
    
    init(index: Int, position: SIMD3<Float>) {
        self.index = index
        self.position = position
    }
}

/// Contains all facial landmarks detected from ARKit
struct FacialLandmarks {
    let landmarks: [Int: FacialLandmark]
    let timestamp: TimeInterval
    
    init(from faceGeometry: ARFaceGeometry, timestamp: TimeInterval) {
        self.timestamp = timestamp
        var landmarkDict: [Int: FacialLandmark] = [:]
        
        // Extract all available landmark indices from the face geometry
        // ARFaceGeometry.vertices is a buffer of SIMD3<Float> values
        let vertexCount = faceGeometry.vertices.count
        for i in 0..<vertexCount {
            let vertex = faceGeometry.vertices[i]
            landmarkDict[i] = FacialLandmark(index: i, position: vertex)
        }
        
        self.landmarks = landmarkDict
    }
    
    /// Get a specific landmark by index
    func landmark(at index: Int) -> FacialLandmark? {
        return landmarks[index]
    }
    
    /// Get multiple landmarks by indices
    func landmarks(at indices: [Int]) -> [FacialLandmark] {
        return indices.compactMap { landmarks[$0] }
    }
    
    /// Calculate distance between two landmarks
    func distance(between index1: Int, and index2: Int) -> Float? {
        guard let landmark1 = landmarks[index1],
              let landmark2 = landmarks[index2] else {
            return nil
        }
        
        let dx = landmark1.position.x - landmark2.position.x
        let dy = landmark1.position.y - landmark2.position.y
        let dz = landmark1.position.z - landmark2.position.z
        
        return sqrt(dx * dx + dy * dy + dz * dz)
    }
    
    /// Calculate multiple distances between landmark pairs
    func distances(between pairs: [(Int, Int)]) -> [String: Float] {
        var results: [String: Float] = [:]
        
        for (index1, index2) in pairs {
            if let distance = distance(between: index1, and: index2) {
                results["\(index1)-\(index2)"] = distance
            }
        }
        
        return results
    }
}

/// Predefined landmark pairs for common facial measurements
struct FacialMeasurementPairs {
    static let commonPairs: [(Int, Int)] = [
        // Start with basic pairs that are more likely to exist
        (0, 1),     // First two landmarks
        (1, 2),     // Second and third landmarks
        (2, 3),     // Third and fourth landmarks
        (0, 10),    // First and eleventh landmarks
        (10, 20),   // Eleventh and twenty-first landmarks
        // Add your specific landmark pairs here once you find valid indices
    ]
    
    static let pairDescriptions: [String: String] = [
        "0-1": "Landmark 0 to 1",
        "1-2": "Landmark 1 to 2", 
        "2-3": "Landmark 2 to 3",
        "0-10": "Landmark 0 to 10",
        "10-20": "Landmark 10 to 20",
        // Add descriptions for your pairs
    ]
}