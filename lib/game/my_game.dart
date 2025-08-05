import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'components/card_deck.dart';
import 'data/game_constants.dart';

class MyGame extends FlameGame with HasGameReference {
  late CardDeck cardDeck;
  
  @override
  Future<void> onLoad() async {
    // Get actual screen size for responsive design
    final screenSize = size;
    
    // Add a simple background color that fills the screen
    add(RectangleComponent(
      size: screenSize,
      paint: Paint()..color = GameConstants.backgroundColor,
    ));

    // Add the card deck at the bottom
    cardDeck = CardDeck();
    add(cardDeck);
  }
  
  // Method to reset the game state
  void resetGame() {
    cardDeck.resetAllCards();
  }
  
  // Method to update card count in hand
  void updateHandSize(int newCardCount) {
    cardDeck.updateCardCount(newCardCount);
  }
  
  // Demo method to cycle through different hand sizes
  void demoHandSizes() {
    // This could be called periodically to demonstrate the fanned layout
    final handSizes = [3, 5, 7, 4, 6, 5]; // Different hand sizes to demo
    int currentIndex = 0;
    
    // You could implement a timer or trigger to cycle through these
    // For now, this serves as documentation of the capability
  }
  
  // Getter for card deck
  CardDeck get deck => cardDeck;
}
