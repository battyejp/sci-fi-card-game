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

    // Add instructions text - positioned responsively
    add(TextComponent(
      text: 'Hover or tap cards below to highlight them',
      position: Vector2(screenSize.x / 2, screenSize.y * 0.4), // 40% from top
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: GameConstants.instructionFontSize.sp,
          color: GameConstants.instructionTextColor,
        ),
      ),
    ));

    // Add the card deck at the bottom
    cardDeck = CardDeck();
    add(cardDeck);
  }
  
  // Method to reset the game state
  void resetGame() {
    cardDeck.resetAllCards();
  }
  
  // Getter for card deck
  CardDeck get deck => cardDeck;
}
