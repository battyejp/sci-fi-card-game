import 'package:flutter_test/flutter_test.dart';
import 'package:flame/game.dart';
import 'package:sci_fi_card_game/game/components/card.dart';
import 'package:sci_fi_card_game/game/my_game.dart';

void main() {
  group('GameCard', () {
    late MyGame game;
    late GameCard card;

    setUp(() async {
      game = MyGame();
      await game.onLoad();
      card = GameCard();
      await card.onLoad();
      game.add(card);
    });

    test('should initialize with correct default values', () {
      expect(card.isSelected, false);
      expect(card.isAnimating, false);
      expect(card.isDragging, false);
    });

    test('should have original position set', () {
      final originalPos = card.originalPosition;
      expect(originalPos, isA<Vector2>());
    });

    test('should have card rotation property', () {
      final rotation = card.cardRotation;
      expect(rotation, isA<double>());
    });

    test('should be able to set original position', () {
      final newPosition = Vector2(100, 200);
      card.setOriginalPosition(newPosition);
      expect(card.originalPosition, equals(newPosition));
      expect(card.position, equals(newPosition));
    });

    test('should be able to set rotation', () {
      const newRotation = 0.5;
      card.setRotation(newRotation);
      expect(card.cardRotation, equals(newRotation));
      expect(card.angle, equals(newRotation));
    });

    test('should handle force deselect when not dragging', () {
      // This should not throw an error
      card.forceDeselect();
      expect(card.isSelected, false);
    });
  });
}