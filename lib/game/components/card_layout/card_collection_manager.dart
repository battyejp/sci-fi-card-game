import '../card.dart';
import 'card_selection_manager.dart';

abstract class ICardCollectionManager {
  List<GameCard> get cards;
  int get cardCount;
  void addCard(GameCard card);
  void clearAllCards();
  int indexOf(GameCard card);
}

/// Manages the collection of cards in the deck
class CardCollectionManager implements ICardCollectionManager {
  final List<GameCard> _cards = [];
  final CardSelectionManager _selectionManager;

  CardCollectionManager(this._selectionManager);

  /// Gets an unmodifiable view of all cards
  @override
  List<GameCard> get cards => List.unmodifiable(_cards);

  /// Gets the current number of cards
  @override
  int get cardCount => _cards.length;

  /// Adds a card to the collection
  @override
  void addCard(GameCard card) {
    // Set the selection change callback
    card.onSelectionChanged = _selectionManager.onCardSelectionChanged;
    _cards.add(card);
  }

  /// Clears all cards
  @override
  void clearAllCards() {
    for (final card in _cards) {
      card.removeFromParent();
    }
    _cards.clear();
  }

  /// Gets the index of a specific card
  @override
  int indexOf(GameCard card) {
    return _cards.indexOf(card);
  }
}
