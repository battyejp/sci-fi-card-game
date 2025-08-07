import 'package:flutter_test/flutter_test.dart';
import 'package:flame/game.dart';
import 'package:sci_fi_card_game/game/components/card_deck.dart';
import 'package:sci_fi_card_game/game/data/game_constants.dart';

class MockFlameGame extends FlameGame {
  @override
  Vector2 get size => Vector2(932, 430); // GameConstants dimensions
}

void main() {
  group('CardDeck', () {
    late CardDeck cardDeck;
    late MockFlameGame game;

    setUp(() async {
      game = MockFlameGame();
      cardDeck = CardDeck();
      
      // Set the game reference manually
      cardDeck.game = game;
      
      // Initialize managers manually
      await cardDeck.onLoad();
    });

    group('initialization', () {
      test('should initialize with default card count', () {
        expect(cardDeck.cardCount, equals(GameConstants.cardCount));
      });

      test('should create correct number of cards', () {
        expect(cardDeck.getAllCards().length, equals(GameConstants.cardCount));
      });

      test('should have no selected card initially', () {
        expect(cardDeck.selectedCard, isNull);
      });

      test('should add all cards to the component tree', () {
        final allCards = cardDeck.getAllCards();
        for (final card in allCards) {
          expect(cardDeck.children.contains(card), isTrue);
        }
      });
    });

    group('card access methods', () {
      test('getCardAt should return correct card for valid index', () {
        final cards = cardDeck.getAllCards();
        
        for (int i = 0; i < cards.length; i++) {
          expect(cardDeck.getCardAt(i), equals(cards[i]));
        }
      });

      test('getCardAt should return null for invalid index', () {
        expect(cardDeck.getCardAt(-1), isNull);
        expect(cardDeck.getCardAt(100), isNull);
      });

      test('getAllCards should return unmodifiable list', () {
        final cards = cardDeck.getAllCards();
        
        expect(() => cards.add(cards.first), throwsUnsupportedError);
        expect(() => cards.clear(), throwsUnsupportedError);
      });
    });

    group('updateCardCount', () {
      test('should update card count when changed', () {
        const newCount = 5;
        cardDeck.updateCardCount(newCount);

        expect(cardDeck.cardCount, equals(newCount));
        expect(cardDeck.getAllCards().length, equals(newCount));
      });

      test('should not change when same count is provided', () {
        final initialCount = cardDeck.cardCount;
        final initialCards = cardDeck.getAllCards();

        cardDeck.updateCardCount(initialCount);

        expect(cardDeck.cardCount, equals(initialCount));
        expect(cardDeck.getAllCards().length, equals(initialCards.length));
      });

      test('should handle increasing card count', () {
        const initialCount = 5;
        const newCount = 8;
        
        cardDeck.updateCardCount(initialCount);
        expect(cardDeck.cardCount, equals(initialCount));
        
        cardDeck.updateCardCount(newCount);
        expect(cardDeck.cardCount, equals(newCount));
        expect(cardDeck.getAllCards().length, equals(newCount));
      });

      test('should handle decreasing card count', () {
        const initialCount = 8;
        const newCount = 5;
        
        cardDeck.updateCardCount(initialCount);
        expect(cardDeck.cardCount, equals(initialCount));
        
        cardDeck.updateCardCount(newCount);
        expect(cardDeck.cardCount, equals(newCount));
        expect(cardDeck.getAllCards().length, equals(newCount));
      });

      test('should update GameConstants card count', () {
        const newCount = 6;
        cardDeck.updateCardCount(newCount);

        expect(GameConstants.cardCount, equals(newCount));
      });
    });

    group('resetAllCards', () {
      test('should clear selection', () {
        // This is a basic test - in a real scenario we'd need to simulate card selection
        cardDeck.resetAllCards();
        expect(cardDeck.selectedCard, isNull);
      });

      test('should maintain card count after reset', () {
        final initialCount = cardDeck.cardCount;
        
        cardDeck.resetAllCards();
        
        expect(cardDeck.cardCount, equals(initialCount));
        expect(cardDeck.getAllCards().length, equals(initialCount));
      });
    });

    group('getCardPriority', () {
      test('should return priority for cards in deck', () {
        final cards = cardDeck.getAllCards();
        
        for (final card in cards) {
          final priority = cardDeck.getCardPriority(card);
          expect(priority, isA<int>());
          expect(priority, greaterThan(0));
        }
      });

      test('should return 0 for cards not in deck', () {
        // Create a card that's not in the deck
        final externalCard = cardDeck.getAllCards().first;
        cardDeck.updateCardCount(0); // Remove all cards
        
        final priority = cardDeck.getCardPriority(externalCard);
        expect(priority, equals(0));
      });

      test('should give highest priority to center cards', () {
        cardDeck.updateCardCount(5);
        final cards = cardDeck.getAllCards();
        
        final centerPriority = cardDeck.getCardPriority(cards[2]); // Center card
        final edgePriority1 = cardDeck.getCardPriority(cards[0]); // Left edge
        final edgePriority2 = cardDeck.getCardPriority(cards[4]); // Right edge
        
        expect(centerPriority, greaterThan(edgePriority1));
        expect(centerPriority, greaterThan(edgePriority2));
      });
    });

    group('edge cases', () {
      test('should handle single card', () {
        cardDeck.updateCardCount(1);
        
        expect(cardDeck.cardCount, equals(1));
        expect(cardDeck.getAllCards().length, equals(1));
        
        final singleCard = cardDeck.getCardAt(0);
        expect(singleCard, isNotNull);
        expect(cardDeck.getCardPriority(singleCard!), greaterThan(0));
      });

      test('should handle maximum reasonable card count', () {
        const maxCards = 10;
        cardDeck.updateCardCount(maxCards);
        
        expect(cardDeck.cardCount, equals(maxCards));
        expect(cardDeck.getAllCards().length, equals(maxCards));
        
        // All cards should be accessible
        for (int i = 0; i < maxCards; i++) {
          expect(cardDeck.getCardAt(i), isNotNull);
        }
      });

      test('should handle zero cards', () {
        cardDeck.updateCardCount(0);
        
        expect(cardDeck.cardCount, equals(0));
        expect(cardDeck.getAllCards(), isEmpty);
        expect(cardDeck.getCardAt(0), isNull);
      });
    });

    group('component integration', () {
      test('should properly add and remove cards from component tree', () {
        final initialCount = cardDeck.cardCount;
        cardDeck.updateCardCount(initialCount + 2);
        
        // All cards should be in the component tree
        final allCards = cardDeck.getAllCards();
        for (final card in allCards) {
          expect(cardDeck.children.contains(card), isTrue);
        }
        
        // Reduce card count
        cardDeck.updateCardCount(initialCount - 1);
        
        // Remaining cards should still be in component tree
        final remainingCards = cardDeck.getAllCards();
        for (final card in remainingCards) {
          expect(cardDeck.children.contains(card), isTrue);
        }
      });
    });
  });
}
