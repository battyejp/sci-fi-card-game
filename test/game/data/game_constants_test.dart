
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

  group('GameConstants drag and drop constants', () {
    test('drag threshold is positive', () {
      expect(GameConstants.dragThreshold, greaterThan(0));
    });

    test('drag card scale is between 0 and 1', () {
      expect(GameConstants.dragCardScale, greaterThan(0));
      expect(GameConstants.dragCardScale, lessThanOrEqualTo(1));
    });

    test('drag card opacity is between 0 and 1', () {
      expect(GameConstants.dragCardOpacity, greaterThan(0));
      expect(GameConstants.dragCardOpacity, lessThanOrEqualTo(1));
    });
  });

  group('GameConstants play area constants', () {
    test('play area dimensions are positive', () {
      expect(GameConstants.playAreaWidth, greaterThan(0));
      expect(GameConstants.playAreaHeight, greaterThan(0));
    });

    test('play area corner radius is non-negative', () {
      expect(GameConstants.playAreaCornerRadius, greaterThanOrEqualTo(0));
    });

    test('play area border width is positive', () {
      expect(GameConstants.playAreaBorderWidth, greaterThan(0));
    });

    test('play area highlight duration is positive', () {
      expect(GameConstants.playAreaHighlightDuration, greaterThan(0));
    });
  });

  group('GameConstants colors', () {
    test('play area colors are defined', () {
      expect(GameConstants.playAreaColor, isNotNull);
      expect(GameConstants.playAreaHighlightColor, isNotNull);
    });

    test('play area colors are different', () {
      expect(GameConstants.playAreaColor, isNot(equals(GameConstants.playAreaHighlightColor)));
    });
  });
}
