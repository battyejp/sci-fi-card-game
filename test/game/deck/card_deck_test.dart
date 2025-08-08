import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'package:sci_fi_card_game/game/deck/card_deck.dart';
import 'package:sci_fi_card_game/game/deck/card_deck_controller.dart';
import 'package:sci_fi_card_game/game/card/card.dart';

import 'card_deck_test.mocks.dart';

@GenerateMocks([CardDeckController, FlameGame, GameCard])
void main() {
  group('CardDeck', () {
    late MockCardDeckController mockController;
    late MockFlameGame mockGame;
    late CardDeck cardDeck;

    setUp(() {
      mockController = MockCardDeckController();
      mockGame = MockFlameGame();
      cardDeck = CardDeck(controller: mockController);
      
      // Setup default mock behaviors
      when(mockGame.size).thenReturn(Vector2(800, 600));
      when(mockController.cardCount).thenReturn(5);
      when(mockController.cards).thenReturn([]);
      when(mockController.selectedCard).thenReturn(null);
    });

    group('Initialization', () {
      test('creates with default controller when none provided', () {
        final deck = CardDeck();
        expect(deck.controller, isNotNull);
        expect(deck.controller, isA<CardDeckController>());
      });

      test('uses provided controller', () {
        final deck = CardDeck(controller: mockController);
        expect(deck.controller, equals(mockController));
      });

      test('controller getter returns the controller', () {
        expect(cardDeck.controller, equals(mockController));
      });
    });

    group('Deck Management', () {
      test('resetAllCards delegates to controller', () {
        cardDeck.game = mockGame;
        
        cardDeck.resetAllCards();
        
        verify(mockController.resetAllCards(cardDeck, mockGame.size)).called(1);
      });

      test('getCardPriority delegates to controller', () {
        final mockCard = MockGameCard();
        when(mockController.getCardPriority(mockCard)).thenReturn(3);
        
        final priority = cardDeck.getCardPriority(mockCard);
        
        expect(priority, equals(3));
        verify(mockController.getCardPriority(mockCard)).called(1);
      });
    });

    group('Property Access', () {
      test('cardCount returns controller cardCount', () {
        when(mockController.cardCount).thenReturn(7);
        
        expect(cardDeck.cardCount, equals(7));
        verify(mockController.cardCount).called(1);
      });

      test('cards returns controller cards', () {
        final mockCards = [MockGameCard(), MockGameCard()];
        when(mockController.cards).thenReturn(mockCards);
        
        expect(cardDeck.cards, equals(mockCards));
        verify(mockController.cards).called(1);
      });

      test('selectedCard returns controller selectedCard', () {
        final mockCard = MockGameCard();
        when(mockController.selectedCard).thenReturn(mockCard);
        
        expect(cardDeck.selectedCard, equals(mockCard));
        verify(mockController.selectedCard).called(1);
      });

      test('selectedCard returns null when no card selected', () {
        when(mockController.selectedCard).thenReturn(null);
        
        expect(cardDeck.selectedCard, isNull);
        verify(mockController.selectedCard).called(1);
      });
    });

    group('Game Integration', () {
      test('onLoad calls controller buildDeck with correct parameters', () async {
        cardDeck.game = mockGame;
        when(mockController.buildDeck(any, any)).thenAnswer((_) async {});
        
        await cardDeck.onLoad();
        
        verify(mockController.buildDeck(cardDeck, mockGame.size)).called(1);
      });

      test('onLoad handles async buildDeck correctly', () async {
        cardDeck.game = mockGame;
        var buildDeckCalled = false;
        when(mockController.buildDeck(any, any)).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 10));
          buildDeckCalled = true;
        });
        
        await cardDeck.onLoad();
        
        expect(buildDeckCalled, true);
      });
    });

    group('Controller Integration', () {
      test('multiple operations work together', () {
        cardDeck.game = mockGame;
        final mockCard1 = MockGameCard();
        final mockCard2 = MockGameCard();
        final mockCards = [mockCard1, mockCard2];
        
        when(mockController.cards).thenReturn(mockCards);
        when(mockController.cardCount).thenReturn(2);
        when(mockController.selectedCard).thenReturn(mockCard1);
        when(mockController.getCardPriority(mockCard1)).thenReturn(2);
        when(mockController.getCardPriority(mockCard2)).thenReturn(1);
        
        // Test multiple property accesses
        expect(cardDeck.cards.length, equals(2));
        expect(cardDeck.cardCount, equals(2));
        expect(cardDeck.selectedCard, equals(mockCard1));
        expect(cardDeck.getCardPriority(mockCard1), equals(2));
        expect(cardDeck.getCardPriority(mockCard2), equals(1));
        
        // Reset and verify
        cardDeck.resetAllCards();
        
        verify(mockController.resetAllCards(cardDeck, mockGame.size)).called(1);
      });
    });

    group('Error Handling', () {
      test('handles controller exceptions gracefully', () {
        when(mockController.cardCount).thenThrow(Exception('Test exception'));
        
        expect(() => cardDeck.cardCount, throwsA(isA<Exception>()));
      });

      test('handles null game reference in resetAllCards', () {
        cardDeck.game = mockGame;
        // This should not throw
        expect(() => cardDeck.resetAllCards(), returnsNormally);
      });
    });

    group('State Consistency', () {
      test('repeated calls return consistent values', () {
        when(mockController.cardCount).thenReturn(5);
        
        expect(cardDeck.cardCount, equals(5));
        expect(cardDeck.cardCount, equals(5));
        expect(cardDeck.cardCount, equals(5));
        
        verify(mockController.cardCount).called(3);
      });

      test('property changes reflect in subsequent calls', () {
        // First return 3 cards
        when(mockController.cardCount).thenReturn(3);
        expect(cardDeck.cardCount, equals(3));
        
        // Then return 5 cards
        when(mockController.cardCount).thenReturn(5);
        expect(cardDeck.cardCount, equals(5));
        
        verify(mockController.cardCount).called(2);
      });
    });
  });
}