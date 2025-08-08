import 'package:flutter_test/flutter_test.dart';
import 'package:flame/components.dart';
import 'package:sci_fi_card_game/game/card/card.dart';

void main() {
  group('GameCard basic (pre-load) behavior', () {
    test('ids are unique', () {
      final a = GameCard();
      final b = GameCard();
      expect(a.id, isNot(equals(b.id)));
    });

    test('setOriginalPosition before load updates position & originalPosition', () {
      final c = GameCard();
      c.setOriginalPosition(Vector2(10, 20));
      expect(c.position.x, 10);
      expect(c.originalPosition.x, 10);
      expect(c.originalPosition.y, 20);
    });

    test('setRotation before load sets angle but base rotation remains default until load', () {
      final c = GameCard();
      c.setRotation(1.23);
      // angle updated
      expect(c.angle, 1.23);
      // base rotation not yet established (remains 0)
      expect(c.cardRotation, 0);
    });

    test('toJson contains expected keys', () {
      final c = GameCard();
      final json = c.toJson();
      expect(json['id'], isNotEmpty);
      expect(json.containsKey('x'), true);
      expect(json.containsKey('y'), true);
      expect(json.containsKey('rotation'), true);
      expect(json['selected'], false);
    });
  });
}
