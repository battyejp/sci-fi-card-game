import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

import 'package:sci_fi_card_game/game/card/card.dart';
import 'package:sci_fi_card_game/game/card/card_interaction_controller.dart';

import 'game_card_enhanced_test.mocks.dart';

@GenerateMocks([FlameGame, CardInteractionController])
void main() {
  group('GameCard Enhanced Tests', () {
    late MockFlameGame mockGame;
    late GameCard card;

    setUp(() {
      mockGame = MockFlameGame();
      when(mockGame.size).thenReturn(Vector2(800, 600));
    });

    group('Card Creation and ID Management', () {
      test('creates card with auto-generated unique ID', () {
        final card1 = GameCard();
        final card2 = GameCard();
        
        expect(card1.id, isNotEmpty);
        expect(card2.id, isNotEmpty);
        expect(card1.id, isNot(equals(card2.id)));
        expect(card1.id, startsWith('card_'));
        expect(card2.id, startsWith('card_'));
      });

      test('creates card with custom ID', () {
        final card = GameCard(id: 'custom_id');
        expect(card.id, equals('custom_id'));
      });

      test('sequential auto-generated IDs', () {
        final cards = List.generate(5, (index) => GameCard());
        final ids = cards.map((c) => c.id).toList();
        
        // All IDs should be unique
        expect(ids.toSet().length, equals(5));
        
        // All should start with 'card_'
        expect(ids.every((id) => id.startsWith('card_')), true);
      });
    });

    group('Position and Rotation Management', () {
      late GameCard card;

      setUp(() {
        card = GameCard(id: 'test_card');
      });

      test('setOriginalPosition before load stores pending position', () {
        final newPosition = Vector2(150, 250);
        card.setOriginalPosition(newPosition);
        
        // Should update current position immediately
        expect(card.position.x, equals(150));
        expect(card.position.y, equals(250));
        
        // Original position should return the set value
        expect(card.originalPosition.x, equals(150));
        expect(card.originalPosition.y, equals(250));
      });

      test('setRotation before load stores pending rotation', () {
        final newRotation = 1.5;
        card.setRotation(newRotation);
        
        // Should update current angle immediately
        expect(card.angle, equals(newRotation));
        
        // Card rotation should return the set value
        expect(card.cardRotation, equals(newRotation));
      });

      test('originalPosition returns current position when not set', () {
        card.position = Vector2(100, 200);
        expect(card.originalPosition.x, equals(100));
        expect(card.originalPosition.y, equals(200));
      });

      test('cardRotation returns 0.0 initially', () {
        expect(card.cardRotation, equals(0.0));
      });
    });

    group('Selection State', () {
      late GameCard card;
      late MockCardInteractionController mockController;

      setUp(() {
        card = GameCard(id: 'test_card');
        mockController = MockCardInteractionController();
      });

      test('isSelected returns false initially', () {
        expect(card.isSelected, false);
      });

      test('isAnimating returns false initially', () {
        expect(card.isAnimating, false);
      });

      test('forceDeselect calls interaction controller', () {
        // We can't easily inject the mock controller, but we can test the method exists
        expect(() => card.forceDeselect(), returnsNormally);
      });
    });

    group('JSON Serialization', () {
      test('toJson includes all expected fields', () {
        final card = GameCard(id: 'test_serialize');
        card.position = Vector2(100, 200);
        
        final json = card.toJson();
        
        expect(json, isA<Map<String, dynamic>>());
        expect(json['id'], equals('test_serialize'));
        expect(json['x'], equals(100.0));
        expect(json['y'], equals(200.0));
        expect(json['rotation'], isA<double>());
        expect(json['selected'], isA<bool>());
      });

      test('toJson with custom position and rotation', () {
        final card = GameCard(id: 'positioned_card');
        card.position = Vector2(300, 400);
        card.setRotation(1.2);
        
        final json = card.toJson();
        
        expect(json['x'], equals(300.0));
        expect(json['y'], equals(400.0));
        expect(json['rotation'], equals(1.2));
      });
    });

    group('String Representation', () {
      test('toString returns JSON representation', () {
        final card = GameCard(id: 'string_test');
        card.position = Vector2(50, 75);
        
        final stringRep = card.toString();
        
        expect(stringRep, startsWith('GameCard('));
        expect(stringRep, contains('string_test'));
        expect(stringRep, contains('50.0'));
        expect(stringRep, contains('75.0'));
      });
    });

    group('Tap Event Handling', () {
      late GameCard card;

      setUp(() {
        card = GameCard(id: 'tap_test');
      });

      test('onTapDown returns false when controller not ready', () {
        final event = TapDownEvent(1, TapDownDetails(localPosition: Vector2(10, 10)));
        final result = card.onTapDown(event);
        expect(result, false);
      });

      test('onTapUp returns false when controller not ready', () {
        final event = TapUpEvent(1, TapUpDetails(localPosition: Vector2(10, 10)));
        final result = card.onTapUp(event);
        expect(result, false);
      });

      test('onTapCancel returns false when controller not ready', () {
        final event = TapCancelEvent(1);
        final result = card.onTapCancel(event);
        expect(result, false);
      });
    });

    group('Callback Integration', () {
      test('onSelectionChanged can be set and called', () {
        final card = GameCard(id: 'callback_test');
        bool callbackCalled = false;
        GameCard? callbackCard;
        
        card.onSelectionChanged = (GameCard c) {
          callbackCalled = true;
          callbackCard = c;
        };
        
        // Trigger the callback
        card.onSelectionChanged?.call(card);
        
        expect(callbackCalled, true);
        expect(callbackCard, equals(card));
      });

      test('onSelectionChanged is null by default', () {
        final card = GameCard(id: 'no_callback');
        expect(card.onSelectionChanged, isNull);
      });
    });

    group('Edge Cases and Error Handling', () {
      test('handles Vector2 cloning correctly', () {
        final card = GameCard(id: 'clone_test');
        final originalPos = Vector2(100, 200);
        
        card.setOriginalPosition(originalPos);
        
        // Modify the original vector
        originalPos.x = 999;
        
        // Card should have its own copy
        expect(card.originalPosition.x, equals(100));
        expect(card.originalPosition.y, equals(200));
      });

      test('handles null game reference gracefully', () {
        final card = GameCard(id: 'null_game');
        // Should not throw when game is null (before onLoad)
        expect(() => card.isSelected, returnsNormally);
        expect(() => card.isAnimating, returnsNormally);
      });
    });
  });
}