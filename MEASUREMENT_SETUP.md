# Setting Up Your Facial Measurements

This guide will help you configure the specific facial landmark measurement pairs for your mask fitting research.

## Understanding ARKit Facial Landmarks

ARKit provides 3D facial landmarks as vertices in a face geometry mesh. Each landmark has an index (0 to vertexCount-1) and a 3D position.

## How to Find Your Landmark Indices

### Method 1: Debug Visualization
1. Add this code to `FaceMeasurementViewController.swift` in the `renderer(_:didUpdate:for:)` method:

```swift
// Add this after faceGeometry.update(from: faceAnchor.geometry)
if isMeasuring {
    // Debug: Print landmark positions
    for i in 0..<min(faceAnchor.geometry.vertexCount, 50) { // Print first 50 landmarks
        let vertex = faceAnchor.geometry.vertices[i]
        print("Landmark \(i): x=\(vertex.x), y=\(vertex.y), z=\(vertex.z)")
    }
}
```

2. Run the app and check the console output
3. Identify landmarks by their relative positions

### Method 2: Visual Inspection
1. Use the face geometry visualization in the app
2. Note the approximate positions of landmarks you're interested in
3. Cross-reference with the debug output

## Common Facial Landmark Areas

Based on typical face geometry, here are approximate landmark regions:

- **Nose Bridge**: Usually around indices 10-20
- **Eye Corners**: Typically indices 30-50
- **Cheekbones**: Often indices 100-200
- **Chin**: Usually higher indices (500+)
- **Forehead**: Lower indices (0-100)

*Note: These are rough estimates. Actual indices vary by face shape and ARKit version.*

## Configuring Your Measurements

### Step 1: Update FacialMeasurementPairs
Edit `BreatheSafe/Models/FacialLandmarks.swift`:

```swift
struct FacialMeasurementPairs {
    static let commonPairs: [(Int, Int)] = [
        // Replace these with your actual landmark indices
        (14, 818),  // Example: bridge of nose to chin
        (1, 2),     // Example: left eye corner to right eye corner
        (3, 4),     // Example: left cheek to right cheek
        // Add your specific pairs here
    ]
    
    static let pairDescriptions: [String: String] = [
        "14-818": "Bridge of nose to chin",
        "1-2": "Eye corner to eye corner", 
        "3-4": "Cheek to cheek",
        // Add descriptions for your pairs
    ]
}
```

### Step 2: Test Your Measurements
1. Run the app with your new measurement pairs
2. Check that measurements appear in the UI
3. Verify the values make sense (not zero or extremely large)

### Step 3: Validate with Known Faces
1. Test with faces of known dimensions
2. Compare measurements to manual measurements
3. Adjust landmark indices if needed

## Example Measurement Setup

Here's an example for common mask fitting measurements:

```swift
struct FacialMeasurementPairs {
    static let commonPairs: [(Int, Int)] = [
        // Face width (cheek to cheek)
        (leftCheekIndex, rightCheekIndex),
        
        // Face height (forehead to chin)
        (foreheadIndex, chinIndex),
        
        // Nose bridge width
        (leftNoseIndex, rightNoseIndex),
        
        // Eye distance
        (leftEyeIndex, rightEyeIndex),
        
        // Add more as needed
    ]
    
    static let pairDescriptions: [String: String] = [
        "\(leftCheekIndex)-\(rightCheekIndex)": "Face width (cheek to cheek)",
        "\(foreheadIndex)-\(chinIndex)": "Face height (forehead to chin)",
        "\(leftNoseIndex)-\(rightNoseIndex)": "Nose bridge width",
        "\(leftEyeIndex)-\(rightEyeIndex)": "Eye distance",
        // Add descriptions
    ]
}
```

## Tips for Accurate Measurements

1. **Multiple Samples**: The app collects 30 measurements by default for averaging
2. **Steady Positioning**: Keep face steady during measurement
3. **Good Lighting**: Ensure adequate lighting for ARKit
4. **Clean Face**: Remove glasses, hats, or facial hair that might interfere

## Troubleshooting Measurements

### Issue: Measurements are zero
- Check that landmark indices are valid (0 to vertexCount-1)
- Verify landmarks are being detected

### Issue: Measurements seem wrong
- Double-check landmark indices
- Test with different face positions
- Compare with manual measurements

### Issue: No measurements appearing
- Check console for errors
- Verify ARKit is detecting faces
- Ensure measurement pairs are properly configured

## Next Steps

1. Configure your specific measurement pairs
2. Test with your target user group
3. Integrate with your mask database
4. Set up your webapp server endpoint
5. Conduct user studies to validate measurements

## Support

If you need help finding specific landmark indices or configuring measurements, consider:
1. Using ARKit's face geometry visualization
2. Consulting ARKit documentation
3. Testing with known facial measurements
4. Reaching out to the iOS development community