import 'package:flutter_test/flutter_test.dart';
import 'package:sci_fi_card_game/game/deck/layout/card_collection_manager.dart';
import 'package:sci_fi_card_game/game/deck/layout/card_selection_manager.dart';
import 'package:sci_fi_card_game/game/card/card.dart';

class _MockCard extends GameCard {
  bool removedFlag = false;
  @override
  void removeFromParent() { removedFlag = true; }
}

void main() {
  group('CardCollectionManager', () {
    late CardCollectionManager manager; late CardSelectionManager sel; 
    late _MockCard a,b,c;
    setUp(() { sel=CardSelectionManager(); manager=CardCollectionManager(sel); a=_MockCard(); b=_MockCard(); c=_MockCard(); });

    test('addCard increments count', () {
      manager.addCard(a); expect(manager.cardCount, 1); expect(manager.cards, contains(a));
    });

    test('clearAllCards removes all', () {
      manager..addCard(a)..addCard(b)..addCard(c);
      manager.clearAllCards();
  expect(manager.cardCount, 0); expect(a.removedFlag, true); expect(b.removedFlag, true); expect(c.removedFlag, true);
    });

    test('indexOf works', () {
      manager..addCard(a)..addCard(b);
      expect(manager.indexOf(a),0); expect(manager.indexOf(b),1); expect(manager.indexOf(c), -1);
    });
  });
}
