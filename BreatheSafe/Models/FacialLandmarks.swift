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
        (967, 464),
        (464, 456),
        (456, 451),
        (451, 455),
        (999, 1027),
        (1027, 884),
        (884, 883),
        (883,879),
        (1049, 983),
        (983, 982),
        (982, 1050),
        (1050, 1051),
        (1051, 1052),
        (1052, 1053),
        (1053, 509),
        (509, 893),
        (893, 894),
        (894, 881),
        (881, 880),
        (880, 879),
        (879, 600),
        (600, 756),
        (756, 862),
        (862, 753),
        (753, 594),
        (594, 582),
        (582, 609),
        (609, 802),
        (802, 798),
        (798, 14),
        (14, 818),
        (1049, 984),
        (984, 985),
        (985, 986),
        (986, 987),
        (987, 988),
        (988, 989),
        (989, 60),
        (60, 478),
        (478, 479),
        (479, 453),
        (453, 452),
        (452, 451),
        (451, 151),
        (151, 321),
        (321, 434),
        (434, 318),
        (318, 145),
        (145, 133),
        (133, 160),
        (160, 371),
        (371, 367),
        (367, 387),
        (387, 14),
        // Add your specific landmark pairs here once you find valid indices
    ]

    static let pairDescriptions: [String: String] = [
        "967-464": "left strap 4",
        "464-456": "left strap 3",
        "456-451": "left strap 2",
        "451-455": "left strap 1",
        "999-1027": "right strap 4",
        "1027-884": "right strap 3",
        "884-883": "right strap 2",
        "883-879": "right strap 1",
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
