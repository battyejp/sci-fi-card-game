import 'package:flutter_test/flutter_test.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:sci_fi_card_game/game/components/card.dart';
import 'package:sci_fi_card_game/game/components/card_deck.dart';
import 'package:sci_fi_card_game/game/components/play_area.dart';
import 'package:sci_fi_card_game/game/data/game_constants.dart';

void main() {
  group('GameCard Drag and Drop', () {
    late FlameGame game;
    late GameCard card;
    late CardDeck cardDeck;
    late PlayArea playArea;

    setUp(() {
      game = FlameGame();
      card = GameCard();
      cardDeck = CardDeck();
      playArea = PlayArea();
      cardDeck.playArea = playArea;
    });

    test('initial state is idle', () async {
      game.add(card);
      await game.ready();

      expect(card.state, CardState.idle);
      expect(card.isSelected, isFalse);
      expect(card.isDragging, isFalse);
    });

    test('tap changes state to selected', () async {
      game.add(card);
      await game.ready();

      final tapEvent = TapDownEvent(
        1,
        TapDownInfo(
          Vector2.zero(),
          Vector2.zero(),
        ),
      );

      card.onTapDown(tapEvent);
      expect(card.state, CardState.selected);
      expect(card.isSelected, isTrue);
    });

    test('forceDeselect changes selected card back to idle', () async {
      game.add(card);
      await game.ready();

      // First select the card
      final tapEvent = TapDownEvent(
        1,
        TapDownInfo(
          Vector2.zero(),
          Vector2.zero(),
        ),
      );
      card.onTapDown(tapEvent);
      expect(card.state, CardState.selected);

      // Then force deselect
      card.forceDeselect();
      expect(card.state, CardState.idle);
    });

    test('drag start only works when card is selected', () async {
      cardDeck.add(card);
      game.add(cardDeck);
      await game.ready();

      final dragStartEvent = DragStartEvent(
        1,
        DragStartInfo(
          Vector2.zero(),
          Vector2.zero(),
        ),
      );

      // Should not start drag when idle
      expect(card.onDragStart(dragStartEvent), isFalse);

      // Select the card first
      final tapEvent = TapDownEvent(
        1,
        TapDownInfo(
          Vector2.zero(),
          Vector2.zero(),
        ),
      );
      card.onTapDown(tapEvent);

      // Now drag should work
      expect(card.onDragStart(dragStartEvent), isTrue);
    });

    test('drag threshold must be met to start dragging', () async {
      cardDeck.add(card);
      game.add(cardDeck);
      await game.ready();

      // Select the card
      final tapEvent = TapDownEvent(
        1,
        TapDownInfo(
          Vector2.zero(),
          Vector2.zero(),
        ),
      );
      card.onTapDown(tapEvent);

      // Start drag
      final dragStartEvent = DragStartEvent(
        1,
        DragStartInfo(
          Vector2.zero(),
          Vector2.zero(),
        ),
      );
      card.onDragStart(dragStartEvent);

      // Small movement should not trigger dragging
      final smallDragUpdate = DragUpdateEvent(
        1,
        DragUpdateInfo(
          Vector2(5, 5), // Less than threshold
          Vector2(1, 1),
          Vector2.zero(),
          Vector2.zero(),
        ),
      );
      card.onDragUpdate(smallDragUpdate);
      expect(card.state, CardState.selected);

      // Large movement should trigger dragging
      final largeDragUpdate = DragUpdateEvent(
        1,
        DragUpdateInfo(
          Vector2(20, 20), // Greater than threshold
          Vector2(15, 15),
          Vector2.zero(),
          Vector2.zero(),
        ),
      );
      card.onDragUpdate(largeDragUpdate);
      expect(card.state, CardState.dragging);
    });

    test('getters return correct values for different states', () async {
      game.add(card);
      await game.ready();

      // Test idle state
      expect(card.isSelected, isFalse);
      expect(card.isDragging, isFalse);
      expect(card.state, CardState.idle);

      // Test selected state
      final tapEvent = TapDownEvent(
        1,
        TapDownInfo(
          Vector2.zero(),
          Vector2.zero(),
        ),
      );
      card.onTapDown(tapEvent);
      expect(card.isSelected, isTrue);
      expect(card.isDragging, isFalse);
      expect(card.state, CardState.selected);
    });

    test('originalPosition and cardRotation getters work correctly', () async {
      game.add(card);
      await game.ready();

      final testPosition = Vector2(100, 200);
      final testRotation = 0.5;

      card.setOriginalPosition(testPosition);
      card.setRotation(testRotation);

      expect(card.originalPosition, testPosition);
      expect(card.cardRotation, testRotation);
    });
  });
}