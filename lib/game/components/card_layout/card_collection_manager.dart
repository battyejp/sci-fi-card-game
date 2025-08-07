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
  
  /// Removes a card from the collection
  void removeCard(GameCard card) {
    _cards.remove(card);
    // Clear selection if this card was selected
    if (_selectionManager.selectedCard == card) {
      _selectionManager.clearSelection();
    }
  }
  
  /// Clears all cards
  void clearAllCards() {
    for (final card in _cards) {
      card.removeFromParent();
    }
    _cards.clear();
  }
  
  /// Gets the index of a specific card
  int indexOf(GameCard card) {
    return _cards.indexOf(card);
  }
}
