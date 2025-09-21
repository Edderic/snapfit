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
    
    /// Export all landmark coordinates as a dictionary
    func exportCoordinates() -> [String: [String: Float]] {
        var coordinates: [String: [String: Float]] = [:]
        
        for (index, landmark) in landmarks {
            coordinates["\(index)"] = [
                "x": landmark.position.x,
                "y": landmark.position.y,
                "z": landmark.position.z
            ]
        }
        
        return coordinates
    }
    
    /// Export coordinates for specific landmark indices
    func exportCoordinates(for indices: [Int]) -> [String: [String: Float]] {
        var coordinates: [String: [String: Float]] = [:]
        
        for index in indices {
            if let landmark = landmarks[index] {
                coordinates["\(index)"] = [
                    "x": landmark.position.x,
                    "y": landmark.position.y,
                    "z": landmark.position.z
                ]
            }
        }
        
        return coordinates
    }
}

/// Predefined landmark pairs for common facial measurements
struct FacialMeasurementPairs {
    static let commonPairs: [(Int, Int)] = [
        (458, 1045),   // First two landmarks
        (15, 1049),   // First two landmarks
        (4, 7),   // First two landmarks
        (294, 589),   // First two landmarks
        (1049, 4),   // First two landmarks
        (638, 394),   // First two landmarks
        (967, 464),
        (464, 456),
        (456, 451),
        (451, 455),
        (999, 1027),
        (1027, 884),
        (884, 883),
        (883,879),
        (4, 38),
        (38, 5),
        (5, 37),
        (37, 6),
        (6, 7),
        (1049, 983),   // First two landmarks
        (983, 982),   // First two landmarks
        (982, 1050),   // First two landmarks
        (1050, 1051),   // First two landmarks
        (1051, 1052),   // First two landmarks
        (1052, 1053),   // First two landmarks
        (1053, 509),   // First two landmarks
        (509, 893),   // First two landmarks
        (893, 894),   // First two landmarks
        (894, 881),   // First two landmarks
        (881, 880),   // First two landmarks
        (880, 879),   // First two landmarks
        (879, 600),   // First two landmarks
        (600, 756),   // First two landmarks
        (756, 862),   // First two landmarks
        (862, 753),   // First two landmarks
        (753, 594),   // First two landmarks
        (594, 582),   // First two landmarks
        (582, 609),   // First two landmarks
        (609, 802),   // First two landmarks
        (802, 798),   // First two landmarks
        (798, 14),   // First two landmarks
        (14, 818),   // First two landmarks
        (1049, 984),   // First two landmarks
        (984, 985),    // First two landmarks
        (985, 986),    // First two landmarks
        (986, 987),    // First two landmarks
        (987, 988),    // First two landmarks
        (988, 989),    // First two landmarks
        (989, 60),     // First two landmarks
        (60, 478),     // First two landmarks
        (478, 479),     // First two landmarks
        (479, 453),     // First two landmarks
        (452, 451),     // First two landmarks
        (451, 151),     // First two landmarks
        (151, 321),     // First two landmarks
        (321, 434),     // First two landmarks
        (434, 318),     // First two landmarks
        (318, 145),     // First two landmarks
        (145, 133),     // First two landmarks
        (133, 160),     // First two landmarks
        (160, 371),     // First two landmarks
        (367, 387),     // First two landmarks
        (387, 14),     // First two landmarks
        // Add your specific landmark pairs here once you find valid indices
    ]

    static let pairDescriptions: [String: String] = [
        "458-1045": "face width",
        "15-1049": "face length",
        "4-7": "nose protrusion",
        "294-589": "nose breadth",
        "1049-4": "lower face length",
        "638-394": "lip width",
        "967-464": "left strap 4",
        "464-456": "left strap 3",
        "456-451": "left strap 2",
        "451-455": "left strap 1",
        "999-1027": "right strap 4",
        "1027-884": "right strap 3",
        "884-883": "right strap 2",
        "883-879": "right strap 1",
        "4-38": "nose protrusion 1",
        "38-5": "nose protrusion 2",
        "5-37": "nose protrusion 3",
        "37-6": "nose protrusion 4",
        "6-7": "nose protrusion 5",
        "1049-983": "chin right 7",
        "983-982": "chin right 6",
        "982-1050": "chin right 5",
        "1050-1051": "chin right 4",
        "1051-1052": "chin right 3",
        "1052-1053": "chin right 2",
        "1053-509": "chin right 1",
        "509-893": "mid right cheek 5",
        "893-894": "mid right cheek 4",
        "894-881": "mid right cheek 3",
        "881-880": "mid right cheek 2",
        "880-879": "mid right cheek 1",
        "879-600": "top right cheek 7",
        "600-756": "top right cheek 6",
        "756-862": "top right cheek 5",
        "862-753": "top right cheek 4",
        "753-594": "top right cheek 3",
        "594-582": "top right cheek 2",
        "582-609": "top right cheek 1",
        "609-802": "nose right 4",
        "802-798": "nose right 3",
        "798-14": "nose right 2",
        "14-818": "nose right 1",
        "1049-984": "chin left 7",
        "984-985": "chin left 6",
        "985-986": "chin left 5",
        "986-987": "chin left 4",
        "987-988": "chin left 3",
        "988-989": "chin left 2",
        "989-60": "chin left 1",
        "60-478": "mid left cheek 5",
        "478-479": "mid left cheek 4",
        "479-453": "mid left cheek 3",
        "453-452": "mid left cheek 2",
        "452-451": "mid left cheek 1",
        "451-151": "top left cheek 7",
        "151-321": "top left cheek 6",
        "321-434": "top left cheek 5",
        "434-318": "top left cheek 4",
        "318-145": "top left cheek 3",
        "145-133": "top left cheek 2",
        "133-160": "top left cheek 1",
        "160-371": "nose left 4",
        "371-367": "nose left 3",
        "367-387": "nose left 2",
        "387-14": "nose left 1",
        // Add descriptions for your pairs
    ]
}
