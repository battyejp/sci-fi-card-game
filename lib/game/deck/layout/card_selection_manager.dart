import '../../card/card.dart';

abstract class ICardSelectionManager {
  GameCard? get selectedCard;
  void onCardSelectionChanged(GameCard card);
  void clearSelection();
  bool isCardSelected(GameCard card);
  bool get hasSelection;
}

class CardSelectionManager implements ICardSelectionManager {
  GameCard? _selectedCard;
  @override
  GameCard? get selectedCard => _selectedCard;
  @override
  void onCardSelectionChanged(GameCard card) {
    if (_selectedCard != null && _selectedCard != card) {
      _selectedCard!.forceDeselect();
    }
    _selectedCard = card.isSelected ? card : null;
  }
  @override
  void clearSelection() {
    if (_selectedCard != null) {
      _selectedCard!.forceDeselect();
      _selectedCard = null;
    }
  }
  @override
  bool isCardSelected(GameCard card) => _selectedCard == card;
  @override
  bool get hasSelection => _selectedCard != null;
}
