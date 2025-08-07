import 'package:flutter_test/flutter_test.dart';
import 'package:flame/game.dart';
import 'package:sci_fi_card_game/game/components/card.dart';
import 'package:sci_fi_card_game/game/components/play_area.dart';
import 'package:sci_fi_card_game/game/components/card_deck.dart';
import 'package:sci_fi_card_game/game/my_game.dart';

void main() {
  group('Drag and Drop Integration', () {
    late MyGame game;
    late GameCard card;
    late PlayArea playArea;
    late CardDeck cardDeck;

    setUp(() async {
      game = MyGame();
      await game.onLoad();
      
      card = GameCard();
      await card.onLoad();
      
      cardDeck = game.deck;
      playArea = game.area;
      
      // Add card to deck
      cardDeck.cards.add(card);
      game.add(card);
    });

    test('should have play area and card deck initialized', () {
      expect(playArea, isNotNull);
      expect(cardDeck, isNotNull);
      expect(card, isNotNull);
    });

    test('should detect when card is over play area', () {
      // Position card at play area center
      final playAreaCenter = Vector2(
        playArea.position.x + playArea.size.x / 2,
        playArea.position.y + playArea.size.y / 2,
      );
      
      expect(playArea.isCardOver(playAreaCenter), true);
      
      // Position card outside play area
      final outsidePosition = Vector2(-50, -50);
      expect(playArea.isCardOver(outsidePosition), false);
    });

    test('should highlight play area when requested', () {
      expect(playArea.isHighlighted, false);
      
      playArea.highlight();
      expect(playArea.isHighlighted, true);
      
      playArea.removeHighlight();
      expect(playArea.isHighlighted, false);
    });

    test('should be able to remove card from deck', () {
      final initialCardCount = cardDeck.cards.length;
      
      cardDeck.removeCard(card);
      
      expect(cardDeck.cards.length, equals(initialCardCount - 1));
      expect(cardDeck.cards.contains(card), false);
    });

    test('should maintain card properties during operations', () {
      final originalPosition = card.originalPosition;
      final cardRotation = card.cardRotation;
      
      expect(originalPosition, isA<Vector2>());
      expect(cardRotation, isA<double>());
      expect(card.isSelected, false);
      expect(card.isAnimating, false);
      expect(card.isDragging, false);
    });

    test('should handle card positioning correctly', () {
      final newPosition = Vector2(100, 200);
      card.setOriginalPosition(newPosition);
      
      expect(card.originalPosition, equals(newPosition));
      expect(card.position, equals(newPosition));
    });

    test('should handle card rotation correctly', () {
      const newRotation = 1.5;
      card.setRotation(newRotation);
      
      expect(card.cardRotation, equals(newRotation));
      expect(card.angle, equals(newRotation));
    });
  });
}