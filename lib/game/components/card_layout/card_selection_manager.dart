import '../card.dart';

/// Manages card selection state and handles selection changes
class CardSelectionManager {
  GameCard? _selectedCard;
  
  /// Gets the currently selected card
  GameCard? get selectedCard => _selectedCard;
  
  /// Handles when a card's selection state changes
  void onCardSelectionChanged(GameCard card) {
    // If another card is already selected, deselect it
    if (_selectedCard != null && _selectedCard != card) {
      _selectedCard!.forceDeselect();
    }
    
    // Update the currently selected card
    _selectedCard = card.isSelected ? card : null;
  }
  
  /// Clears the current selection
  void clearSelection() {
    if (_selectedCard != null) {
      _selectedCard!.forceDeselect();
      _selectedCard = null;
    }
  }
  
  /// Checks if a specific card is selected
  bool isCardSelected(GameCard card) {
    return _selectedCard == card;
  }
  
  /// Checks if any card is selected
  bool get hasSelection => _selectedCard != null;
}
