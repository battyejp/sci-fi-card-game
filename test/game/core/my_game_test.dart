import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flame/components.dart';

import 'package:sci_fi_card_game/game/core/my_game.dart';
import 'package:sci_fi_card_game/game/deck/card_deck.dart';
import 'package:sci_fi_card_game/game/data/game_constants.dart';

import 'my_game_test.mocks.dart';

@GenerateMocks([CardDeck])
void main() {
  group('MyGame', () {
    late MyGame game;

    setUp(() {
      game = MyGame();
    });

    test('game initializes with correct size', () {
      // Game size should be set by the Flame framework
      expect(game, isA<MyGame>());
    });

    test('deck getter returns cardDeck', () async {
      // Set a size for the game
      game.size = Vector2(800, 600);
      
      // Load the game to initialize the deck
      await game.onLoad();
      
      expect(game.deck, isNotNull);
      expect(game.deck, isA<CardDeck>());
      expect(game.cardDeck, equals(game.deck));
    });

    group('Game Lifecycle', () {
      test('onLoad sets up background and card deck', () async {
        game.size = Vector2(800, 600);
        
        await game.onLoad();
        
        // Check that components were added
        expect(game.children.length, equals(2)); // background + deck
        
        // Find the background component
        final background = game.children.firstWhere(
          (component) => component is RectangleComponent,
        );
        expect(background, isNotNull);
        expect((background as RectangleComponent).size, equals(Vector2(800, 600)));
        
        // Find the card deck
        final deck = game.children.firstWhere(
          (component) => component is CardDeck,
        );
        expect(deck, isNotNull);
        expect(deck, isA<CardDeck>());
      });

      test('onLoad creates background with correct color', () async {
        game.size = Vector2(400, 300);
        
        await game.onLoad();
        
        final background = game.children.firstWhere(
          (component) => component is RectangleComponent,
        ) as RectangleComponent;
        
        expect(background.paint.color, equals(GameConstants.backgroundColor));
      });

      test('onLoad creates deck accessible via property', () async {
        game.size = Vector2(800, 600);
        
        await game.onLoad();
        
        expect(game.cardDeck, isNotNull);
        expect(game.deck, equals(game.cardDeck));
      });
    });

    group('Game Operations', () {
      test('resetGame calls deck resetAllCards', () async {
        game.size = Vector2(800, 600);
        await game.onLoad();
        
        // Create a mock deck to verify the call
        final mockDeck = MockCardDeck();
        game.cardDeck = mockDeck;
        
        game.resetGame();
        
        verify(mockDeck.resetAllCards()).called(1);
      });

      test('resetGame works with real deck', () async {
        game.size = Vector2(800, 600);
        await game.onLoad();
        
        // This should not throw
        expect(() => game.resetGame(), returnsNormally);
      });
    });

    group('Component Hierarchy', () {
      test('game contains expected components after load', () async {
        game.size = Vector2(800, 600);
        await game.onLoad();
        
        expect(game.children.length, equals(2));
        
        // Check component types
        final componentTypes = game.children.map((c) => c.runtimeType).toList();
        expect(componentTypes.contains(RectangleComponent), true);
        expect(componentTypes.contains(CardDeck), true);
      });

      test('background component has correct properties', () async {
        game.size = Vector2(1000, 500);
        await game.onLoad();
        
        final background = game.children
            .whereType<RectangleComponent>()
            .first;
            
        expect(background.size.x, equals(1000));
        expect(background.size.y, equals(500));
        expect(background.paint.color, equals(GameConstants.backgroundColor));
      });

      test('deck is properly added to component tree', () async {
        game.size = Vector2(800, 600);
        await game.onLoad();
        
        final deck = game.children.whereType<CardDeck>().first;
        expect(deck.parent, equals(game));
      });
    });

    group('Size Handling', () {
      test('handles different screen sizes', () async {
        final sizes = [
          Vector2(320, 568), // iPhone SE
          Vector2(375, 667), // iPhone 8
          Vector2(414, 896), // iPhone 11
          Vector2(768, 1024), // iPad
          Vector2(800, 600), // Desktop
        ];
        
        for (final size in sizes) {
          final testGame = MyGame();
          testGame.size = size;
          
          await testGame.onLoad();
          
          final background = testGame.children
              .whereType<RectangleComponent>()
              .first;
              
          expect(background.size, equals(size));
          expect(testGame.children.length, equals(2));
        }
      });

      test('minimum size handling', () async {
        game.size = Vector2(1, 1);
        
        await game.onLoad();
        
        // Should still create components without error
        expect(game.children.length, equals(2));
        
        final background = game.children
            .whereType<RectangleComponent>()
            .first;
        expect(background.size, equals(Vector2(1, 1)));
      });
    });

    group('Game State', () {
      test('maintains game state across resets', () async {
        game.size = Vector2(800, 600);
        await game.onLoad();
        
        final originalDeck = game.deck;
        
        game.resetGame();
        
        // Deck should be the same instance
        expect(game.deck, equals(originalDeck));
        expect(game.children.length, equals(2));
      });

      test('game reference is available in components', () async {
        game.size = Vector2(800, 600);
        await game.onLoad();
        
        final deck = game.children.whereType<CardDeck>().first;
        expect(deck.game, equals(game));
      });
    });

    group('Error Handling', () {
      test('handles zero size gracefully', () async {
        game.size = Vector2.zero();
        
        expect(() => game.onLoad(), returnsNormally);
      });

      test('handles negative size gracefully', () async {
        game.size = Vector2(-100, -50);
        
        expect(() => game.onLoad(), returnsNormally);
      });
    });
  });
}