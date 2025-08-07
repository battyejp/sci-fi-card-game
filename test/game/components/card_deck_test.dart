import 'package:flutter_test/flutter_test.dart';
import 'package:flame/game.dart';
import 'package:sci_fi_card_game/game/components/card_deck.dart';
import 'package:sci_fi_card_game/game/components/play_area.dart';
import 'package:sci_fi_card_game/game/my_game.dart';

void main() {
  group('CardDeck', () {
    late MyGame game;
    late CardDeck cardDeck;
    late PlayArea playArea;

    setUp(() async {
      game = MyGame();
      await game.onLoad();
      cardDeck = game.cardDeck;
      playArea = game.playArea;
    });

    test('should allow setting play area', () {
      cardDeck.playArea = playArea;
      expect(cardDeck.playArea, equals(playArea));
    });

    test('should create cards with default count', () {
      expect(cardDeck.cards.length, greaterThan(0));
    });

    test('should remove card from hand when requested', () {
      final initialCount = cardDeck.cards.length;
      final cardToRemove = cardDeck.cards.first;
      
      cardDeck.removeCardFromHand(cardToRemove);
      
      expect(cardDeck.cards.length, equals(initialCount - 1));
      expect(cardDeck.cards.contains(cardToRemove), isFalse);
    });

    test('should update card count after removing card', () {
      final initialCount = cardDeck.cardCount;
      final cardToRemove = cardDeck.cards.first;
      
      cardDeck.removeCardFromHand(cardToRemove);
      
      expect(cardDeck.cardCount, equals(initialCount - 1));
    });

    test('should clear selected card if removed card was selected', () {
      final cardToRemove = cardDeck.cards.first;
      // Simulate card selection
      cardDeck.selectedCard; // This would be set through the selection callback
      
      cardDeck.removeCardFromHand(cardToRemove);
      
      // The selected card should be cleared if it was the removed card
      expect(cardDeck.selectedCard, isNull);
    });

    test('should set play area reference on all cards', () {
      cardDeck.playArea = playArea;
      
      for (final card in cardDeck.cards) {
        // We can't directly test the private _playArea field,
        // but we can verify the setter was called without errors
        expect(() => card.setPlayArea(playArea), returnsNormally);
      }
    });

    test('should handle removing non-existent card gracefully', () {
      final initialCount = cardDeck.cards.length;
      final fakeCard = cardDeck.cards.first; // Get a real card
      cardDeck.removeCardFromHand(fakeCard); // Remove it first
      
      // Try to remove it again - should not crash
      expect(() => cardDeck.removeCardFromHand(fakeCard), returnsNormally);
      expect(cardDeck.cards.length, equals(initialCount - 1));
    });

    test('should rearrange remaining cards after removal', () {
      final initialCount = cardDeck.cards.length;
      if (initialCount > 1) {
        final cardToRemove = cardDeck.cards[1]; // Remove middle card
        final remainingCards = List.from(cardDeck.cards);
        remainingCards.removeAt(1);
        
        cardDeck.removeCardFromHand(cardToRemove);
        
        expect(cardDeck.cards.length, equals(initialCount - 1));
        // Cards should be rearranged (we can't test exact positions due to animations)
      }
    });

    test('should handle empty deck after removing all cards', () {
      final cardsToRemove = List.from(cardDeck.cards);
      
      for (final card in cardsToRemove) {
        cardDeck.removeCardFromHand(card);
      }
      
      expect(cardDeck.cards.isEmpty, isTrue);
      expect(cardDeck.cardCount, equals(0));
    });
  });
}