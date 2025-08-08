import 'package:flutter_test/flutter_test.dart';
import 'package:sci_fi_card_game/game/deck/layout/card_collection_manager.dart';
import 'package:sci_fi_card_game/game/deck/layout/card_selection_manager.dart';
import 'package:sci_fi_card_game/game/card/card.dart';

class _StubCard extends GameCard {
  bool removedFlag = false;
  @override
  void removeFromParent() { removedFlag = true; }
}

void main() {
  group('CardCollectionManager', () {
    late CardCollectionManager coll; late CardSelectionManager sel; late _StubCard a,b,c;
    setUp(() { sel = CardSelectionManager(); coll = CardCollectionManager(sel); a=_StubCard(); b=_StubCard(); c=_StubCard(); });

    test('addCard adds', () {
      coll.addCard(a);
      expect(coll.cardCount, 1); expect(coll.cards.single, a);
    });

    test('indexOf returns positions', () {
      coll..addCard(a)..addCard(b);
      expect(coll.indexOf(a), 0); expect(coll.indexOf(b), 1); expect(coll.indexOf(c), -1);
    });

    test('clearAllCards removes & empties', () {
      coll..addCard(a)..addCard(b)..addCard(c);
      coll.clearAllCards();
  expect(coll.cardCount, 0); expect(a.removedFlag, true); expect(b.removedFlag, true); expect(c.removedFlag, true);
    });
  });
}
