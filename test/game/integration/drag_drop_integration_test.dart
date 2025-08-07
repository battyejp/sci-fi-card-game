import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:sci_fi_card_game/game/my_game.dart';
import 'package:sci_fi_card_game/game/components/card.dart';
import 'package:sci_fi_card_game/game/data/game_constants.dart';

void main() {
  group('Drag and Drop Integration Tests', () {
    late MyGame game;

    setUp(() {
      game = MyGame();
    });

    testWidgets('complete drag and drop workflow', (WidgetTester tester) async {
      await tester.pumpWidget(GameWidget.controlled(gameFactory: () => game));
      await tester.pump();
      await game.ready();

      // Verify initial setup
      expect(game.cardDeck.cards.length, GameConstants.cardCount);
      expect(game.playArea, isNotNull);
      expect(game.cardDeck.playArea, game.playArea);

      // Get the first card
      final firstCard = game.cardDeck.cards.first;
      final initialCardCount = game.cardDeck.cards.length;

      // Simulate card selection
      final tapEvent = TapDownEvent(
        1,
        TapDownInfo(
          Vector2.zero(),
          Vector2.zero(),
        ),
      );
      firstCard.onTapDown(tapEvent);
      expect(firstCard.state, CardState.selected);

      // Simulate drag start
      final dragStartEvent = DragStartEvent(
        1,
        DragStartInfo(
          Vector2.zero(),
          Vector2.zero(),
        ),
      );
      expect(firstCard.onDragStart(dragStartEvent), isTrue);

      // Simulate drag movement that exceeds threshold
      final dragUpdateEvent = DragUpdateEvent(
        1,
        DragUpdateInfo(
          Vector2(20, 20), // Exceeds threshold
          Vector2(20, 20),
          Vector2.zero(),
          Vector2.zero(),
        ),
      );
      firstCard.onDragUpdate(dragUpdateEvent);
      expect(firstCard.state, CardState.dragging);

      // Move card to play area center
      final playAreaCenter = game.playArea.centerPosition;
      firstCard.position = playAreaCenter - firstCard.size / 2;

      // Simulate drag end over play area
      final dragEndEvent = DragEndEvent(
        1,
        DragEndInfo(
          Vector2.zero(),
          Vector2.zero(),
        ),
      );
      firstCard.onDragEnd(dragEndEvent);

      // Verify card was removed from hand
      expect(game.cardDeck.cards.length, initialCardCount - 1);
      expect(game.cardDeck.cards.contains(firstCard), isFalse);
    });

    testWidgets('card returns to hand when dropped outside play area', (WidgetTester tester) async {
      await tester.pumpWidget(GameWidget.controlled(gameFactory: () => game));
      await tester.pump();
      await game.ready();

      final firstCard = game.cardDeck.cards.first;
      final initialCardCount = game.cardDeck.cards.length;
      final originalPosition = firstCard.originalPosition;

      // Select and start dragging the card
      final tapEvent = TapDownEvent(
        1,
        TapDownInfo(
          Vector2.zero(),
          Vector2.zero(),
        ),
      );
      firstCard.onTapDown(tapEvent);

      final dragStartEvent = DragStartEvent(
        1,
        DragStartInfo(
          Vector2.zero(),
          Vector2.zero(),
        ),
      );
      firstCard.onDragStart(dragStartEvent);

      // Exceed drag threshold
      final dragUpdateEvent = DragUpdateEvent(
        1,
        DragUpdateInfo(
          Vector2(20, 20),
          Vector2(20, 20),
          Vector2.zero(),
          Vector2.zero(),
        ),
      );
      firstCard.onDragUpdate(dragUpdateEvent);
      expect(firstCard.state, CardState.dragging);

      // Move card outside play area
      firstCard.position = Vector2(10, 10); // Far from play area

      // End drag
      final dragEndEvent = DragEndEvent(
        1,
        DragEndInfo(
          Vector2.zero(),
          Vector2.zero(),
        ),
      );
      firstCard.onDragEnd(dragEndEvent);

      // Verify card was not removed and returned to hand
      expect(game.cardDeck.cards.length, initialCardCount);
      expect(game.cardDeck.cards.contains(firstCard), isTrue);
      expect(firstCard.state, CardState.idle);
    });

    testWidgets('play area highlights when card is dragged over it', (WidgetTester tester) async {
      await tester.pumpWidget(GameWidget.controlled(gameFactory: () => game));
      await tester.pump();
      await game.ready();

      final firstCard = game.cardDeck.cards.first;
      
      // Initially play area should not be highlighted
      expect(game.playArea.isHighlighted, isFalse);

      // Select and start dragging
      final tapEvent = TapDownEvent(
        1,
        TapDownInfo(
          Vector2.zero(),
          Vector2.zero(),
        ),
      );
      firstCard.onTapDown(tapEvent);

      final dragStartEvent = DragStartEvent(
        1,
        DragStartInfo(
          Vector2.zero(),
          Vector2.zero(),
        ),
      );
      firstCard.onDragStart(dragStartEvent);

      // Start dragging
      final dragUpdateEvent = DragUpdateEvent(
        1,
        DragUpdateInfo(
          Vector2(20, 20),
          Vector2(20, 20),
          Vector2.zero(),
          Vector2.zero(),
        ),
      );
      firstCard.onDragUpdate(dragUpdateEvent);

      // Move card over play area
      final playAreaCenter = game.playArea.centerPosition;
      firstCard.position = playAreaCenter - firstCard.size / 2;

      // Simulate another drag update to trigger highlight check
      final dragUpdateOverPlayArea = DragUpdateEvent(
        1,
        DragUpdateInfo(
          playAreaCenter,
          Vector2(1, 1),
          Vector2.zero(),
          Vector2.zero(),
        ),
      );
      firstCard.onDragUpdate(dragUpdateOverPlayArea);

      // Play area should now be highlighted
      expect(game.playArea.isHighlighted, isTrue);

      // Move card away from play area
      firstCard.position = Vector2(10, 10);
      final dragUpdateAwayFromPlayArea = DragUpdateEvent(
        1,
        DragUpdateInfo(
          Vector2(10, 10),
          Vector2(-5, -5),
          Vector2.zero(),
          Vector2.zero(),
        ),
      );
      firstCard.onDragUpdate(dragUpdateAwayFromPlayArea);

      // Play area should no longer be highlighted
      expect(game.playArea.isHighlighted, isFalse);
    });

    test('multiple cards can be selected but only one at a time', () async {
      await game.ready();

      final firstCard = game.cardDeck.cards.first;
      final secondCard = game.cardDeck.cards[1];

      // Select first card
      final tapEvent1 = TapDownEvent(
        1,
        TapDownInfo(
          Vector2.zero(),
          Vector2.zero(),
        ),
      );
      firstCard.onTapDown(tapEvent1);
      expect(firstCard.state, CardState.selected);
      expect(game.cardDeck.selectedCard, firstCard);

      // Select second card - should deselect first
      final tapEvent2 = TapDownEvent(
        1,
        TapDownInfo(
          Vector2.zero(),
          Vector2.zero(),
        ),
      );
      secondCard.onTapDown(tapEvent2);
      expect(secondCard.state, CardState.selected);
      expect(firstCard.state, CardState.idle);
      expect(game.cardDeck.selectedCard, secondCard);
    });
  });
}