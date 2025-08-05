# Mobile Landscape Deployment Guide

This guide covers the mobile-specific optimizations and configurations for deploying your sci-fi card game to mobile devices in landscape mode.

## Key Mobile Optimizations Made

### 1. **Orientation Lock**
- Forces landscape orientation on app startup
- Hides status bar for immersive gaming experience
- Uses `SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky)`

### 2. **Responsive Design System**
- Dynamic screen size detection and adaptation
- Responsive card sizing based on screen width
- Safe area handling for notches and navigation bars
- Automatic spacing adjustment for different screen sizes

### 3. **Mobile-Optimized Dimensions**
```dart
// Updated card dimensions for better mobile touch
static const double cardWidth = 80.0;   // Larger for easier touch
static const double cardHeight = 120.0; // Proportionally larger
static const double cardSpacing = 60.0; // More spacing for touch targets
static const double highlightScale = 1.3; // Reduced to prevent overflow
```

### 4. **Touch-Friendly Interface**
- Larger touch targets (minimum 44px as per mobile guidelines)
- Increased card spacing for easier selection
- Overlay back button instead of app bar for full-screen gaming
- Semi-transparent UI elements that don't obstruct gameplay

## Common Mobile Landscape Resolutions Supported

| Device | Resolution | Aspect Ratio |
|--------|------------|--------------|
| iPhone 14 Pro | 932 × 430 | ~2.17:1 |
| iPhone 13/12 | 844 × 390 | ~2.16:1 |
| Samsung Galaxy S21 | 800 × 360 | ~2.22:1 |
| Google Pixel 6 | 840 × 384 | ~2.19:1 |
| Standard 16:9 | 854 × 480 | 16:9 |

## Deployment Steps

### Android Deployment

1. **Configure Android Manifest** (`android/app/src/main/AndroidManifest.xml`):
```xml
<activity
    android:name=".MainActivity"
    android:screenOrientation="sensorLandscape"
    android:launchMode="singleTop"
    android:theme="@style/LaunchTheme"
    android:hardwareAccelerated="true">
```

2. **Build Release APK**:
```bash
flutter build apk --release
```

3. **Build App Bundle** (for Google Play):
```bash
flutter build appbundle --release
```

### iOS Deployment

1. **Configure Info.plist** (`ios/Runner/Info.plist`):
```xml
<key>UISupportedInterfaceOrientations</key>
<array>
    <string>UIInterfaceOrientationLandscapeLeft</string>
    <string>UIInterfaceOrientationLandscapeRight</string>
</array>
```

2. **Build for iOS**:
```bash
flutter build ios --release
```

## Performance Optimizations for Mobile

### 1. **Memory Management**
- Limit concurrent animations (max 3)
- Disable shadows for better performance
- Use sprite batching for cards
- Implement object pooling for frequently created/destroyed objects

### 2. **Battery Optimization**
- Reduce animation frame rates when not in focus
- Pause game loops when app is backgrounded
- Use efficient image formats (WebP for Android, optimized PNG for iOS)

### 3. **Loading Optimization**
- Preload all card sprites during loading screen
- Use compressed textures
- Implement progressive loading for large assets

## Testing on Different Devices

### Screen Size Testing
```dart
// Test different resolutions in your main.dart
const testResolutions = [
  Size(932, 430), // iPhone 14 Pro
  Size(844, 390), // iPhone 13
  Size(800, 360), // Samsung S21
  Size(720, 320), // Minimum supported
];
```

### Performance Testing
- Test on older devices (3+ years old)
- Monitor frame rates using Flutter Inspector
- Test battery usage during extended play sessions
- Verify touch responsiveness on different screen sizes

## Distribution Checklist

### App Store (iOS)
- [ ] Configure landscape orientation in Xcode
- [ ] Test on multiple iPhone models
- [ ] Optimize app size (< 150MB recommended)
- [ ] Add App Store screenshots in landscape
- [ ] Test on iPad (if supporting)

### Google Play (Android)
- [ ] Test on multiple Android devices
- [ ] Optimize APK/AAB size
- [ ] Configure proper permissions
- [ ] Test on different Android versions (API 21+)
- [ ] Add Play Store screenshots in landscape

## Future Mobile Enhancements

1. **Haptic Feedback**: Add vibration for card interactions
2. **Gesture Controls**: Swipe gestures for card management
3. **Adaptive UI**: Dynamic layout based on screen size
4. **Accessibility**: Voice over support, larger text options
5. **Offline Mode**: Local storage for game progress
6. **Push Notifications**: Daily challenges, game updates

## Troubleshooting Common Issues

### Layout Issues
- Cards appear too small: Adjust `cardWidth` in `GameConstants`
- Cards overflow screen: Reduce `cardSpacing` or implement dynamic spacing
- UI elements cut off: Check safe area handling

### Performance Issues
- Laggy animations: Reduce `highlightScale` or animation duration
- Memory leaks: Implement proper disposal in game components
- Battery drain: Reduce animation frequency and effects

### Orientation Issues
- App rotates unexpectedly: Verify orientation lock in native configuration
- Safe area problems: Test on devices with notches/navigation bars
