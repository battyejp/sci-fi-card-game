import 'package:flutter_test/flutter_test.dart';
import 'package:sci_fi_card_game/game/components/card_layout/card_selection_manager.dart';
import 'package:sci_fi_card_game/game/components/card.dart';

class MockGameCard extends GameCard {
  bool _mockIsSelected = false;
  bool _forceDeselectCalled = false;

  @override
  bool get isSelected => _mockIsSelected;

  @override
  void forceDeselect() {
    _forceDeselectCalled = true;
    _mockIsSelected = false;
  }

  void setMockSelected(bool selected) {
    _mockIsSelected = selected;
  }

  bool get wasForceDeselectCalled => _forceDeselectCalled;

  void resetMock() {
    _forceDeselectCalled = false;
    _mockIsSelected = false;
  }
}

void main() {
  group('CardSelectionManager', () {
    late CardSelectionManager manager;
    late MockGameCard card1;
    late MockGameCard card2;
    late MockGameCard card3;

    setUp(() {
      manager = CardSelectionManager();
      card1 = MockGameCard();
      card2 = MockGameCard();
      card3 = MockGameCard();
    });

    group('onCardSelectionChanged', () {
      test('should set selected card when card is selected', () {
        card1.setMockSelected(true);
        manager.onCardSelectionChanged(card1);

        expect(manager.selectedCard, equals(card1));
        expect(manager.hasSelection, isTrue);
      });

      test('should clear selected card when card is deselected', () {
        // First select a card
        card1.setMockSelected(true);
        manager.onCardSelectionChanged(card1);
        expect(manager.selectedCard, equals(card1));

        // Then deselect it
        card1.setMockSelected(false);
        manager.onCardSelectionChanged(card1);
        expect(manager.selectedCard, isNull);
        expect(manager.hasSelection, isFalse);
      });

      test('should deselect previous card when new card is selected', () {
        // Select first card
        card1.setMockSelected(true);
        manager.onCardSelectionChanged(card1);
        expect(manager.selectedCard, equals(card1));

        // Select second card
        card2.setMockSelected(true);
        manager.onCardSelectionChanged(card2);

        expect(card1.wasForceDeselectCalled, isTrue);
        expect(manager.selectedCard, equals(card2));
      });

      test('should not call forceDeselect on same card', () {
        card1.setMockSelected(true);
        manager.onCardSelectionChanged(card1);

        card1.resetMock();
        card1.setMockSelected(true);
        manager.onCardSelectionChanged(card1);

        expect(card1.wasForceDeselectCalled, isFalse);
      });

      test('should handle multiple card selections correctly', () {
        // Select card1
        card1.setMockSelected(true);
        manager.onCardSelectionChanged(card1);
        expect(manager.selectedCard, equals(card1));

        // Select card2 (should deselect card1)
        card2.setMockSelected(true);
        manager.onCardSelectionChanged(card2);
        expect(card1.wasForceDeselectCalled, isTrue);
        expect(manager.selectedCard, equals(card2));

        // Select card3 (should deselect card2)
        card2.resetMock();
        card3.setMockSelected(true);
        manager.onCardSelectionChanged(card3);
        expect(card2.wasForceDeselectCalled, isTrue);
        expect(manager.selectedCard, equals(card3));
      });
    });

    group('clearSelection', () {
      test('should clear selection and call forceDeselect', () {
        card1.setMockSelected(true);
        manager.onCardSelectionChanged(card1);
        expect(manager.selectedCard, equals(card1));

        manager.clearSelection();

        expect(card1.wasForceDeselectCalled, isTrue);
        expect(manager.selectedCard, isNull);
        expect(manager.hasSelection, isFalse);
      });

      test('should handle clearing when no card is selected', () {
        expect(manager.selectedCard, isNull);
        
        // Should not throw
        expect(() => manager.clearSelection(), returnsNormally);
        
        expect(manager.selectedCard, isNull);
        expect(manager.hasSelection, isFalse);
      });
    });

    group('isCardSelected', () {
      test('should return true for selected card', () {
        card1.setMockSelected(true);
        manager.onCardSelectionChanged(card1);

        expect(manager.isCardSelected(card1), isTrue);
        expect(manager.isCardSelected(card2), isFalse);
      });

      test('should return false when no card is selected', () {
        expect(manager.isCardSelected(card1), isFalse);
        expect(manager.isCardSelected(card2), isFalse);
      });

      test('should return false for different card', () {
        card1.setMockSelected(true);
        manager.onCardSelectionChanged(card1);

        expect(manager.isCardSelected(card1), isTrue);
        expect(manager.isCardSelected(card2), isFalse);
        expect(manager.isCardSelected(card3), isFalse);
      });
    });

    group('hasSelection', () {
      test('should return false initially', () {
        expect(manager.hasSelection, isFalse);
      });

      test('should return true when card is selected', () {
        card1.setMockSelected(true);
        manager.onCardSelectionChanged(card1);

        expect(manager.hasSelection, isTrue);
      });

      test('should return false after selection is cleared', () {
        card1.setMockSelected(true);
        manager.onCardSelectionChanged(card1);
        expect(manager.hasSelection, isTrue);

        manager.clearSelection();
        expect(manager.hasSelection, isFalse);
      });
    });

    group('selectedCard getter', () {
      test('should return null initially', () {
        expect(manager.selectedCard, isNull);
      });

      test('should return the selected card', () {
        card1.setMockSelected(true);
        manager.onCardSelectionChanged(card1);

        expect(manager.selectedCard, equals(card1));
      });

      test('should return null after deselection', () {
        card1.setMockSelected(true);
        manager.onCardSelectionChanged(card1);
        expect(manager.selectedCard, equals(card1));

        card1.setMockSelected(false);
        manager.onCardSelectionChanged(card1);
        expect(manager.selectedCard, isNull);
      });
    });
  });
}
