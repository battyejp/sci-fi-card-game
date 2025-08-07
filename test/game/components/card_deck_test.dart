import 'package:flutter_test/flutter_test.dart';
import 'package:flame/game.dart';
import 'package:sci_fi_card_game/game/components/card_deck.dart';
import 'package:sci_fi_card_game/game/components/card.dart';
import 'package:sci_fi_card_game/game/components/play_area.dart';
import 'package:sci_fi_card_game/game/data/game_constants.dart';

void main() {
  group('CardDeck', () {
    late FlameGame game;
    late CardDeck cardDeck;
    late PlayArea playArea;

    setUp(() {
      game = FlameGame();
      cardDeck = CardDeck();
      playArea = PlayArea();
      cardDeck.playArea = playArea;
    });

    test('initializes with correct number of cards', () async {
      game.add(cardDeck);
      await game.ready();

      expect(cardDeck.cards.length, GameConstants.cardCount);
      expect(cardDeck.cardCount, GameConstants.cardCount);
    });

    test('removeCard removes card from deck and updates count', () async {
      game.add(cardDeck);
      await game.ready();

      final initialCount = cardDeck.cards.length;
      final cardToRemove = cardDeck.cards.first;

      cardDeck.removeCard(cardToRemove);

      expect(cardDeck.cards.length, initialCount - 1);
      expect(cardDeck.cardCount, initialCount - 1);
      expect(cardDeck.cards.contains(cardToRemove), isFalse);
    });

    test('removeCard clears selected card if it was the removed card', () async {
      game.add(cardDeck);
      await game.ready();

      final cardToRemove = cardDeck.cards.first;
      
      // Simulate card selection
      cardDeck.selectedCard; // This might be null initially
      
      // Set the card as selected by calling the selection callback
      cardDeck.cards.first.onSelectionChanged?.call(cardDeck.cards.first);
      
      cardDeck.removeCard(cardToRemove);

      expect(cardDeck.selectedCard, isNull);
    });

    test('removeCard does nothing for non-existent card', () async {
      game.add(cardDeck);
      await game.ready();

      final initialCount = cardDeck.cards.length;
      final nonExistentCard = GameCard();

      cardDeck.removeCard(nonExistentCard);

      expect(cardDeck.cards.length, initialCount);
      expect(cardDeck.cardCount, initialCount);
    });

    test('playArea reference can be set and accessed', () async {
      game.add(cardDeck);
      await game.ready();

      expect(cardDeck.playArea, playArea);

      final newPlayArea = PlayArea();
      cardDeck.playArea = newPlayArea;
      expect(cardDeck.playArea, newPlayArea);
    });

    test('getAllCards returns unmodifiable list', () async {
      game.add(cardDeck);
      await game.ready();

      final allCards = cardDeck.getAllCards();
      expect(allCards.length, cardDeck.cards.length);
      
      // Should be unmodifiable
      expect(() => allCards.add(GameCard()), throwsUnsupportedError);
    });

    test('getCardAt returns correct card or null', () async {
      game.add(cardDeck);
      await game.ready();

      // Valid index
      final firstCard = cardDeck.getCardAt(0);
      expect(firstCard, cardDeck.cards.first);

      // Invalid indices
      expect(cardDeck.getCardAt(-1), isNull);
      expect(cardDeck.getCardAt(cardDeck.cards.length), isNull);
    });

    test('getCardPriority returns correct priority for card', () async {
      game.add(cardDeck);
      await game.ready();

      final firstCard = cardDeck.cards.first;
      final priority = cardDeck.getCardPriority(firstCard);
      
      expect(priority, isA<int>());
      expect(priority, greaterThan(0));
    });

    test('resetAllCards resets selected card to null', () async {
      game.add(cardDeck);
      await game.ready();

      // Simulate having a selected card
      if (cardDeck.cards.isNotEmpty) {
        cardDeck.cards.first.onSelectionChanged?.call(cardDeck.cards.first);
      }

      cardDeck.resetAllCards();
      expect(cardDeck.selectedCard, isNull);
    });
  });
}