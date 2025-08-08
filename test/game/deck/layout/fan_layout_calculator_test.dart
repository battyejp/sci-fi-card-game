import 'package:flutter_test/flutter_test.dart';
import 'package:sci_fi_card_game/game/deck/layout/fan_layout_calculator.dart';
import 'package:sci_fi_card_game/game/data/game_constants.dart';

void main() {
  group('FanLayoutCalculator', () {
    late FanLayoutCalculator calculator;
    setUp(() => calculator = FanLayoutCalculator());

    test('single card centered & rotation 0', () {
      final p = calculator.calculateCardPosition(
        cardIndex: 0,
        totalCards: 1,
        centerX: 400,
        centerY: 300,
        radius: 250,
      );
      expect(p.x, 400);
      expect(p.y, 300);
      expect(calculator.calculateCardRotation(cardIndex: 0, totalCards: 1), 0);
      expect(calculator.calculateCardPriority(cardIndex: 0, totalCards: 1), 1);
    });

    test('center priority highest (odd count)', () {
      const total = 5;
      final priorities = [
        for (int i = 0; i < total; i++)
          calculator.calculateCardPriority(cardIndex: i, totalCards: total)
      ];
      final max = priorities.reduce((a, b) => a > b ? a : b);
      expect(priorities[2], max);
    });

    test('rotation bounded by maxFanRotation', () {
      final maxRot =
          GameConstants.degreesToRadians(GameConstants.maxFanRotation).abs();
      for (int total = 3; total <= 11; total += 2) {
        for (int i = 0; i < total; i++) {
          final r = calculator
              .calculateCardRotation(cardIndex: i, totalCards: total)
              .abs();
          expect(r, lessThanOrEqualTo(maxRot));
        }
      }
    });

    test('adjusted radius shrinks when total width would overflow', () {
      const base = GameConstants.fanRadius;
      final shrunk = calculator.calculateAdjustedRadius(
        cardCount: 40,
        gameWidth: 600,
        safeAreaPadding: GameConstants.safeAreaPadding,
        cardWidth: GameConstants.handCardWidth,
        baseRadius: base,
      );
      expect(shrunk, lessThan(base));
    });
  });
}
