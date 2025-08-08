import 'package:flame/components.dart';
import '../../card/card.dart';
import 'card_selection_manager.dart';

abstract class ICardCollectionManager<T extends Component> {
  List<T> get cards;
  int get cardCount;
  void addCard(T card);
  void clearAllCards();
  int indexOf(T card);
}

class CardCollectionManager implements ICardCollectionManager<GameCard> {
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

class DeckCardCollectionManager implements ICardCollectionManager<Component> {
  final List<Component> _cards = [];
  
  @override
  List<Component> get cards => List.unmodifiable(_cards);
  @override
  int get cardCount => _cards.length;
  @override
  void addCard(Component card) {
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
  int indexOf(Component card) => _cards.indexOf(card);
}
