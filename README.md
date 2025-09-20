# BreatheSafe iOS - Facial Measurement for Mask Fitting

An iOS application that uses Apple's True Depth camera and ARKit to measure facial features for mask fitting recommendations.

## Features

- **Real-time Facial Landmark Detection**: Uses ARKit's face tracking to detect facial landmarks
- **Custom Measurement Pairs**: Calculate distances between specific facial landmark indices
- **Guided User Experience**: Step-by-step instructions for proper positioning
- **Data Export**: Multiple export options including JSON, CSV, and server integration
- **Privacy Controls**: User consent management for data sharing
- **Measurement History**: Collects multiple samples for accurate averaging

## Requirements

- iOS 11.0 or later
- iPhone with True Depth camera (iPhone X and newer)
- Xcode 12.0 or later
- Swift 5.0 or later

## Project Structure

```
BreatheSafe/
├── Controllers/
│   └── FaceMeasurementViewController.swift    # Main ARKit view controller
├── Models/
│   └── FacialLandmarks.swift                  # Facial landmark data models
├── Managers/
│   ├── MeasurementEngine.swift               # Measurement calculation engine
│   └── DataExportManager.swift               # Data export functionality
├── Views/
│   └── (Storyboard files)
├── Assets.xcassets/                           # App icons and colors
├── Info.plist                                # App configuration
└── Main.storyboard                           # Main UI layout
```

## Setup Instructions

### 1. Open the Project
1. Open `BreatheSafe.xcodeproj` in Xcode
2. Select your development team in the project settings
3. Update the bundle identifier if needed

### 2. Configure Measurement Pairs
Edit `FacialLandmarks.swift` to specify your facial landmark measurement pairs:

```swift
struct FacialMeasurementPairs {
    static let commonPairs: [(Int, Int)] = [
        (14, 818),  // Your specific landmark pairs
        (1, 2),     // Add more pairs as needed
        // ... more pairs
    ]
    
    static let pairDescriptions: [String: String] = [
        "14-818": "Bridge of nose to chin",
        "1-2": "Eye corner to eye corner",
        // ... descriptions for your pairs
    ]
}
```

### 3. Configure Server Integration (Optional)
In `FaceMeasurementViewController.swift`, update the server URL:

```swift
dataExportManager.setServerURL("https://your-webapp-server.com/api/measurements")
```

### 4. Build and Run
1. Connect an iPhone with True Depth camera
2. Build and run the project
3. Grant camera permissions when prompted

## Usage

### For Users
1. **Preparation**: Remove glasses, hats, or anything covering your face
2. **Positioning**: Hold iPhone close to face (less than 12 inches away) in portrait mode
3. **Measurement**: Tap "Start Measurement" and keep face steady
4. **Export**: Choose how to export your measurements

### For Developers
- **Custom Measurements**: Modify `FacialMeasurementPairs` to add your specific landmark indices
- **Data Format**: Measurements are exported as JSON with timestamps and statistics
- **Privacy**: Users can choose to keep data local or share with your server

## ARKit Integration

The app uses `ARFaceTrackingConfiguration` to:
- Detect facial landmarks in real-time
- Calculate 3D distances between landmarks
- Provide visual feedback during measurement
- Handle session interruptions gracefully

## Data Export Options

1. **System Share**: Share via Messages, Mail, etc.
2. **Local Files**: Save to device storage
3. **Server Upload**: Send to your webapp (with user consent)

## Privacy Considerations

- Camera access requires user permission
- Facial data is processed locally on device
- User consent required for server data sharing
- No personal information is collected

## Troubleshooting

### Common Issues
1. **"ARKit not supported"**: Ensure you're using an iPhone with True Depth camera
2. **Camera permission denied**: Check Settings > Privacy > Camera
3. **Poor measurements**: Ensure good lighting and proper positioning

### Debug Tips
- Check console for ARKit session errors
- Verify landmark indices are valid (0 to vertexCount-1)
- Test with different lighting conditions

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on multiple devices
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review ARKit documentation
3. Open an issue on GitHub

## Future Enhancements

- [ ] Multiple measurement sessions
- [ ] Measurement validation algorithms
- [ ] Integration with mask database
- [ ] Advanced visualization options
- [ ] Offline measurement storage