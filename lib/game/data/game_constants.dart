import 'package:flutter/material.dart';
import 'dart:math' as math;

class GameConstants {
  // Hand card dimensions (smaller for fanned layout)
  static const double handCardWidth = 90.0; 
  static const double handCardHeight = 135.0;
  
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
  static int cardCount = 0; // Start with empty hand
  /// The number of cards to deal when clicking the deck.
  static const int dealCardCount = 5;
  /// The initial number of cards in the deck pile.
  static const int deckPileCount = 20;
  /// Margin from the bottom of the screen to the bottom of the card fan.
  static const double deckBottomMargin = 0.0;
  
  // Deck pile positioning (left side)
  static const double deckPileLeftMargin = 60.0;
  static const double deckPileBottomMargin = 100.0;
  static const double deckPileCardOffset = 2.0; // Slight offset for stacked effect
  
  // Animation durations
  static const double cardAnimationDuration = 0.2;
  
  // Game dimensions - Mobile landscape optimized
  static const double gameWidth = 932.0;  // Width for landscape
  static const double gameHeight = 430.0; // Height for landscape
  
  // Safe area considerations for mobile
  static const double safeAreaPadding = 40.0; // For notches, nav bars, etc.
  
  // Colors
  static const Color backgroundColor = Color(0xFF1A1A2E);
  
  // Method to update card count
  static void setCardCount(int newCount) {
    cardCount = math.max(1, math.min(newCount, 10)); // Limit between 1 and 10 cards
  }
  
  // Helper method to convert degrees to radians
  static double degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }
}
