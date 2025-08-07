import 'package:flutter_test/flutter_test.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:sci_fi_card_game/game/components/play_area.dart';
import 'package:sci_fi_card_game/game/data/game_constants.dart';

void main() {
  group('PlayArea', () {
    late FlameGame game;
    late PlayArea playArea;

    setUp(() {
      game = FlameGame();
      playArea = PlayArea();
    });

    test('initializes with correct size and position', () async {
      game.add(playArea);
      await game.ready();

      expect(playArea.size.x, GameConstants.playAreaWidth);
      expect(playArea.size.y, GameConstants.playAreaHeight);
      
      // Should be centered on screen
      final expectedX = (game.size.x - playArea.size.x) / 2;
      final expectedY = (game.size.y - playArea.size.y) / 2;
      expect(playArea.position.x, expectedX);
      expect(playArea.position.y, expectedY);
    });

    test('containsPoint returns true for points inside play area', () async {
      game.add(playArea);
      await game.ready();

      // Test center point
      final centerPoint = playArea.position + playArea.size / 2;
      expect(playArea.containsPoint(centerPoint), isTrue);

      // Test corner points (inside)
      final topLeft = playArea.position + Vector2(1, 1);
      expect(playArea.containsPoint(topLeft), isTrue);

      final bottomRight = playArea.position + playArea.size - Vector2(1, 1);
      expect(playArea.containsPoint(bottomRight), isTrue);
    });

    test('containsPoint returns false for points outside play area', () async {
      game.add(playArea);
      await game.ready();

      // Test points outside the play area
      final outsideLeft = playArea.position - Vector2(1, 0);
      expect(playArea.containsPoint(outsideLeft), isFalse);

      final outsideRight = playArea.position + Vector2(playArea.size.x + 1, 0);
      expect(playArea.containsPoint(outsideRight), isFalse);

      final outsideTop = playArea.position - Vector2(0, 1);
      expect(playArea.containsPoint(outsideTop), isFalse);

      final outsideBottom = playArea.position + Vector2(0, playArea.size.y + 1);
      expect(playArea.containsPoint(outsideBottom), isFalse);
    });

    test('highlight changes state correctly', () async {
      game.add(playArea);
      await game.ready();

      expect(playArea.isHighlighted, isFalse);

      playArea.highlight();
      expect(playArea.isHighlighted, isTrue);

      playArea.removeHighlight();
      expect(playArea.isHighlighted, isFalse);
    });

    test('centerPosition returns correct center coordinates', () async {
      game.add(playArea);
      await game.ready();

      final expectedCenter = playArea.position + playArea.size / 2;
      expect(playArea.centerPosition, expectedCenter);
    });
  });
}