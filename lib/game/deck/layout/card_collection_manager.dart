import '../../card/card.dart';
import 'card_selection_manager.dart';

abstract class ICardCollectionManager {
  List<GameCard> get cards;
  int get cardCount;
  void addCard(GameCard card);
  void clearAllCards();
  int indexOf(GameCard card);
}

class CardCollectionManager implements ICardCollectionManager {
  final List<GameCard> _cards = [];
  final CardSelectionManager _selectionManager;
  CardCollectionManager(this._selectionManager);

  @override
  List<GameCard> get cards => List.unmodifiable(_cards);
  @override
  int get cardCount => _cards.length;
  @override
  void addCard(GameCard card) {
    card.onSelectionChanged = _selectionManager.onCardSelectionChanged;
    _cards.add(card);
  }
  @override
  void clearAllCards() {
    for (final card in _cards) {
      card.removeFromParent();
    }
    _cards.clear();
  }
  @override
  int indexOf(GameCard card) => _cards.indexOf(card);
}
