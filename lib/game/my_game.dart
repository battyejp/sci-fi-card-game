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
  
  // Getter for card deck
  CardDeck get deck => cardDeck;
}
