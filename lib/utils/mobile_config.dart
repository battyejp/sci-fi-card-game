import 'package:flutter/material.dart';

class MobileConfig {
  // Common mobile landscape resolutions
  static const Map<String, Size> commonResolutions = {
    'iPhone_14_Pro': Size(932, 430),
    'iPhone_13': Size(844, 390),
    'iPhone_12': Size(844, 390),
    'Samsung_S21': Size(800, 360),
    'Pixel_6': Size(840, 384),
    'Standard_16_9': Size(854, 480),
  };
  
  // Minimum safe dimensions
  static const Size minSafeSize = Size(720, 320);
  
  // Check if device is in landscape
  static bool isLandscape(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return orientation == Orientation.landscape;
  }
  
  // Get safe area insets
  static EdgeInsets getSafeArea(BuildContext context) {
    return MediaQuery.of(context).padding;
  }
  
  // Calculate responsive card size based on screen width
  static double getResponsiveCardWidth(double screenWidth) {
    // Base card width is 80, but scale based on screen width
    const baseWidth = 80.0;
    final scaleFactor = screenWidth / 932.0; // Based on iPhone 14 Pro
    return (baseWidth * scaleFactor).clamp(60.0, 100.0);
  }
  
  // Calculate responsive card spacing
  static double getResponsiveCardSpacing(double screenWidth, int cardCount) {
    final availableWidth = screenWidth * 0.8; // Use 80% of screen width
    final cardWidth = getResponsiveCardWidth(screenWidth);
    final totalCardWidth = cardWidth * cardCount;
    final availableSpacing = availableWidth - totalCardWidth;
    return (availableSpacing / (cardCount - 1)).clamp(20.0, 80.0);
  }
  
  // Touch target minimum size for mobile
  static const double minTouchTarget = 44.0;
  
  // Performance settings for mobile
  static const bool enableParticles = true;
  static const bool enableShadows = false; // Disable for better performance
  static const int maxAnimations = 3; // Limit concurrent animations
}
