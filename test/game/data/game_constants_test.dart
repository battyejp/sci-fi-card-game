
import 'package:flutter_test/flutter_test.dart';
import 'package:sci_fi_card_game/game/data/game_constants.dart';
import 'dart:math' as math;

void main() {
  group('GameConstants.setCardCount', () {
    test('sets cardCount within bounds', () {
      GameConstants.setCardCount(5);
      expect(GameConstants.cardCount, 5);
      GameConstants.setCardCount(1);
      expect(GameConstants.cardCount, 1);
      GameConstants.setCardCount(10);
      expect(GameConstants.cardCount, 10);
    });
    test('clamps cardCount below 1', () {
      GameConstants.setCardCount(-3);
      expect(GameConstants.cardCount, 1);
    });
    test('clamps cardCount above 10', () {
      GameConstants.setCardCount(20);
      expect(GameConstants.cardCount, 10);
    });
  });

  group('GameConstants.degreesToRadians', () {
    test('converts degrees to radians correctly', () {
      expect(GameConstants.degreesToRadians(0), 0);
      expect(GameConstants.degreesToRadians(180), closeTo(math.pi, 0.0001));
      expect(GameConstants.degreesToRadians(90), closeTo(math.pi / 2, 0.0001));
      expect(GameConstants.degreesToRadians(360), closeTo(2 * math.pi, 0.0001));
    });
  });
}
