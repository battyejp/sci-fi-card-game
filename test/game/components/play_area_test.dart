import 'package:flutter_test/flutter_test.dart';
import 'package:flame/game.dart';
import 'package:sci_fi_card_game/game/components/play_area.dart';
import 'package:sci_fi_card_game/game/my_game.dart';

void main() {
  group('PlayArea', () {
    late MyGame game;
    late PlayArea playArea;

    setUp(() async {
      game = MyGame();
      await game.onLoad();
      playArea = PlayArea();
      await playArea.onLoad();
      game.add(playArea);
    });

    test('should initialize with correct default values', () {
      expect(playArea.isHighlighted, false);
    });

    test('should highlight when highlight() is called', () {
      playArea.highlight();
      expect(playArea.isHighlighted, true);
    });

    test('should remove highlight when removeHighlight() is called', () {
      playArea.highlight();
      expect(playArea.isHighlighted, true);
      
      playArea.removeHighlight();
      expect(playArea.isHighlighted, false);
    });

    test('should detect if point is inside play area', () {
      final centerPoint = Vector2(
        playArea.position.x + playArea.size.x / 2,
        playArea.position.y + playArea.size.y / 2,
      );
      
      expect(playArea.containsPoint(centerPoint), true);
      
      final outsidePoint = Vector2(-10, -10);
      expect(playArea.containsPoint(outsidePoint), false);
    });

    test('should detect if card is over play area', () {
      final centerPoint = Vector2(
        playArea.position.x + playArea.size.x / 2,
        playArea.position.y + playArea.size.y / 2,
      );
      
      expect(playArea.isCardOver(centerPoint), true);
      
      final outsidePoint = Vector2(-10, -10);
      expect(playArea.isCardOver(outsidePoint), false);
    });
  });
}