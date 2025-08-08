import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

import 'package:sci_fi_card_game/game/card/card_interaction_controller.dart';
import 'package:sci_fi_card_game/game/card/card.dart';
import 'package:sci_fi_card_game/game/deck/card_deck.dart';

import 'card_interaction_controller_test.mocks.dart';

@GenerateMocks([GameCard, FlameGame, CardDeck])
void main() {
  group('CardInteractionController', () {
    late MockGameCard mockCard;
    late MockFlameGame mockGame;
    late CardInteractionController controller;

    setUp(() {
      mockCard = MockGameCard();
      mockGame = MockFlameGame();
      controller = CardInteractionController(mockCard);

      // Setup default mock behaviors
      when(mockCard.size).thenReturn(Vector2(90, 135));
      when(mockCard.position).thenReturn(Vector2(100, 200));
      when(mockCard.game).thenReturn(mockGame);
      when(mockGame.size).thenReturn(Vector2(800, 600));
      when(mockCard.originalPosition).thenReturn(Vector2(100, 200));
      when(mockCard.cardRotation).thenReturn(0.0);
    });

    test('initial state is not selected and not animating', () {
      expect(controller.isSelected, false);
      expect(controller.isAnimating, false);
    });

    test('initialize sets up controller state', () {
      controller.initialize();
      // Should complete without throwing - initialization sets internal state
      expect(controller.isSelected, false);
      expect(controller.isAnimating, false);
    });

    group('onTapDown', () {
      setUp(() {
        controller.initialize();
      });

      test('returns true when not animating', () {
        final event = TapDownEvent(1, TapDownDetails(localPosition: Vector2(10, 10)));
        final result = controller.onTapDown(event);
        expect(result, true);
      });

      test('does not trigger selection when already animating', () {
        // Simulate animating state
        controller.initialize();
        
        // First tap to start selection
        final event1 = TapDownEvent(1, TapDownDetails(localPosition: Vector2(10, 10)));
        controller.onTapDown(event1);
        
        // Verify card is being selected
        verify(mockCard.onSelectionChanged?.call(mockCard)).called(1);
        
        // Second tap while animating should not trigger another selection
        final event2 = TapDownEvent(1, TapDownDetails(localPosition: Vector2(20, 20)));
        controller.onTapDown(event2);
        
        // Should still only be called once
        verify(mockCard.onSelectionChanged?.call(mockCard)).called(1);
      });
    });

    group('onTapUp', () {
      setUp(() {
        controller.initialize();
      });

      test('returns true', () {
        final event = TapUpEvent(1, TapUpDetails(localPosition: Vector2(10, 10)));
        final result = controller.onTapUp(event);
        expect(result, true);
      });

      test('deselects when selected and not animating', () {
        // First select the card
        final tapDown = TapDownEvent(1, TapDownDetails(localPosition: Vector2(10, 10)));
        controller.onTapDown(tapDown);
        
        // Simulate selection animation completed
        expect(controller.isSelected, true);
        
        // Now tap up should trigger deselection
        final tapUp = TapUpEvent(1, TapUpDetails(localPosition: Vector2(10, 10)));
        controller.onTapUp(tapUp);
        
        // Should have triggered effects on the mock card
        verify(mockCard.add(any)).called(greaterThan(0));
      });
    });

    group('onTapCancel', () {
      setUp(() {
        controller.initialize();
      });

      test('returns true', () {
        final event = TapCancelEvent(1);
        final result = controller.onTapCancel(event);
        expect(result, true);
      });

      test('deselects when selected and not animating', () {
        // First select the card
        final tapDown = TapDownEvent(1, TapDownDetails(localPosition: Vector2(10, 10)));
        controller.onTapDown(tapDown);
        
        expect(controller.isSelected, true);
        
        // Cancel should trigger deselection
        final cancel = TapCancelEvent(1);
        controller.onTapCancel(cancel);
        
        // Should have triggered effects on the mock card
        verify(mockCard.add(any)).called(greaterThan(0));
      });
    });

    group('forceDeselect', () {
      setUp(() {
        controller.initialize();
      });

      test('deselects when selected and not animating', () {
        // First select the card
        final tapDown = TapDownEvent(1, TapDownDetails(localPosition: Vector2(10, 10)));
        controller.onTapDown(tapDown);
        
        expect(controller.isSelected, true);
        
        // Force deselect
        controller.forceDeselect();
        
        // Should have triggered effects on the mock card
        verify(mockCard.add(any)).called(greaterThan(0));
      });

      test('does nothing when not selected', () {
        controller.forceDeselect();
        
        // Should not have triggered any effects
        verifyNever(mockCard.add(any));
      });
    });

    group('selection behavior', () {
      setUp(() {
        controller.initialize();
      });

      test('selection sets priority and triggers callback', () {
        final event = TapDownEvent(1, TapDownDetails(localPosition: Vector2(10, 10)));
        controller.onTapDown(event);
        
        // Should set selected state
        expect(controller.isSelected, true);
        expect(controller.isAnimating, true);
        
        // Should set priority and trigger callback
        verify(mockCard.onSelectionChanged?.call(mockCard)).called(1);
        verify(mockCard.add(any)).called(3); // move, scale, rotate effects
      });

      test('handles card at bottom edge of screen', () {
        // Position card near bottom of screen
        when(mockCard.position).thenReturn(Vector2(100, 550));
        
        final event = TapDownEvent(1, TapDownDetails(localPosition: Vector2(10, 10)));
        controller.onTapDown(event);
        
        // Should still handle the selection
        expect(controller.isSelected, true);
        verify(mockCard.add(any)).called(3);
      });

      test('handles card at top edge of screen', () {
        // Position card near top of screen
        when(mockCard.position).thenReturn(Vector2(100, 50));
        
        final event = TapDownEvent(1, TapDownDetails(localPosition: Vector2(10, 10)));
        controller.onTapDown(event);
        
        // Should still handle the selection
        expect(controller.isSelected, true);
        verify(mockCard.add(any)).called(3);
      });
    });

    group('deselection behavior', () {
      setUp(() {
        controller.initialize();
      });

      test('deselection restores original position and rotation', () {
        final mockDeck = MockCardDeck();
        when(mockCard.parent).thenReturn(mockDeck);
        when(mockDeck.getCardPriority(mockCard)).thenReturn(5);
        
        // First select
        final tapDown = TapDownEvent(1, TapDownDetails(localPosition: Vector2(10, 10)));
        controller.onTapDown(tapDown);
        
        // Then deselect
        final tapUp = TapUpEvent(1, TapUpDetails(localPosition: Vector2(10, 10)));
        controller.onTapUp(tapUp);
        
        // Should restore priority from deck
        verify(mockDeck.getCardPriority(mockCard)).called(1);
        
        // Should add effects to restore position, scale, rotation
        verify(mockCard.add(any)).called(6); // 3 for select + 3 for deselect
      });

      test('handles deselection without CardDeck parent', () {
        when(mockCard.parent).thenReturn(Component());
        
        // First select
        final tapDown = TapDownEvent(1, TapDownDetails(localPosition: Vector2(10, 10)));
        controller.onTapDown(tapDown);
        
        // Then deselect
        final tapUp = TapUpEvent(1, TapUpDetails(localPosition: Vector2(10, 10)));
        controller.onTapUp(tapUp);
        
        // Should still handle deselection gracefully
        verify(mockCard.add(any)).called(6); // 3 for select + 3 for deselect
      });
    });
  });
}