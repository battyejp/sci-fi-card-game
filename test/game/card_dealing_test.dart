import 'package:flutter_test/flutter_test.dart';
import 'package:sci_fi_card_game/game/data/game_constants.dart';
import 'package:sci_fi_card_game/game/deck/card_deck.dart';
import 'package:sci_fi_card_game/game/deck/card_hand.dart';
import 'package:sci_fi_card_game/game/my_game.dart';

void main() {
  group('Card Dealing Tests', () {
    test('GameConstants should have correct initial values for dealing', () {
      expect(GameConstants.cardCount, equals(0)); // Hand starts empty
      expect(GameConstants.dealCardCount, equals(5)); // Deal 5 cards
      expect(GameConstants.deckPileCount, equals(20)); // Deck has 20 cards
    });

    test('CardDeck should start with correct number of cards', () {
      final deck = CardDeck();
      expect(deck.controller.cardCount, equals(GameConstants.deckPileCount));
    });

    test('CardHand should start empty', () {
      final hand = CardHand();
      expect(hand.controller.cardCount, equals(0));
    });

    test('CardDeck dealCards should reduce card count', () {
      final deck = CardDeck();
      final initialCount = deck.cardCount;
      
      final success = deck.dealCards(5);
      
      expect(success, isTrue);
      expect(deck.cardCount, equals(initialCount - 5));
    });

    test('CardDeck dealCards should fail if not enough cards', () {
      final deck = CardDeck();
      
      // Try to deal more cards than available
      final success = deck.dealCards(deck.cardCount + 1);
      
      expect(success, isFalse);
    });
  });

  group('Layout Constants Tests', () {
    test('Deck positioning constants should be reasonable', () {
      expect(GameConstants.deckPileLeftMargin, greaterThan(0));
      expect(GameConstants.deckPileBottomMargin, greaterThan(0));
      expect(GameConstants.deckPileCardOffset, greaterThan(0));
    });

    test('Card dimensions should be positive', () {
      expect(GameConstants.handCardWidth, greaterThan(0));
      expect(GameConstants.handCardHeight, greaterThan(0));
    });
  });
}