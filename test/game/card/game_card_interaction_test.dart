import 'package:flutter_test/flutter_test.dart';
import 'package:sci_fi_card_game/game/card/card.dart';

void main() {
  test('GameCard id & toJson', () {
    final c = GameCard();
    final j = c.toJson();
    expect(j['id'], isNotEmpty);
    expect(j['selected'], false);
  });
}
