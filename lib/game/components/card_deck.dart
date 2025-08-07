import 'package:flame/components.dart';
import 'card.dart';
import '../data/game_constants.dart';
import 'card_layout/fan_layout_calculator.dart';
import 'card_layout/card_selection_manager.dart';
import 'card_layout/card_collection_manager.dart';

class CardDeck extends Component with HasGameReference {
  late FanLayoutCalculator _layoutCalculator;
  late CardSelectionManager _selectionManager;
  late CardCollectionManager _collectionManager;
  
  final int _currentCardCount = GameConstants.cardCount;
  
  @override
  Future<void> onLoad() async {
    _initializeManagers();
    _createFannedHand(_currentCardCount);
  }
  
  void _initializeManagers() {
    _layoutCalculator = FanLayoutCalculator();
    _selectionManager = CardSelectionManager();
    _collectionManager = CardCollectionManager(_selectionManager);
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
      
      // Set callback for when card is played to area
      card.onCardPlayedToArea = _onCardPlayedToArea;
      
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
  
  // Handle when a card is played to the area
  void _onCardPlayedToArea(GameCard card) {
    _collectionManager.removeCard(card);
    // Optionally, could reorganize remaining cards here
    // For now, we'll leave the remaining cards in their positions
  }
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
