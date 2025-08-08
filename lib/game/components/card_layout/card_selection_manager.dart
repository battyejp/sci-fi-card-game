import '../card.dart';

abstract class ICardSelectionManager {
  GameCard? get selectedCard;
  void onCardSelectionChanged(GameCard card);
  void clearSelection();
  bool isCardSelected(GameCard card);
  bool get hasSelection;
}

/// Manages card selection state and handles selection changes
class CardSelectionManager implements ICardSelectionManager {
  GameCard? _selectedCard;

  /// Gets the currently selected card
  @override
  GameCard? get selectedCard => _selectedCard;

  /// Handles when a card's selection state changes
  @override
  void onCardSelectionChanged(GameCard card) {
    // If another card is already selected, deselect it
    if (_selectedCard != null && _selectedCard != card) {
      _selectedCard!.forceDeselect();
    }

    // Update the currently selected card
    _selectedCard = card.isSelected ? card : null;
  }

  /// Clears the current selection
  @override
  void clearSelection() {
    if (_selectedCard != null) {
      _selectedCard!.forceDeselect();
      _selectedCard = null;
    }
  }

  /// Checks if a specific card is selected
  @override
  bool isCardSelected(GameCard card) {
    return _selectedCard == card;
  }

  /// Checks if any card is selected
  @override
  bool get hasSelection => _selectedCard != null;
}
