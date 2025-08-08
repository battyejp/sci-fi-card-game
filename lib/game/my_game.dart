import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'dart:ui';
import 'deck/card_hand.dart';
import 'data/game_constants.dart';

class MyGame extends FlameGame with HasGameReference {
  late CardHand cardHand;
  
  @override
  Future<void> onLoad() async {
    // Get actual screen size for responsive design
    final screenSize = size;
    
    // Add a simple background color that fills the screen
    add(RectangleComponent(
      size: screenSize,
      paint: Paint()..color = GameConstants.backgroundColor,
    ));

  // Add the card hand at the bottom
  cardHand = CardHand();
  add(cardHand);
  }
  
  // Method to reset the game state
  void resetGame() {
  cardHand.resetAllCards();
  }
  
  // Getter for card hand
  CardHand get hand => cardHand;
}
