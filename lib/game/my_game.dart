import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'components/card_deck.dart';
import 'components/play_area.dart';
import 'data/game_constants.dart';

class MyGame extends FlameGame with HasGameReference {
  late CardDeck cardDeck;
  late PlayArea playArea;
  
  @override
  Future<void> onLoad() async {
    // Get actual screen size for responsive design
    final screenSize = size;
    
    // Add a simple background color that fills the screen
    add(RectangleComponent(
      size: screenSize,
      paint: Paint()..color = GameConstants.backgroundColor,
    ));

    // Add the play area in the center
    playArea = PlayArea();
    add(playArea);

    // Add the card deck at the bottom
    cardDeck = CardDeck();
    // Pass the play area reference to the card deck for drag-drop interaction
    cardDeck.playArea = playArea;
    add(cardDeck);
  }
  
  // Method to reset the game state
  void resetGame() {
    cardDeck.resetAllCards();
  }
  
  // Getter for card deck
  CardDeck get deck => cardDeck;
}
