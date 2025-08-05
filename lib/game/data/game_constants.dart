import 'package:flutter/material.dart';
import 'dart:math' as math;

class GameConstants {
  // Card dimensions - Optimized for mobile touch
  static const double cardWidth = 80.0;   // Slightly larger for mobile
  static const double cardHeight = 120.0; // Proportionally larger
  static const double cardScale = 1.0;
  static const double highlightScale = 1.3; // Slightly reduced for mobile
  
  // Hand card dimensions (smaller for fanned layout)
  static const double handCardWidth = 60.0;   // Smaller cards in hand
  static const double handCardHeight = 90.0;  // Proportionally smaller
  
  // Fan layout constants
  static const double maxFanRotation = 35.0; // Slightly reduced for better mobile view
  static const double fanRadius = 180.0;     // Reduced radius for mobile screens
  static const double cardOverlap = 30.0;    // Reduced overlap for mobile
  static const double fanCenterOffset = 50.0; // Slightly reduced offset
  
  // Deck constants - Mobile optimized
  static int cardCount = 5; // Made non-const to allow dynamic changes
  static const double cardSpacing = 60.0; // More spacing for touch targets
  static const double deckBottomMargin = 30.0; // More margin for safe areas
  
  // Animation durations
  static const double cardAnimationDuration = 0.2;
  
  // Game dimensions - Mobile landscape optimized
  // Common mobile landscape resolutions:
  // iPhone: 844x390, 926x428, 932x430
  // Android: varies widely, but typically 16:9 or 18:9 aspect ratio
  static const double gameWidth = 932.0;  // Width for landscape
  static const double gameHeight = 430.0; // Height for landscape
  
  // Alternative approach: Use aspect ratio based design
  static const double aspectRatio = 16.0 / 9.0; // Standard mobile landscape
  
  // Safe area considerations for mobile
  static const double safeAreaPadding = 40.0; // For notches, nav bars, etc.
  
  // Colors
  static const Color backgroundColor = Color(0xFF1A1A2E);
  static const Color instructionTextColor = Colors.grey;
  
  // UI Constants
  static const double instructionFontSize = 16.0;
  static const double titleFontSize = 32.0;
  static const double buttonFontSize = 18.0;
  static const double titleSpacing = 32.0;
  
  // Method to update card count
  static void setCardCount(int newCount) {
    cardCount = math.max(1, math.min(newCount, 10)); // Limit between 1 and 10 cards
  }
  
  // Helper method to convert degrees to radians
  static double degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }
}
