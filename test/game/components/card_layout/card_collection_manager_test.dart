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

    group('clearAllCards', () {
      test('should remove all cards and call removeFromParent', () {
        manager.addCard(card1);
        manager.addCard(card2);
        manager.addCard(card3);
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

    group('indexOf', () {
      test('should return correct index for cards in collection', () {
        manager.addCard(card1);
        manager.addCard(card2);
        manager.addCard(card3);

        expect(manager.indexOf(card1), equals(0));
        expect(manager.indexOf(card2), equals(1));
        expect(manager.indexOf(card3), equals(2));
      });

      test('should return -1 for cards not in collection', () {
        manager.addCard(card1);
        manager.addCard(card2);

        expect(manager.indexOf(card3), equals(-1));
      });

      test('should return -1 for empty collection', () {
        expect(manager.indexOf(card1), equals(-1));
      });
    });
  });
}
