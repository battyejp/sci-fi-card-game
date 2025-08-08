import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'dart:ui';
import 'deck/card_hand.dart';
import 'deck/card_deck.dart';
import 'card/card.dart';
import 'card/deck_card.dart';
import 'data/game_constants.dart';
import 'core/card_dealing_animator.dart';

class MyGame extends FlameGame with HasGameReference {
  late CardHand cardHand;
  late CardDeck cardDeck;
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

    // Add the card deck on the left side
    cardDeck = CardDeck();
    cardDeck.controller.onCardTapped = _onDeckTapped;
    add(cardDeck);

    // Add the card hand at the bottom (starts empty)
    cardHand = CardHand();
    add(cardHand);
  }
  
  void _onDeckTapped(DeckCard deckCard) async {
    // Prevent multiple dealing operations
    if (_isDealing || cardDeck.cardCount < GameConstants.dealCardCount) return;
    
    _isDealing = true;
    
    // Deal cards when deck is clicked
    if (cardDeck.dealCards(GameConstants.dealCardCount)) {
      // Get deck position for animation
      final deckPosition = cardDeck.cards.isNotEmpty 
          ? cardDeck.cards.last.position 
          : Vector2(
              GameConstants.deckPileLeftMargin + (GameConstants.handCardWidth / 2),
              size.y - GameConstants.deckPileBottomMargin - (GameConstants.handCardHeight / 2),
            );
      
      // Animate dealing cards to hand
      await CardDealingAnimator.dealCardsWithAnimation(
        gameComponent: this,
        deckPosition: deckPosition,
        targetHand: cardHand,
        cardCount: GameConstants.dealCardCount,
      );
      
      // Update deck display to remove dealt cards
      _updateDeckDisplay();
    }
    
    _isDealing = false;
  }
  
  void _updateDeckDisplay() {
    // Rebuild deck with new card count
    cardDeck.resetAllCards();
  }
  
  // Method to reset the game state
  void resetGame() {
    if (_isDealing) return;
    cardHand.resetAllCards();
    cardDeck.resetAllCards();
  }
  
  // Getters
  CardHand get hand => cardHand;
  CardDeck get deck => cardDeck;
}
