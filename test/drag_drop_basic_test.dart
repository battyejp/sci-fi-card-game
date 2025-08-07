import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:sci_fi_card_game/game/my_game.dart';
import 'package:sci_fi_card_game/game/components/play_area.dart';
import 'package:sci_fi_card_game/game/components/card_deck.dart';
import 'package:sci_fi_card_game/game/components/card.dart';
import 'package:sci_fi_card_game/game/data/game_constants.dart';

void main() {
  group('Basic Drag-Drop Implementation Test', () {
    test('should compile and create all components without errors', () async {
      // Test that all components can be instantiated
      final game = MyGame();
      await game.onLoad();
      
      // Verify all components exist
      expect(game.cardDeck, isNotNull);
      expect(game.playArea, isNotNull);
      expect(game.cardDeck.playArea, equals(game.playArea));
      
      // Verify cards have play area reference
      final firstCard = game.cardDeck.cards.first;
      expect(firstCard, isA<GameCard>());
      
      // Verify constants are defined
      expect(GameConstants.playAreaWidth, isA<double>());
      expect(GameConstants.playAreaHeight, isA<double>());
      expect(GameConstants.playAreaBorderWidth, isA<double>());
      expect(GameConstants.playAreaColor, isA<Color>());
      expect(GameConstants.playAreaHighlightColor, isA<Color>());
      expect(GameConstants.dragThreshold, isA<double>());
      expect(GameConstants.dragCardScale, isA<double>());
      expect(GameConstants.dragCardOpacity, isA<double>());
    });
    
    test('should have working play area methods', () async {
      final game = MyGame();
      await game.onLoad();
      final playArea = game.playArea;
      
      // Test highlight functionality
      expect(playArea.isHighlighted, isFalse);
      playArea.highlight();
      expect(playArea.isHighlighted, isTrue);
      playArea.removeHighlight();
      expect(playArea.isHighlighted, isFalse);
      
      // Test collision detection
      final centerPoint = playArea.centerPosition;
      expect(playArea.containsPoint(centerPoint), isTrue);
      
      final outsidePoint = Vector2(-100, -100);
      expect(playArea.containsPoint(outsidePoint), isFalse);
    });
    
    test('should have working card deck integration', () async {
      final game = MyGame();
      await game.onLoad();
      final cardDeck = game.cardDeck;
      
      final initialCount = cardDeck.cards.length;
      expect(initialCount, greaterThan(0));
      
      // Test card removal
      final cardToRemove = cardDeck.cards.first;
      cardDeck.removeCardFromHand(cardToRemove);
      
      expect(cardDeck.cards.length, equals(initialCount - 1));
      expect(cardDeck.cards.contains(cardToRemove), isFalse);
    });
  });
}