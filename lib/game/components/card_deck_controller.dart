import 'package:flame/components.dart';

import '../data/game_constants.dart';
import 'card.dart';
import 'card_layout/fan_layout_calculator.dart';
import 'card_layout/layout_strategy.dart';
import 'card_layout/card_selection_manager.dart';
import 'card_layout/card_collection_manager.dart';

/// Controller encapsulating layout, selection, and collection logic for CardDeck.
typedef GameCardFactory = GameCard Function();

class CardDeckController {
  CardDeckController({
    CardLayoutStrategy? layoutStrategy,
    ICardSelectionManager? selectionManager,
    ICardCollectionManager? collectionManager,
    GameCardFactory? cardFactory,
    int? initialCardCount,
  })  : _layoutStrategy = layoutStrategy ?? FanLayoutCalculator(),
        _selectionManager = selectionManager ?? CardSelectionManager(),
        _collectionManager = collectionManager ??
            CardCollectionManager(selectionManager is CardSelectionManager
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

  Future<void> buildDeck(Component deckComponent, Vector2 gameSize) async {
    _createFannedHand(deckComponent, _currentCardCount, gameSize);
  }

  void setCardCount(int newCount, Component deckComponent, Vector2 gameSize) {
    _currentCardCount = newCount;
    _createFannedHand(deckComponent, _currentCardCount, gameSize);
  }

  void resetAllCards(Component deckComponent, Vector2 gameSize) {
    _selectionManager.clearSelection();
    _createFannedHand(deckComponent, _currentCardCount, gameSize);
  }

  int getCardPriority(GameCard card) {
    final index = _collectionManager.indexOf(card);
    if (index == -1) return 0;
    return _layoutStrategy.calculateCardPriority(
      cardIndex: index,
      totalCards: _currentCardCount,
    );
  }

  void _createFannedHand(
      Component deckComponent, int cardCount, Vector2 gameSize) {
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
      deckComponent.add(card);
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
