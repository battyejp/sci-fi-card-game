import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sci_fi_card_game/game/deck/layout/card_collection_manager.dart';
import 'package:sci_fi_card_game/game/deck/layout/card_selection_manager.dart';
import 'package:sci_fi_card_game/game/card/card.dart';

import 'card_collection_manager_enhanced_test.mocks.dart';

@GenerateMocks([GameCard, CardSelectionManager])
void main() {
  group('CardCollectionManager Enhanced Tests', () {
    late CardCollectionManager manager;
    late MockCardSelectionManager mockSelectionManager;
    late MockGameCard mockCardA;
    late MockGameCard mockCardB;
    late MockGameCard mockCardC;

    setUp(() {
      mockSelectionManager = MockCardSelectionManager();
      manager = CardCollectionManager(mockSelectionManager);
      
      mockCardA = MockGameCard();
      mockCardB = MockGameCard();
      mockCardC = MockGameCard();

      // Setup default behaviors
      when(mockCardA.id).thenReturn('card_a');
      when(mockCardB.id).thenReturn('card_b');
      when(mockCardC.id).thenReturn('card_c');
      
      // Setup selection callback
      when(mockCardA.onSelectionChanged).thenReturn(null);
      when(mockCardB.onSelectionChanged).thenReturn(null);
      when(mockCardC.onSelectionChanged).thenReturn(null);
    });

    group('Initial State', () {
      test('starts with empty collection', () {
        expect(manager.cards, isEmpty);
        expect(manager.cardCount, equals(0));
      });

      test('uses provided selection manager', () {
        expect(manager, isNotNull);
        // We can't directly access the private field, but we can verify behavior
      });

      test('creates with default selection manager when none provided', () {
        final defaultManager = CardCollectionManager();
        expect(defaultManager, isNotNull);
        expect(defaultManager.cards, isEmpty);
      });
    });

    group('Adding Cards', () {
      test('addCard increases count and adds to collection', () {
        manager.addCard(mockCardA);
        
        expect(manager.cardCount, equals(1));
        expect(manager.cards, contains(mockCardA));
        expect(manager.cards.length, equals(1));
      });

      test('addCard sets selection callback', () {
        manager.addCard(mockCardA);
        
        // Verify that the card's onSelectionChanged was set
        verify(mockCardA.onSelectionChanged = any).called(1);
      });

      test('multiple addCard calls work correctly', () {
        manager.addCard(mockCardA);
        manager.addCard(mockCardB);
        manager.addCard(mockCardC);
        
        expect(manager.cardCount, equals(3));
        expect(manager.cards, containsAll([mockCardA, mockCardB, mockCardC]));
        expect(manager.cards.length, equals(3));
      });

      test('addCard maintains order of insertion', () {
        manager.addCard(mockCardA);
        manager.addCard(mockCardB);
        manager.addCard(mockCardC);
        
        expect(manager.cards[0], equals(mockCardA));
        expect(manager.cards[1], equals(mockCardB));
        expect(manager.cards[2], equals(mockCardC));
      });

      test('can add same card multiple times', () {
        manager.addCard(mockCardA);
        manager.addCard(mockCardA);
        manager.addCard(mockCardA);
        
        expect(manager.cardCount, equals(3));
        expect(manager.cards.where((card) => card == mockCardA).length, equals(3));
      });
    });

    group('Card Lookup', () {
      setUp(() {
        manager.addCard(mockCardA);
        manager.addCard(mockCardB);
        manager.addCard(mockCardC);
      });

      test('indexOf returns correct index for existing cards', () {
        expect(manager.indexOf(mockCardA), equals(0));
        expect(manager.indexOf(mockCardB), equals(1));
        expect(manager.indexOf(mockCardC), equals(2));
      });

      test('indexOf returns -1 for non-existing card', () {
        final nonExistentCard = MockGameCard();
        expect(manager.indexOf(nonExistentCard), equals(-1));
      });

      test('indexOf works with duplicate cards', () {
        manager.addCard(mockCardA); // Now mockCardA appears at index 0 and 3
        
        // Should return the first occurrence
        expect(manager.indexOf(mockCardA), equals(0));
      });

      test('indexOf handles empty collection', () {
        final emptyManager = CardCollectionManager(mockSelectionManager);
        expect(emptyManager.indexOf(mockCardA), equals(-1));
      });
    });

    group('Clearing Cards', () {
      setUp(() {
        manager.addCard(mockCardA);
        manager.addCard(mockCardB);
        manager.addCard(mockCardC);
      });

      test('clearAllCards removes all cards from collection', () {
        manager.clearAllCards();
        
        expect(manager.cardCount, equals(0));
        expect(manager.cards, isEmpty);
      });

      test('clearAllCards calls removeFromParent on all cards', () {
        manager.clearAllCards();
        
        verify(mockCardA.removeFromParent()).called(1);
        verify(mockCardB.removeFromParent()).called(1);
        verify(mockCardC.removeFromParent()).called(1);
      });

      test('clearAllCards can be called on empty collection', () {
        final emptyManager = CardCollectionManager(mockSelectionManager);
        
        expect(() => emptyManager.clearAllCards(), returnsNormally);
        expect(emptyManager.cardCount, equals(0));
      });

      test('clearAllCards can be called multiple times', () {
        manager.clearAllCards();
        expect(manager.cardCount, equals(0));
        
        manager.clearAllCards();
        expect(manager.cardCount, equals(0));
        
        // Cards should only be removed once each
        verify(mockCardA.removeFromParent()).called(1);
        verify(mockCardB.removeFromParent()).called(1);
        verify(mockCardC.removeFromParent()).called(1);
      });
    });

    group('Selection Integration', () {
      test('card selection callback delegates to selection manager', () {
        manager.addCard(mockCardA);
        
        // Capture the callback that was set
        final capturedCallback = verify(mockCardA.onSelectionChanged = captureAny).captured.single;
        
        // Call the captured callback
        capturedCallback(mockCardA);
        
        // Verify it was delegated to the selection manager
        verify(mockSelectionManager.onCardSelectionChanged(mockCardA)).called(1);
      });

      test('multiple cards have correct selection callbacks', () {
        manager.addCard(mockCardA);
        manager.addCard(mockCardB);
        
        // Get the callbacks
        final capturedCallbacks = verify(mockCardA.onSelectionChanged = captureAny).captured;
        final callbackA = capturedCallbacks.first;
        
        final capturedCallbacksB = verify(mockCardB.onSelectionChanged = captureAny).captured;
        final callbackB = capturedCallbacksB.first;
        
        // Test both callbacks
        callbackA(mockCardA);
        callbackB(mockCardB);
        
        verify(mockSelectionManager.onCardSelectionChanged(mockCardA)).called(1);
        verify(mockSelectionManager.onCardSelectionChanged(mockCardB)).called(1);
      });

      test('selection callback works after clearing and re-adding', () {
        manager.addCard(mockCardA);
        manager.clearAllCards();
        manager.addCard(mockCardA);
        
        // Get the new callback
        final capturedCallbacks = verify(mockCardA.onSelectionChanged = captureAny).captured;
        final newCallback = capturedCallbacks.last;
        
        newCallback(mockCardA);
        
        verify(mockSelectionManager.onCardSelectionChanged(mockCardA)).called(1);
      });
    });

    group('Edge Cases and Error Handling', () {
      test('handles card that throws exception during removeFromParent', () {
        when(mockCardA.removeFromParent()).thenThrow(Exception('Remove failed'));
        
        manager.addCard(mockCardA);
        manager.addCard(mockCardB);
        
        // Should handle the exception and continue clearing other cards
        expect(() => manager.clearAllCards(), returnsNormally);
        
        verify(mockCardA.removeFromParent()).called(1);
        verify(mockCardB.removeFromParent()).called(1);
        expect(manager.cardCount, equals(0));
      });

      test('handles null selection manager gracefully', () {
        // This tests the default constructor path
        final defaultManager = CardCollectionManager();
        
        expect(() => defaultManager.addCard(mockCardA), returnsNormally);
        expect(defaultManager.cardCount, equals(1));
      });

      test('large collection operations perform correctly', () {
        final largeCardList = List.generate(1000, (index) {
          final card = MockGameCard();
          when(card.id).thenReturn('card_$index');
          return card;
        });
        
        // Add all cards
        for (final card in largeCardList) {
          manager.addCard(card);
        }
        
        expect(manager.cardCount, equals(1000));
        
        // Test indexOf on various cards
        expect(manager.indexOf(largeCardList[0]), equals(0));
        expect(manager.indexOf(largeCardList[500]), equals(500));
        expect(manager.indexOf(largeCardList[999]), equals(999));
        
        // Clear all
        manager.clearAllCards();
        expect(manager.cardCount, equals(0));
      });
    });

    group('State Consistency', () {
      test('cardCount is always consistent with cards.length', () {
        expect(manager.cardCount, equals(manager.cards.length));
        
        manager.addCard(mockCardA);
        expect(manager.cardCount, equals(manager.cards.length));
        
        manager.addCard(mockCardB);
        expect(manager.cardCount, equals(manager.cards.length));
        
        manager.clearAllCards();
        expect(manager.cardCount, equals(manager.cards.length));
      });

      test('cards list is immutable from outside', () {
        manager.addCard(mockCardA);
        manager.addCard(mockCardB);
        
        final cardsList = manager.cards;
        
        // Try to modify the returned list (should not affect internal state)
        expect(() => cardsList.clear(), throwsUnsupportedError);
      });

      test('operations maintain internal consistency', () {
        // Complex sequence of operations
        manager.addCard(mockCardA);
        expect(manager.indexOf(mockCardA), equals(0));
        
        manager.addCard(mockCardB);
        expect(manager.indexOf(mockCardA), equals(0));
        expect(manager.indexOf(mockCardB), equals(1));
        
        manager.addCard(mockCardC);
        expect(manager.indexOf(mockCardC), equals(2));
        
        manager.clearAllCards();
        expect(manager.indexOf(mockCardA), equals(-1));
        expect(manager.indexOf(mockCardB), equals(-1));
        expect(manager.indexOf(mockCardC), equals(-1));
        
        manager.addCard(mockCardC);
        expect(manager.indexOf(mockCardC), equals(0));
      });
    });

    group('Integration Scenarios', () {
      test('complete collection management workflow', () {
        // Start empty
        expect(manager.cardCount, equals(0));
        
        // Add cards
        manager.addCard(mockCardA);
        manager.addCard(mockCardB);
        manager.addCard(mockCardC);
        expect(manager.cardCount, equals(3));
        
        // Verify positions
        expect(manager.indexOf(mockCardA), equals(0));
        expect(manager.indexOf(mockCardB), equals(1));
        expect(manager.indexOf(mockCardC), equals(2));
        
        // Test selection callback
        final callback = verify(mockCardA.onSelectionChanged = captureAny).captured.first;
        callback(mockCardA);
        verify(mockSelectionManager.onCardSelectionChanged(mockCardA)).called(1);
        
        // Clear and verify
        manager.clearAllCards();
        expect(manager.cardCount, equals(0));
        verify(mockCardA.removeFromParent()).called(1);
        verify(mockCardB.removeFromParent()).called(1);
        verify(mockCardC.removeFromParent()).called(1);
      });
    });
  });
}