import 'package:flutter_test/flutter_test.dart';
import 'package:flame/game.dart';
import 'package:sci_fi_card_game/game/components/play_area.dart';
import 'package:sci_fi_card_game/game/my_game.dart';
import 'package:sci_fi_card_game/game/data/game_constants.dart';

void main() {
  group('PlayArea', () {
    late MyGame game;
    late PlayArea playArea;

    setUp(() async {
      game = MyGame();
      await game.onLoad();
      playArea = game.playArea;
    });

    test('should initialize with correct size and position', () {
      expect(playArea.size.x, equals(GameConstants.playAreaWidth));
      expect(playArea.size.y, equals(GameConstants.playAreaHeight));
      
      // Should be centered on screen
      final expectedX = (game.size.x - playArea.size.x) / 2;
      final expectedY = (game.size.y - playArea.size.y) / 2;
      expect(playArea.position.x, closeTo(expectedX, 1.0));
      expect(playArea.position.y, closeTo(expectedY, 1.0));
    });

    test('should highlight when requested', () {
      expect(playArea.isHighlighted, isFalse);
      
      playArea.highlight();
      
      expect(playArea.isHighlighted, isTrue);
    });

    test('should remove highlight when requested', () {
      playArea.highlight();
      expect(playArea.isHighlighted, isTrue);
      
      playArea.removeHighlight();
      
      expect(playArea.isHighlighted, isFalse);
    });

    test('should not highlight if already highlighted', () {
      playArea.highlight();
      final firstHighlightState = playArea.isHighlighted;
      
      playArea.highlight(); // Call again
      
      expect(playArea.isHighlighted, equals(firstHighlightState));
    });

    test('should not remove highlight if not highlighted', () {
      expect(playArea.isHighlighted, isFalse);
      
      playArea.removeHighlight(); // Should not crash
      
      expect(playArea.isHighlighted, isFalse);
    });

    test('should detect when card is over play area', () {
      final cardPosition = playArea.centerPosition;
      final cardSize = Vector2(50, 75); // Smaller than play area
      
      final isOver = playArea.isCardOver(cardPosition, cardSize);
      
      expect(isOver, isTrue);
    });

    test('should detect when card is not over play area', () {
      final cardPosition = Vector2(0, 0); // Top-left corner, outside play area
      final cardSize = Vector2(50, 75);
      
      final isOver = playArea.isCardOver(cardPosition, cardSize);
      
      expect(isOver, isFalse);
    });

    test('should require at least 50% overlap for card to be considered over', () {
      // Position card so only a small part overlaps
      final cardPosition = Vector2(
        playArea.position.x - 40, // Most of card is outside
        playArea.centerPosition.y,
      );
      final cardSize = Vector2(50, 75);
      
      final isOver = playArea.isCardOver(cardPosition, cardSize);
      
      expect(isOver, isFalse); // Less than 50% overlap
    });

    test('should detect point containment correctly', () {
      final centerPoint = playArea.centerPosition;
      final outsidePoint = Vector2(0, 0);
      
      expect(playArea.containsPoint(centerPoint), isTrue);
      expect(playArea.containsPoint(outsidePoint), isFalse);
    });

    test('should detect edge points correctly', () {
      final topLeftPoint = playArea.position;
      final bottomRightPoint = playArea.position + playArea.size;
      final justOutsidePoint = playArea.position + playArea.size + Vector2(1, 1);
      
      expect(playArea.containsPoint(topLeftPoint), isTrue);
      expect(playArea.containsPoint(bottomRightPoint), isFalse); // Exclusive boundary
      expect(playArea.containsPoint(justOutsidePoint), isFalse);
    });

    test('should have correct center position', () {
      final expectedCenter = playArea.position + playArea.size / 2;
      
      expect(playArea.centerPosition.x, closeTo(expectedCenter.x, 0.1));
      expect(playArea.centerPosition.y, closeTo(expectedCenter.y, 0.1));
    });

    test('should handle large card overlap correctly', () {
      final cardPosition = playArea.centerPosition;
      final largeCardSize = Vector2(400, 300); // Much larger than play area
      
      final isOver = playArea.isCardOver(cardPosition, largeCardSize);
      
      expect(isOver, isTrue); // Large card centered over play area should count
    });

    test('should handle card exactly at boundary', () {
      final boundaryPosition = Vector2(
        playArea.position.x + playArea.size.x / 2, // Right at right edge
        playArea.centerPosition.y,
      );
      final cardSize = Vector2(playArea.size.x, 75); // Card width equals play area width
      
      final isOver = playArea.isCardOver(boundaryPosition, cardSize);
      
      expect(isOver, isTrue); // Exactly 50% overlap
    });
  });
}