import 'package:flutter_test/flutter_test.dart';
import 'package:sci_fi_card_game/game/deck/layout/fan_layout_calculator.dart';
import 'package:sci_fi_card_game/game/data/game_constants.dart';

void main() {
  group('FanLayoutCalculator', () {
    late FanLayoutCalculator calculator;

    setUp(() => calculator = FanLayoutCalculator());

    test('single card center position', () {
      final p = calculator.calculateCardPosition(
        cardIndex: 0,
        totalCards: 1,
        centerX: 400,
        centerY: 300,
        radius: 200,
      );
      expect(p.x, 400);
      expect(p.y, 300);
    });

    test('rotation range bounded', () {
      for (int i = 0; i < 7; i++) {
        final r = calculator.calculateCardRotation(cardIndex: i, totalCards: 7);
        final max = GameConstants.degreesToRadians(GameConstants.maxFanRotation);
        expect(r.abs(), lessThanOrEqualTo(max));
      }
    });

    test('center priority highest', () {
      final list = [for (int i = 0; i < 5; i++) calculator.calculateCardPriority(cardIndex: i, totalCards: 5)];
      final max = list.reduce((a,b)=> a>b? a:b);
      expect(list[2], max);
    });
  });
}
