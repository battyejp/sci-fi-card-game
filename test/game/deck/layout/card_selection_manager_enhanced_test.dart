import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sci_fi_card_game/game/deck/layout/card_selection_manager.dart';
import 'package:sci_fi_card_game/game/card/card.dart';

import 'card_selection_manager_enhanced_test.mocks.dart';

@GenerateMocks([GameCard])
void main() {
  group('CardSelectionManager Enhanced Tests', () {
    late CardSelectionManager manager;
    late MockGameCard mockCardA;
    late MockGameCard mockCardB;
    late MockGameCard mockCardC;

    setUp(() {
      manager = CardSelectionManager();
      mockCardA = MockGameCard();
      mockCardB = MockGameCard();
      mockCardC = MockGameCard();

      // Setup default behaviors
      when(mockCardA.id).thenReturn('card_a');
      when(mockCardB.id).thenReturn('card_b');
      when(mockCardC.id).thenReturn('card_c');
    });

    group('Initial State', () {
      test('starts with no selection', () {
        expect(manager.selectedCard, isNull);
        expect(manager.hasSelection, false);
      });
    });

    group('Card Selection', () {
      test('selects card when it becomes selected', () {
        when(mockCardA.isSelected).thenReturn(true);
        
        manager.onCardSelectionChanged(mockCardA);
        
        expect(manager.selectedCard, equals(mockCardA));
        expect(manager.hasSelection, true);
      });

      test('deselects card when it becomes unselected', () {
        // First select the card
        when(mockCardA.isSelected).thenReturn(true);
        manager.onCardSelectionChanged(mockCardA);
        expect(manager.selectedCard, equals(mockCardA));
        
        // Then deselect it
        when(mockCardA.isSelected).thenReturn(false);
        manager.onCardSelectionChanged(mockCardA);
        
        expect(manager.selectedCard, isNull);
        expect(manager.hasSelection, false);
      });

      test('ignores selection change for non-selected card', () {
        when(mockCardA.isSelected).thenReturn(false);
        
        manager.onCardSelectionChanged(mockCardA);
        
        expect(manager.selectedCard, isNull);
        expect(manager.hasSelection, false);
      });
    });

    group('Multiple Card Management', () {
      test('switching selection deselects previous card', () {
        // Select first card
        when(mockCardA.isSelected).thenReturn(true);
        manager.onCardSelectionChanged(mockCardA);
        expect(manager.selectedCard, equals(mockCardA));
        
        // Select second card
        when(mockCardB.isSelected).thenReturn(true);
        manager.onCardSelectionChanged(mockCardB);
        
        // Should have deselected the first card
        verify(mockCardA.forceDeselect()).called(1);
        expect(manager.selectedCard, equals(mockCardB));
        expect(manager.hasSelection, true);
      });

      test('does not deselect same card when reselected', () {
        // Select card
        when(mockCardA.isSelected).thenReturn(true);
        manager.onCardSelectionChanged(mockCardA);
        
        // Try to select same card again
        manager.onCardSelectionChanged(mockCardA);
        
        // Should not have called forceDeselect
        verifyNever(mockCardA.forceDeselect());
        expect(manager.selectedCard, equals(mockCardA));
      });

      test('handles multiple rapid selection changes', () {
        // Setup cards
        when(mockCardA.isSelected).thenReturn(true);
        when(mockCardB.isSelected).thenReturn(true);
        when(mockCardC.isSelected).thenReturn(true);
        
        // Rapid selections
        manager.onCardSelectionChanged(mockCardA);
        manager.onCardSelectionChanged(mockCardB);
        manager.onCardSelectionChanged(mockCardC);
        
        // Should have deselected previous cards
        verify(mockCardA.forceDeselect()).called(1);
        verify(mockCardB.forceDeselect()).called(1);
        verifyNever(mockCardC.forceDeselect());
        
        expect(manager.selectedCard, equals(mockCardC));
      });
    });

    group('Selection Clearing', () {
      test('clearSelection removes current selection', () {
        // Select a card first
        when(mockCardA.isSelected).thenReturn(true);
        manager.onCardSelectionChanged(mockCardA);
        expect(manager.hasSelection, true);
        
        // Clear selection
        manager.clearSelection();
        
        verify(mockCardA.forceDeselect()).called(1);
        expect(manager.selectedCard, isNull);
        expect(manager.hasSelection, false);
      });

      test('clearSelection does nothing when no selection', () {
        expect(manager.hasSelection, false);
        
        manager.clearSelection();
        
        expect(manager.selectedCard, isNull);
        expect(manager.hasSelection, false);
        // No cards should be affected
        verifyNever(mockCardA.forceDeselect());
        verifyNever(mockCardB.forceDeselect());
      });

      test('clearSelection can be called multiple times safely', () {
        // Select and clear
        when(mockCardA.isSelected).thenReturn(true);
        manager.onCardSelectionChanged(mockCardA);
        manager.clearSelection();
        
        // Clear again
        manager.clearSelection();
        manager.clearSelection();
        
        // Should only have called forceDeselect once
        verify(mockCardA.forceDeselect()).called(1);
        expect(manager.hasSelection, false);
      });
    });

    group('Edge Cases', () {
      test('handles null card gracefully', () {
        // This should not throw
        expect(() => manager.onCardSelectionChanged(null as dynamic), returnsNormally);
        expect(manager.selectedCard, isNull);
      });

      test('handles card that throws exception during forceDeselect', () {
        when(mockCardA.isSelected).thenReturn(true);
        when(mockCardB.isSelected).thenReturn(true);
        when(mockCardA.forceDeselect()).thenThrow(Exception('Force deselect failed'));
        
        // Select first card
        manager.onCardSelectionChanged(mockCardA);
        
        // Try to select second card (should handle exception)
        expect(() => manager.onCardSelectionChanged(mockCardB), returnsNormally);
        
        // Should still update selection despite exception
        expect(manager.selectedCard, equals(mockCardB));
      });

      test('maintains consistency when card selection state changes externally', () {
        // Select card
        when(mockCardA.isSelected).thenReturn(true);
        manager.onCardSelectionChanged(mockCardA);
        expect(manager.selectedCard, equals(mockCardA));
        
        // Card becomes unselected externally
        when(mockCardA.isSelected).thenReturn(false);
        manager.onCardSelectionChanged(mockCardA);
        
        expect(manager.selectedCard, isNull);
        expect(manager.hasSelection, false);
      });
    });

    group('State Consistency', () {
      test('hasSelection is consistent with selectedCard', () {
        // Initially no selection
        expect(manager.hasSelection, equals(manager.selectedCard != null));
        
        // After selection
        when(mockCardA.isSelected).thenReturn(true);
        manager.onCardSelectionChanged(mockCardA);
        expect(manager.hasSelection, equals(manager.selectedCard != null));
        
        // After deselection
        when(mockCardA.isSelected).thenReturn(false);
        manager.onCardSelectionChanged(mockCardA);
        expect(manager.hasSelection, equals(manager.selectedCard != null));
        
        // After clearing
        when(mockCardB.isSelected).thenReturn(true);
        manager.onCardSelectionChanged(mockCardB);
        manager.clearSelection();
        expect(manager.hasSelection, equals(manager.selectedCard != null));
      });

      test('selection state persists across multiple operations', () {
        when(mockCardA.isSelected).thenReturn(true);
        
        manager.onCardSelectionChanged(mockCardA);
        expect(manager.selectedCard, equals(mockCardA));
        
        // Multiple calls with same card should maintain selection
        manager.onCardSelectionChanged(mockCardA);
        manager.onCardSelectionChanged(mockCardA);
        expect(manager.selectedCard, equals(mockCardA));
        expect(manager.hasSelection, true);
      });
    });

    group('Integration Scenarios', () {
      test('complete selection workflow', () {
        // Start with no selection
        expect(manager.hasSelection, false);
        
        // Select card A
        when(mockCardA.isSelected).thenReturn(true);
        manager.onCardSelectionChanged(mockCardA);
        expect(manager.selectedCard, equals(mockCardA));
        
        // Switch to card B
        when(mockCardB.isSelected).thenReturn(true);
        manager.onCardSelectionChanged(mockCardB);
        verify(mockCardA.forceDeselect()).called(1);
        expect(manager.selectedCard, equals(mockCardB));
        
        // Deselect card B
        when(mockCardB.isSelected).thenReturn(false);
        manager.onCardSelectionChanged(mockCardB);
        expect(manager.selectedCard, isNull);
        
        // Clear selection (should be no-op)
        manager.clearSelection();
        expect(manager.hasSelection, false);
      });
    });
  });
}