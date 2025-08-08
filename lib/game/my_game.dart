import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'dart:ui';
import 'deck/card_hand.dart';
import 'deck/card_pile.dart';
import 'data/game_constants.dart';

class MyGame extends FlameGame with HasGameReference {
  late CardHand cardHand;
  late CardPile cardPile;
  bool _isDealing = false;
  
  @override
  Future<void> onLoad() async {
    // Get actual screen size for responsive design
    final screenSize = size;
    
    // Add a simple background color that fills the screen
    add(RectangleComponent(
      size: screenSize,
      paint: Paint()..color = GameConstants.backgroundColor,
    ));

    // Add the card hand at the bottom (starts empty)
    cardHand = CardHand();
    add(cardHand);

    // Add the card pile on the right side
    cardPile = CardPile(onPileClicked: _dealCards);
    add(cardPile);
  }
  
  // Method to reset the game state
  void resetGame() {
    cardHand.resetAllCards();
    cardPile.reset();
    _isDealing = false;
  }
  
  // Handle dealing cards from pile to hand
  Future<void> _dealCards() async {
    if (_isDealing || !cardPile.hasCards) return;
    
    _isDealing = true;
    
    // Deal cards one by one
    final pilePosition = Vector2(
      size.x - GameConstants.handCardWidth / 2 - GameConstants.safeAreaPadding,
      size.y / 2,
    );
    
    for (int i = 0; i < GameConstants.cardsToDealt; i++) {
      await cardHand.addCardFromPosition(pilePosition);
      // Small delay between each card for visual effect
      await Future.delayed(Duration(milliseconds: (GameConstants.cardDealingDelay * 1000).toInt()));
    }
    
    // Remove cards from pile after dealing
    cardPile.removeCards(GameConstants.cardsToDealt);
    _isDealing = false;
  }
  
  // Getter for card hand
  CardHand get hand => cardHand;
}
