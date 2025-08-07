import 'package:flutter_test/flutter_test.dart';
import 'package:sci_fi_card_game/game/components/card_layout/card_collection_manager.dart';
import 'package:sci_fi_card_game/game/components/card_layout/card_selection_manager.dart';
import 'package:sci_fi_card_game/game/components/card.dart';

class MockGameCard extends GameCard {
  bool _removedFromParent = false;
  Function(GameCard)? _onSelectionChanged;

  @override
  void removeFromParent() {
    _removedFromParent = true;
  }

  @override
  set onSelectionChanged(Function(GameCard)? callback) {
    _onSelectionChanged = callback;
  }

  @override
  Function(GameCard)? get onSelectionChanged => _onSelectionChanged;

  bool get wasRemovedFromParent => _removedFromParent;

  void resetMock() {
    _removedFromParent = false;
    _onSelectionChanged = null;
  }
}

void main() {
  group('CardCollectionManager', () {
    late CardCollectionManager manager;
    late CardSelectionManager selectionManager;
    late MockGameCard card1;
    late MockGameCard card2;
    late MockGameCard card3;

    setUp(() {
      selectionManager = CardSelectionManager();
      manager = CardCollectionManager(selectionManager);
      card1 = MockGameCard();
      card2 = MockGameCard();
      card3 = MockGameCard();
    });

    group('addCard', () {
      test('should add card to collection', () {
        manager.addCard(card1);

        expect(manager.cardCount, equals(1));
        expect(manager.cards, contains(card1));
      });

      test('should set selection callback on card', () {
        manager.addCard(card1);

        expect(card1.onSelectionChanged, isNotNull);
      });

      test('should add multiple cards', () {
        manager.addCard(card1);
        manager.addCard(card2);
        manager.addCard(card3);

        expect(manager.cardCount, equals(3));
        expect(manager.cards, containsAll([card1, card2, card3]));
      });
    });

    group('addCards', () {
      test('should add multiple cards at once', () {
        final cards = [card1, card2, card3];
        manager.addCards(cards);

        expect(manager.cardCount, equals(3));
        expect(manager.cards, containsAll(cards));
        
        // All should have selection callbacks
        expect(card1.onSelectionChanged, isNotNull);
        expect(card2.onSelectionChanged, isNotNull);
        expect(card3.onSelectionChanged, isNotNull);
      });

      test('should handle empty list', () {
        manager.addCards([]);

        expect(manager.cardCount, equals(0));
        expect(manager.cards, isEmpty);
      });
    });

    group('removeCardsFromIndex', () {
      test('should remove cards from specified index', () {
        manager.addCards([card1, card2, card3]);
        expect(manager.cardCount, equals(3));

        final removed = manager.removeCardsFromIndex(1);

        expect(manager.cardCount, equals(1));
        expect(manager.cards, equals([card1]));
        expect(removed, equals([card2, card3]));
      });

      test('should return empty list when index is out of bounds', () {
        manager.addCards([card1, card2]);

        final removed = manager.removeCardsFromIndex(5);

        expect(removed, isEmpty);
        expect(manager.cardCount, equals(2));
      });

      test('should handle removing from index 0', () {
        manager.addCards([card1, card2, card3]);

        final removed = manager.removeCardsFromIndex(0);

        expect(manager.cardCount, equals(0));
        expect(removed, equals([card1, card2, card3]));
      });

      test('should handle removing last card', () {
        manager.addCards([card1, card2, card3]);

        final removed = manager.removeCardsFromIndex(2);

        expect(manager.cardCount, equals(2));
        expect(manager.cards, equals([card1, card2]));
        expect(removed, equals([card3]));
      });
    });

    group('clearAllCards', () {
      test('should remove all cards and call removeFromParent', () {
        manager.addCards([card1, card2, card3]);
        expect(manager.cardCount, equals(3));

        manager.clearAllCards();

        expect(manager.cardCount, equals(0));
        expect(manager.cards, isEmpty);
        expect(card1.wasRemovedFromParent, isTrue);
        expect(card2.wasRemovedFromParent, isTrue);
        expect(card3.wasRemovedFromParent, isTrue);
      });

      test('should handle clearing empty collection', () {
        expect(manager.cardCount, equals(0));

        expect(() => manager.clearAllCards(), returnsNormally);

        expect(manager.cardCount, equals(0));
        expect(manager.cards, isEmpty);
      });
    });

    group('getCardAt', () {
      test('should return card at valid index', () {
        manager.addCards([card1, card2, card3]);

        expect(manager.getCardAt(0), equals(card1));
        expect(manager.getCardAt(1), equals(card2));
        expect(manager.getCardAt(2), equals(card3));
      });

      test('should return null for invalid index', () {
        manager.addCards([card1, card2]);

        expect(manager.getCardAt(-1), isNull);
        expect(manager.getCardAt(2), isNull);
        expect(manager.getCardAt(10), isNull);
      });

      test('should return null for empty collection', () {
        expect(manager.getCardAt(0), isNull);
      });
    });

    group('containsCard', () {
      test('should return true for cards in collection', () {
        manager.addCards([card1, card2]);

        expect(manager.containsCard(card1), isTrue);
        expect(manager.containsCard(card2), isTrue);
        expect(manager.containsCard(card3), isFalse);
      });

      test('should return false for empty collection', () {
        expect(manager.containsCard(card1), isFalse);
      });
    });

    group('indexOf', () {
      test('should return correct index for cards in collection', () {
        manager.addCards([card1, card2, card3]);

        expect(manager.indexOf(card1), equals(0));
        expect(manager.indexOf(card2), equals(1));
        expect(manager.indexOf(card3), equals(2));
      });

      test('should return -1 for cards not in collection', () {
        manager.addCards([card1, card2]);

        expect(manager.indexOf(card3), equals(-1));
      });

      test('should return -1 for empty collection', () {
        expect(manager.indexOf(card1), equals(-1));
      });
    });

    group('cards getter', () {
      test('should return unmodifiable list', () {
        manager.addCards([card1, card2, card3]);

        final cards = manager.cards;
        expect(() => cards.add(MockGameCard()), throwsUnsupportedError);
        expect(() => cards.clear(), throwsUnsupportedError);
      });

      test('should reflect current state', () {
        expect(manager.cards, isEmpty);

        manager.addCard(card1);
        expect(manager.cards, equals([card1]));

        manager.addCard(card2);
        expect(manager.cards, equals([card1, card2]));

        manager.removeCardsFromIndex(0);
        expect(manager.cards, isEmpty);
      });
    });

    group('cardCount getter', () {
      test('should return correct count', () {
        expect(manager.cardCount, equals(0));

        manager.addCard(card1);
        expect(manager.cardCount, equals(1));

        manager.addCards([card2, card3]);
        expect(manager.cardCount, equals(3));

        manager.removeCardsFromIndex(1);
        expect(manager.cardCount, equals(1));

        manager.clearAllCards();
        expect(manager.cardCount, equals(0));
      });
    });
  });
}
