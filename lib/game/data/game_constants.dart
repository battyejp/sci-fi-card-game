import 'package:flutter/material.dart';

class GameConstants {
  // Card dimensions - Optimized for mobile touch
  static const double cardWidth = 80.0;   // Slightly larger for mobile
  static const double cardHeight = 120.0; // Proportionally larger
  static const double cardScale = 1.0;
  static const double highlightScale = 1.3; // Slightly reduced for mobile
  
  // Deck constants - Mobile optimized
  static const int cardCount = 5;
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
}
