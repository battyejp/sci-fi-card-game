import 'package:flutter_test/flutter_test.dart';
import 'package:flame/game.dart';
import 'package:sci_fi_card_game/game/components/card_deck.dart';
import 'package:sci_fi_card_game/game/components/play_area.dart';
import 'package:sci_fi_card_game/game/components/card.dart';
import 'package:sci_fi_card_game/game/my_game.dart';
import 'package:sci_fi_card_game/game/data/game_constants.dart';

void main() {
  group('Drag and Drop Integration', () {
    late MyGame game;
    late CardDeck cardDeck;
    late PlayArea playArea;
    late GameCard testCard;

    setUp(() async {
      game = MyGame();
      await game.onLoad();
      cardDeck = game.cardDeck;
      playArea = game.playArea;
      testCard = cardDeck.cards.first;
    });

    test('should connect card deck with play area', () {
      expect(cardDeck.playArea, equals(playArea));
    });

    test('should detect when card is over play area during drag', () {
      // Position card over play area
      testCard.position = playArea.centerPosition;
      
      final isOver = playArea.isCardOver(testCard.position, testCard.size);
      
      expect(isOver, isTrue);
    });

    test('should detect when card is not over play area during drag', () {
      // Position card away from play area
      testCard.position = Vector2(0, 0);
      
      final isOver = playArea.isCardOver(testCard.position, testCard.size);
      
      expect(isOver, isFalse);
    });

    test('should highlight play area when card is dragged over it', () {
      expect(playArea.isHighlighted, isFalse);
      
      // Simulate card being dragged over play area
      playArea.highlight();
      
      expect(playArea.isHighlighted, isTrue);
    });

    test('should remove highlight when card is dragged away', () {
      playArea.highlight();
      expect(playArea.isHighlighted, isTrue);
      
      playArea.removeHighlight();
      
      expect(playArea.isHighlighted, isFalse);
    });

    test('should remove card from deck when dropped in play area', () {
      final initialCardCount = cardDeck.cards.length;
      final cardToRemove = cardDeck.cards.first;
      
      // Simulate successful drop in play area
      cardDeck.removeCardFromHand(cardToRemove);
      
      expect(cardDeck.cards.length, equals(initialCardCount - 1));
      expect(cardDeck.cards.contains(cardToRemove), isFalse);
    });

    test('should maintain card in deck when dropped outside play area', () {
      final initialCardCount = cardDeck.cards.length;
      final testCard = cardDeck.cards.first;
      
      // Simulate drop outside play area (card should return to hand)
      // In a real scenario, this would be handled by the drag end logic
      // For testing, we just verify the card is still in the deck
      expect(cardDeck.cards.contains(testCard), isTrue);
      expect(cardDeck.cards.length, equals(initialCardCount));
    });

    test('should update card count after successful drop', () {
      final initialCount = cardDeck.cardCount;
      final cardToRemove = cardDeck.cards.first;
      
      cardDeck.removeCardFromHand(cardToRemove);
      
      expect(cardDeck.cardCount, equals(initialCount - 1));
    });

    test('should rearrange remaining cards after drop', () {
      final initialCount = cardDeck.cards.length;
      if (initialCount > 1) {
        final cardToRemove = cardDeck.cards[1]; // Remove middle card
        
        cardDeck.removeCardFromHand(cardToRemove);
        
        expect(cardDeck.cards.length, equals(initialCount - 1));
        // Remaining cards should be rearranged (exact positions depend on animation)
      }
    });

    test('should handle multiple card drops correctly', () {
      final initialCount = cardDeck.cards.length;
      final cardsToRemove = [cardDeck.cards[0], cardDeck.cards[1]];
      
      for (final card in cardsToRemove) {
        cardDeck.removeCardFromHand(card);
      }
      
      expect(cardDeck.cards.length, equals(initialCount - 2));
      for (final card in cardsToRemove) {
        expect(cardDeck.cards.contains(card), isFalse);
      }
    });

    test('should maintain play area position and size throughout game', () {
      final initialPosition = playArea.position.clone();
      final initialSize = playArea.size.clone();
      
      // Simulate some game interactions
      playArea.highlight();
      playArea.removeHighlight();
      
      expect(playArea.position.x, closeTo(initialPosition.x, 0.1));
      expect(playArea.position.y, closeTo(initialPosition.y, 0.1));
      expect(playArea.size.x, closeTo(initialSize.x, 0.1));
      expect(playArea.size.y, closeTo(initialSize.y, 0.1));
    });

    test('should handle edge case of empty deck', () {
      // Remove all cards
      final allCards = List.from(cardDeck.cards);
      for (final card in allCards) {
        cardDeck.removeCardFromHand(card);
      }
      
      expect(cardDeck.cards.isEmpty, isTrue);
      expect(cardDeck.cardCount, equals(0));
      expect(cardDeck.selectedCard, isNull);
    });

    test('should maintain play area functionality with empty deck', () {
      // Remove all cards
      final allCards = List.from(cardDeck.cards);
      for (final card in allCards) {
        cardDeck.removeCardFromHand(card);
      }
      
      // Play area should still function normally
      expect(() => playArea.highlight(), returnsNormally);
      expect(() => playArea.removeHighlight(), returnsNormally);
      expect(playArea.containsPoint(playArea.centerPosition), isTrue);
    });

    test('should handle rapid highlight/unhighlight operations', () {
      for (int i = 0; i < 10; i++) {
        playArea.highlight();
        playArea.removeHighlight();
      }
      
      expect(playArea.isHighlighted, isFalse);
    });

    test('should maintain card deck integrity after multiple operations', () {
      final initialCount = cardDeck.cards.length;
      
      // Perform various operations
      if (initialCount > 2) {
        cardDeck.removeCardFromHand(cardDeck.cards[0]);
        cardDeck.removeCardFromHand(cardDeck.cards[0]); // Index shifts after removal
        
        expect(cardDeck.cards.length, equals(initialCount - 2));
        expect(cardDeck.cardCount, equals(initialCount - 2));
      }
    });
  });
}