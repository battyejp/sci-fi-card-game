
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
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

  group('GameConstants Play Area', () {
    test('has correct play area dimensions', () {
      expect(GameConstants.playAreaWidth, 200.0);
      expect(GameConstants.playAreaHeight, 150.0);
      expect(GameConstants.playAreaBorderRadius, 15.0);
    });

    test('has correct play area border width', () {
      expect(GameConstants.playAreaBorderWidth, 3.0);
    });

    test('has correct play area colors', () {
      expect(GameConstants.playAreaColor, const Color(0xFF2A2A3E));
      expect(GameConstants.playAreaHighlightColor, const Color(0xFF4A4A6E));
    });

    test('play area colors are different', () {
      expect(GameConstants.playAreaColor, isNot(equals(GameConstants.playAreaHighlightColor)));
    });

    test('has correct drag and drop constants', () {
      expect(GameConstants.dragThreshold, 10.0);
      expect(GameConstants.dragCardScale, 0.7);
      expect(GameConstants.dragCardOpacity, 0.8);
    });

    test('drag constants are within valid ranges', () {
      expect(GameConstants.dragCardScale, greaterThan(0.0));
      expect(GameConstants.dragCardScale, lessThanOrEqualTo(1.0));
      expect(GameConstants.dragCardOpacity, greaterThan(0.0));
      expect(GameConstants.dragCardOpacity, lessThanOrEqualTo(1.0));
      expect(GameConstants.dragThreshold, greaterThan(0.0));
    });
  });
}
