import 'package:flame/components.dart';
import 'card.dart';
import '../data/game_constants.dart';
import 'card_layout/fan_layout_calculator.dart';
import 'card_layout/card_selection_manager.dart';
import 'card_layout/card_collection_manager.dart';
import 'card_layout/card_deck_animator.dart';

class CardDeck extends Component with HasGameReference {
  late FanLayoutCalculator _layoutCalculator;
  late CardSelectionManager _selectionManager;
  late CardCollectionManager _collectionManager;
  late CardDeckAnimator _animator;
  
  int _currentCardCount = GameConstants.cardCount;
  
  @override
  Future<void> onLoad() async {
    _initializeManagers();
    _createFannedHand(_currentCardCount);
  }
  
  void _initializeManagers() {
    _layoutCalculator = FanLayoutCalculator();
    _selectionManager = CardSelectionManager();
    _collectionManager = CardCollectionManager(_selectionManager);
    _animator = CardDeckAnimator(_layoutCalculator);
  }
  
  void _createFannedHand(int cardCount) {
    // Clear existing cards
    _collectionManager.clearAllCards();
    
    // Get layout parameters
    final layoutParams = _calculateLayoutParameters(cardCount);
    
    // Create cards with fanned positioning
    for (int i = 0; i < cardCount; i++) {
      final card = GameCard();
      
      // Calculate position and rotation for this card
      final position = _layoutCalculator.calculateCardPosition(
        cardIndex: i,
        totalCards: cardCount,
        centerX: layoutParams.fanCenter.x,
        centerY: layoutParams.fanCenter.y,
        radius: layoutParams.adjustedRadius,
      );
      final rotation = _layoutCalculator.calculateCardRotation(
        cardIndex: i,
        totalCards: cardCount,
      );
      final priority = _layoutCalculator.calculateCardPriority(
        cardIndex: i,
        totalCards: cardCount,
      );
      
      // Set card properties
      card.setOriginalPosition(position);
      card.setRotation(rotation);
      card.priority = priority;
      
      _collectionManager.addCard(card);
      add(card);
    }
  }
  
  LayoutParameters _calculateLayoutParameters(int cardCount) {
    final gameSize = game.size;
    const cardWidth = GameConstants.handCardWidth;
    const bottomMargin = GameConstants.deckBottomMargin;
    const fanCenterOffset = GameConstants.fanCenterOffset;
    const safeAreaPadding = GameConstants.safeAreaPadding;
    
    final fanCenter = _layoutCalculator.calculateFanCenter(
      gameWidth: gameSize.x,
      gameHeight: gameSize.y,
      bottomMargin: bottomMargin,
      fanCenterOffset: fanCenterOffset,
    );
    
    final adjustedRadius = _layoutCalculator.calculateAdjustedRadius(
      cardCount: cardCount,
      gameWidth: gameSize.x,
      safeAreaPadding: safeAreaPadding,
      cardWidth: cardWidth,
      baseRadius: GameConstants.fanRadius,
    );
    
    return LayoutParameters(fanCenter: fanCenter, adjustedRadius: adjustedRadius);
  }
  
  // Method to update the number of cards in hand with smooth transition
  void updateCardCount(int newCardCount) {
    if (newCardCount != _currentCardCount) {
      _currentCardCount = newCardCount;
      GameConstants.setCardCount(newCardCount);
      _animateToNewLayout();
    }
  }
  
  void _animateToNewLayout() {
    final layoutParams = _calculateLayoutParameters(_currentCardCount);
    
    // If we have more cards than before, add new ones
    if (_currentCardCount > _collectionManager.cardCount) {
      final newCards = <GameCard>[];
      for (int i = _collectionManager.cardCount; i < _currentCardCount; i++) {
        final card = GameCard();
        newCards.add(card);
        add(card);
      }
      
      _collectionManager.addCards(newCards);
      _animator.animateCardsIn(
        newCards: newCards,
        fanCenter: layoutParams.fanCenter,
        adjustedRadius: layoutParams.adjustedRadius,
        startIndex: _collectionManager.cardCount - newCards.length,
        totalCards: _currentCardCount,
      );
    }
    // If we have fewer cards, remove excess ones with animation
    else if (_currentCardCount < _collectionManager.cardCount) {
      final cardsToRemove = _collectionManager.removeCardsFromIndex(_currentCardCount);
      _animator.animateCardsOut(
        cardsToRemove: cardsToRemove,
        onComplete: () {}, // Cards are already removed from collection
      );
    }
    
    // Animate remaining cards to new positions
    _animator.animateToNewLayout(
      cards: _collectionManager.cards,
      targetCardCount: _currentCardCount,
      fanCenter: layoutParams.fanCenter,
      adjustedRadius: layoutParams.adjustedRadius,
    );
  }
  
  // Method to reset all cards to their original positions
  void resetAllCards() {
    _selectionManager.clearSelection();
    _createFannedHand(_currentCardCount);
  }
  
  // Method to get the original priority for a card
  int getCardPriority(GameCard card) {
    final index = _collectionManager.indexOf(card);
    if (index == -1) return 0;
    
    return _layoutCalculator.calculateCardPriority(
      cardIndex: index,
      totalCards: _currentCardCount,
    );
  }
  
  // Method to get card at specific index
  GameCard? getCardAt(int index) => _collectionManager.getCardAt(index);
  
  // Method to get all cards
  List<GameCard> getAllCards() => _collectionManager.cards;
  
  // Getter for current card count
  int get cardCount => _currentCardCount;
  
  // Getter for currently selected card
  GameCard? get selectedCard => _selectionManager.selectedCard;
}

/// Helper class to hold layout calculation results
class LayoutParameters {
  final Vector2 fanCenter;
  final double adjustedRadius;
  
  LayoutParameters({
    required this.fanCenter,
    required this.adjustedRadius,
  });
}
