import 'package:flutter_test/flutter_test.dart';
import 'package:sci_fi_card_game/game/deck/layout/card_selection_manager.dart';
import 'package:sci_fi_card_game/game/card/card.dart';

class _MockCard extends GameCard {
  bool mockSelected = false;
  bool deselectCalled = false;
  @override
  bool get isSelected => mockSelected;
  @override
  void forceDeselect() { deselectCalled = true; mockSelected = false; }
}

void main() {
  group('CardSelectionManager', () {
    late CardSelectionManager manager;
    late _MockCard a,b;
    setUp(() { manager = CardSelectionManager(); a=_MockCard(); b=_MockCard(); });

    test('select sets selectedCard', () {
      a.mockSelected = true; manager.onCardSelectionChanged(a);
      expect(manager.selectedCard, a); expect(manager.hasSelection, true);
    });

    test('deselect clears selection', () {
      a.mockSelected=true; manager.onCardSelectionChanged(a);
      a.mockSelected=false; manager.onCardSelectionChanged(a);
      expect(manager.selectedCard, isNull); expect(manager.hasSelection, false);
    });

    test('new selection deselects previous', () {
      a.mockSelected=true; manager.onCardSelectionChanged(a);
      b.mockSelected=true; manager.onCardSelectionChanged(b);
      expect(a.deselectCalled, true); expect(manager.selectedCard, b);
    });

    test('clearSelection forces deselect', () {
      a.mockSelected=true; manager.onCardSelectionChanged(a);
      manager.clearSelection();
      expect(a.deselectCalled, true); expect(manager.selectedCard, isNull); expect(manager.hasSelection, false);
    });
  });
}
