import 'package:flame/components.dart';

import '../data/game_constants.dart';
import '../card/deck_card.dart';
import 'layout/pile_layout_calculator.dart';
import 'layout/layout_strategy.dart';
import 'layout/card_selection_manager.dart';
import 'layout/card_collection_manager.dart';

typedef DeckCardFactory = DeckCard Function();

/// Controller encapsulating layout, selection, and collection logic for CardDeck.
class CardDeckController {
  CardDeckController({
    CardLayoutStrategy? layoutStrategy,
    ICardSelectionManager? selectionManager,
    ICardCollectionManager<Component>? collectionManager,
    DeckCardFactory? cardFactory,
    int? initialCardCount,
    Function(DeckCard)? onCardTapped,
  })  : _layoutStrategy = layoutStrategy ?? PileLayoutCalculator(),
        _selectionManager = selectionManager ?? CardSelectionManager(),
        _collectionManager = collectionManager ?? DeckCardCollectionManager(),
        _cardFactory = cardFactory ?? (() => DeckCard()),
        _currentCardCount = initialCardCount ?? GameConstants.deckPileCount,
        onCardTapped = onCardTapped;

  final CardLayoutStrategy _layoutStrategy;
  final ICardSelectionManager _selectionManager;
  final ICardCollectionManager<Component> _collectionManager;
  final DeckCardFactory _cardFactory;
  Function(DeckCard)? onCardTapped;
  int _currentCardCount;

  int get cardCount => _currentCardCount;
  List<DeckCard> get cards => _collectionManager.cards.cast<DeckCard>();
  DeckCard? get selectedCard => _selectionManager.selectedCard as DeckCard?;

  Future<void> buildDeck(Component deckComponent, Vector2 gameSize) async {
    _createPileDeck(deckComponent, _currentCardCount, gameSize);
  }

  void setCardCount(int newCount, Component deckComponent, Vector2 gameSize) {
    _currentCardCount = newCount;
    _createPileDeck(deckComponent, _currentCardCount, gameSize);
  }

  void resetAllCards(Component deckComponent, Vector2 gameSize) {
    _selectionManager.clearSelection();
    _createPileDeck(deckComponent, _currentCardCount, gameSize);
  }

  int getCardPriority(DeckCard card) {
    final index = _collectionManager.indexOf(card);
    if (index == -1) return 0;
    return _layoutStrategy.calculateCardPriority(
      cardIndex: index,
      totalCards: _currentCardCount,
    );
  }

  bool dealCards(int count) {
    if (_currentCardCount < count) return false;
    _currentCardCount -= count;
    return true;
  }

  void _createPileDeck(Component deckComponent, int cardCount, Vector2 gameSize) {
    _collectionManager.clearAllCards();

    final params = _calculateLayoutParameters(cardCount, gameSize);

    for (int i = 0; i < cardCount; i++) {
      final card = _cardFactory();
      card.onTapped = onCardTapped;

      final position = _layoutStrategy.calculateCardPosition(
        cardIndex: i,
        totalCards: cardCount,
        centerX: params.pileCenter.x,
        centerY: params.pileCenter.y,
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

      card.position = position;
      card.angle = rotation;
      card.priority = priority;

      _collectionManager.addCard(card);
      deckComponent.add(card);
    }
  }

  _LayoutParams _calculateLayoutParameters(int cardCount, Vector2 gameSize) {
    final pileCenter = _layoutStrategy.calculateFanCenter(
      gameWidth: gameSize.x,
      gameHeight: gameSize.y,
      bottomMargin: GameConstants.deckBottomMargin,
      fanCenterOffset: GameConstants.fanCenterOffset,
    );

    return _LayoutParams(pileCenter: pileCenter, adjustedRadius: 0.0);
  }
}

class _LayoutParams {
  final Vector2 pileCenter;
  final double adjustedRadius;
  _LayoutParams({required this.pileCenter, required this.adjustedRadius});
}
