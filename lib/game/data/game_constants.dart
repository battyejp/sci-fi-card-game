import 'package:flutter/material.dart';
import 'dart:math' as math;

class GameConstants {
  // Hand card dimensions (smaller for fanned layout)
  static const double handCardWidth = 90.0; 
  static const double handCardHeight = 135.0;
  
  // Enlarged card dimensions (when selected and centered)
  static const double enlargedCardWidth = 180.0;
  static const double enlargedCardHeight = 270.0;
  
  // Fan layout constants
  /// The maximum rotation (in degrees) for the outermost cards in the fan. Lower values = flatter fan.
  static const double maxFanRotation = 30.0;
  /// The radius of the fan arc. Higher values spread the cards out more horizontally.
  static const double fanRadius = 400.0;
  /// The amount of horizontal overlap between cards. Lower values = more of each card is visible.
  static const double cardOverlap = 10.0;
  /// Vertical offset from the bottom of the screen to the center of the fan.
  static const double fanCenterOffset = 50.0;
  
  // Deck constants - Mobile optimized
  /// The number of cards in the hand (can be changed dynamically).
  static int cardCount = 7;
  /// Margin from the bottom of the screen to the bottom of the card fan.
  static const double deckBottomMargin = 0.0;
  
  // Animation durations
  static const double cardAnimationDuration = 0.2;
  static const double playAreaHighlightDuration = 0.15;
  
  // Drag and drop constants
  static const double dragThreshold = 10.0; // Minimum movement to start drag
  static const double dragCardScale = 0.7; // Scale factor for dragged card
  static const double dragCardOpacity = 0.8; // Opacity for dragged card
  
  // Play area constants
  static const double playAreaWidth = 200.0;
  static const double playAreaHeight = 120.0;
  static const double playAreaCornerRadius = 15.0;
  
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
