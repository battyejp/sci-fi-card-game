import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import '../data/game_constants.dart';
import '../card/card.dart';
import 'layout/fan_layout_calculator.dart';
import 'layout/layout_strategy.dart';
import 'layout/card_selection_manager.dart';
import 'layout/card_collection_manager.dart';

typedef GameCardFactory = GameCard Function();

/// Controller encapsulating layout, selection, and collection logic for CardHand.
class CardHandController {
  CardHandController({
    CardLayoutStrategy? layoutStrategy,
    ICardSelectionManager? selectionManager,
    ICardCollectionManager? collectionManager,
    GameCardFactory? cardFactory,
    int? initialCardCount,
  })  : _layoutStrategy = layoutStrategy ?? FanLayoutCalculator(),
        _selectionManager = selectionManager ?? CardSelectionManager(),
        _collectionManager = collectionManager ?? CardCollectionManager(
            selectionManager is CardSelectionManager
                ? selectionManager
                : CardSelectionManager()),
        _cardFactory = cardFactory ?? (() => GameCard()),
        _currentCardCount = initialCardCount ?? GameConstants.cardCount;

  final CardLayoutStrategy _layoutStrategy;
  final ICardSelectionManager _selectionManager;
  final ICardCollectionManager _collectionManager;
  final GameCardFactory _cardFactory;
  int _currentCardCount;

  int get cardCount => _currentCardCount;
  List<GameCard> get cards => _collectionManager.cards;
  GameCard? get selectedCard => _selectionManager.selectedCard;

  Future<void> buildHand(Component handComponent, Vector2 gameSize) async {
    // Start with an empty hand - don't create any cards initially
    _collectionManager.clearAllCards();
  }

  void setCardCount(int newCount, Component handComponent, Vector2 gameSize) {
    _currentCardCount = newCount;
    _createFannedHand(handComponent, _currentCardCount, gameSize);
  }

  void resetAllCards(Component handComponent, Vector2 gameSize) {
    _selectionManager.clearSelection();
    _collectionManager.clearAllCards();
    // Don't create cards immediately - wait for dealing
  }

  // New method to add a single card to the hand with animation
  Future<void> addCardToHand(Component handComponent, Vector2 gameSize, Vector2 startPosition) async {
    final currentCardCount = _collectionManager.cards.length;
    final newCardIndex = currentCardCount;
    final targetCardCount = currentCardCount + 1;
    
    // Create the new card
    final card = _cardFactory();
    
    // Calculate its target position in the fan
    final params = _calculateLayoutParameters(targetCardCount, gameSize);
    final targetPosition = _layoutStrategy.calculateCardPosition(
      cardIndex: newCardIndex,
      totalCards: targetCardCount,
      centerX: params.fanCenter.x,
      centerY: params.fanCenter.y,
      radius: params.adjustedRadius,
    );
    final targetRotation = _layoutStrategy.calculateCardRotation(
      cardIndex: newCardIndex,
      totalCards: targetCardCount,
    );
    final priority = _layoutStrategy.calculateCardPriority(
      cardIndex: newCardIndex,
      totalCards: targetCardCount,
    );

    // Start the card at the pile position
    card.setOriginalPosition(startPosition);
    card.setRotation(0.0);
    card.priority = priority;

    // Add to collection and component
    _collectionManager.addCard(card);
    handComponent.add(card);

    // Animate to target position
    await _animateCardToPosition(card, targetPosition, targetRotation);
    
    // Update all existing cards to their new positions in the expanded fan
    await _updateExistingCardPositions(handComponent, gameSize);
  }

  Future<void> _animateCardToPosition(GameCard card, Vector2 targetPosition, double targetRotation) async {
    // Use Flame's MoveEffect and RotateEffect for smooth animation
    final moveEffect = MoveToEffect(
      targetPosition,
      EffectController(duration: GameConstants.cardAnimationDuration),
    );
    
    final rotateEffect = RotateEffect.to(
      targetRotation,
      EffectController(duration: GameConstants.cardAnimationDuration),
    );
    
    // Apply both effects simultaneously
    card.add(moveEffect);
    card.add(rotateEffect);
    
    // Wait for the animation to complete
    await Future.delayed(Duration(milliseconds: (GameConstants.cardAnimationDuration * 1000).toInt()));
    
    // Update the card's original position after animation
    card.setOriginalPosition(targetPosition);
    card.setRotation(targetRotation);
  }

  Future<void> _updateExistingCardPositions(Component handComponent, Vector2 gameSize) async {
    final totalCards = _collectionManager.cards.length;
    final params = _calculateLayoutParameters(totalCards, gameSize);
    
    for (int i = 0; i < totalCards; i++) {
      final card = _collectionManager.cards[i];
      final position = _layoutStrategy.calculateCardPosition(
        cardIndex: i,
        totalCards: totalCards,
        centerX: params.fanCenter.x,
        centerY: params.fanCenter.y,
        radius: params.adjustedRadius,
      );
      final rotation = _layoutStrategy.calculateCardRotation(
        cardIndex: i,
        totalCards: totalCards,
      );
      final priority = _layoutStrategy.calculateCardPriority(
        cardIndex: i,
        totalCards: totalCards,
      );

      card.setOriginalPosition(position);
      card.setRotation(rotation);
      card.priority = priority;
    }
  }

  int getCardPriority(GameCard card) {
    final index = _collectionManager.indexOf(card);
    if (index == -1) return 0;
    return _layoutStrategy.calculateCardPriority(
      cardIndex: index,
      totalCards: _currentCardCount,
    );
  }

  void _createFannedHand(Component handComponent, int cardCount, Vector2 gameSize) {
    _collectionManager.clearAllCards();

    final params = _calculateLayoutParameters(cardCount, gameSize);

    for (int i = 0; i < cardCount; i++) {
      final card = _cardFactory();

      final position = _layoutStrategy.calculateCardPosition(
        cardIndex: i,
        totalCards: cardCount,
        centerX: params.fanCenter.x,
        centerY: params.fanCenter.y,
        radius: params.adjustedRadius,
      );
      final rotation = _layoutStrategy.calculateCardRotation(
        cardIndex: i,
        totalCards: cardCount,
      );
      final priority = _layoutStrategy.calculateCardPriority(
        cardIndex: i,
        totalCards: cardCount,
      );

      card.setOriginalPosition(position);
      card.setRotation(rotation);
      card.priority = priority;

      _collectionManager.addCard(card);
      handComponent.add(card);
    }
  }

  _LayoutParams _calculateLayoutParameters(int cardCount, Vector2 gameSize) {
    const cardWidth = GameConstants.handCardWidth;
    const bottomMargin = GameConstants.deckBottomMargin;
    const fanCenterOffset = GameConstants.fanCenterOffset;
    const safeAreaPadding = GameConstants.safeAreaPadding;

    final fanCenter = _layoutStrategy.calculateFanCenter(
      gameWidth: gameSize.x,
      gameHeight: gameSize.y,
      bottomMargin: bottomMargin,
      fanCenterOffset: fanCenterOffset,
    );

    final adjustedRadius = _layoutStrategy.calculateAdjustedRadius(
      cardCount: cardCount,
      gameWidth: gameSize.x,
      safeAreaPadding: safeAreaPadding,
      cardWidth: cardWidth,
      baseRadius: GameConstants.fanRadius,
    );

    return _LayoutParams(fanCenter: fanCenter, adjustedRadius: adjustedRadius);
  }
}

class _LayoutParams {
  final Vector2 fanCenter;
  final double adjustedRadius;
  _LayoutParams({required this.fanCenter, required this.adjustedRadius});
}
