import '../card.dart';
import 'card_selection_manager.dart';

/// Manages the collection of cards in the deck
class CardCollectionManager {
  final List<GameCard> _cards = [];
  final CardSelectionManager _selectionManager;
  
  CardCollectionManager(this._selectionManager);
  
  /// Gets an unmodifiable view of all cards
  List<GameCard> get cards => List.unmodifiable(_cards);
  
  /// Gets the current number of cards
  int get cardCount => _cards.length;
  
  /// Adds a card to the collection
  void addCard(GameCard card) {
    // Set the selection change callback
    card.onSelectionChanged = _selectionManager.onCardSelectionChanged;
    _cards.add(card);
  }
  
  /// Removes cards from the specified index to the end
  List<GameCard> removeCardsFromIndex(int fromIndex) {
    if (fromIndex >= _cards.length) return [];
    
    final cardsToRemove = _cards.skip(fromIndex).toList();
    _cards.removeRange(fromIndex, _cards.length);
    return cardsToRemove;
  }
  
  /// Clears all cards
  void clearAllCards() {
    for (final card in _cards) {
      card.removeFromParent();
    }
    _cards.clear();
  }
  
  /// Gets a card at the specified index
  GameCard? getCardAt(int index) {
    if (index >= 0 && index < _cards.length) {
      return _cards[index];
    }
    return null;
  }
  
  /// Checks if the collection contains a specific card
  bool containsCard(GameCard card) {
    return _cards.contains(card);
  }
  
  /// Gets the index of a specific card
  int indexOf(GameCard card) {
    return _cards.indexOf(card);
  }
  
  /// Adds multiple cards to the collection
  void addCards(List<GameCard> newCards) {
    for (final card in newCards) {
      addCard(card);
    }
  }
}
