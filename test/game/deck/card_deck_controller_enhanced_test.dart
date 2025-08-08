import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flame/components.dart';
import 'package:sci_fi_card_game/game/deck/card_deck_controller.dart';
import 'package:sci_fi_card_game/game/deck/layout/layout_strategy.dart';
import 'package:sci_fi_card_game/game/deck/layout/card_selection_manager.dart';
import 'package:sci_fi_card_game/game/deck/layout/card_collection_manager.dart';
import 'package:sci_fi_card_game/game/card/card.dart';

import 'card_deck_controller_enhanced_test.mocks.dart';

@GenerateMocks([CardLayoutStrategy, ICardSelectionManager, ICardCollectionManager, GameCard])
class _MockDeckComponent extends Component {}

void main() {
  group('CardDeckController Enhanced Tests', () {
    late MockCardLayoutStrategy mockLayoutStrategy;
    late MockICardSelectionManager mockSelectionManager;
    late MockICardCollectionManager mockCollectionManager;
    late CardDeckController controller;
    late _MockDeckComponent deckComponent;

    setUp(() {
      mockLayoutStrategy = MockCardLayoutStrategy();
      mockSelectionManager = MockICardSelectionManager();
      mockCollectionManager = MockICardCollectionManager();
      deckComponent = _MockDeckComponent();

      // Setup default mock behaviors
      when(mockLayoutStrategy.calculateFanCenter(
        gameWidth: anyNamed('gameWidth'),
        gameHeight: anyNamed('gameHeight'),
        bottomMargin: anyNamed('bottomMargin'),
        fanCenterOffset: anyNamed('fanCenterOffset'),
      )).thenReturn(Vector2(400, 300));

      when(mockLayoutStrategy.calculateAdjustedRadius(
        cardCount: anyNamed('cardCount'),
        gameWidth: anyNamed('gameWidth'),
        safeAreaPadding: anyNamed('safeAreaPadding'),
        cardWidth: anyNamed('cardWidth'),
        baseRadius: anyNamed('baseRadius'),
      )).thenReturn(200.0);

      when(mockLayoutStrategy.calculateCardPosition(
        cardIndex: anyNamed('cardIndex'),
        totalCards: anyNamed('totalCards'),
        centerX: anyNamed('centerX'),
        centerY: anyNamed('centerY'),
        radius: anyNamed('radius'),
      )).thenAnswer((invocation) {
        final index = invocation.namedArguments[#cardIndex] as int;
        final centerX = invocation.namedArguments[#centerX] as double;
        final centerY = invocation.namedArguments[#centerY] as double;
        return Vector2(centerX + index * 10, centerY);
      });

      when(mockLayoutStrategy.calculateCardRotation(
        cardIndex: anyNamed('cardIndex'),
        totalCards: anyNamed('totalCards'),
      )).thenReturn(0.0);

      when(mockLayoutStrategy.calculateCardPriority(
        cardIndex: anyNamed('cardIndex'),
        totalCards: anyNamed('totalCards'),
      )).thenAnswer((invocation) {
        final index = invocation.namedArguments[#cardIndex] as int;
        final total = invocation.namedArguments[#totalCards] as int;
        return total - index;
      });

      when(mockCollectionManager.cards).thenReturn([]);
      when(mockSelectionManager.selectedCard).thenReturn(null);
    });

    group('Constructor and Dependencies', () {
      test('creates with provided dependencies', () {
        controller = CardDeckController(
          layoutStrategy: mockLayoutStrategy,
          selectionManager: mockSelectionManager,
          collectionManager: mockCollectionManager,
          initialCardCount: 5,
        );

        expect(controller.cardCount, equals(5));
        expect(controller.cards, equals([]));
        expect(controller.selectedCard, isNull);
      });

      test('creates with default dependencies when none provided', () {
        controller = CardDeckController();
        
        expect(controller, isNotNull);
        expect(controller.cardCount, greaterThan(0));
      });

      test('uses custom card factory', () {
        var cardCreationCount = 0;
        controller = CardDeckController(
          layoutStrategy: mockLayoutStrategy,
          selectionManager: mockSelectionManager,
          collectionManager: mockCollectionManager,
          cardFactory: () {
            cardCreationCount++;
            return GameCard(id: 'custom_$cardCreationCount');
          },
          initialCardCount: 3,
        );

        // Build deck should use the custom factory
        controller.buildDeck(deckComponent, Vector2(800, 600));
        
        expect(cardCreationCount, equals(3));
      });
    });

    group('Deck Building', () {
      setUp(() {
        controller = CardDeckController(
          layoutStrategy: mockLayoutStrategy,
          selectionManager: mockSelectionManager,
          collectionManager: mockCollectionManager,
          initialCardCount: 4,
        );
      });

      test('buildDeck calls layout strategy methods correctly', () async {
        final gameSize = Vector2(1000, 500);
        
        await controller.buildDeck(deckComponent, gameSize);

        // Verify layout calculations were called
        verify(mockLayoutStrategy.calculateFanCenter(
          gameWidth: 1000,
          gameHeight: 500,
          bottomMargin: anyNamed('bottomMargin'),
          fanCenterOffset: anyNamed('fanCenterOffset'),
        )).called(1);

        verify(mockLayoutStrategy.calculateAdjustedRadius(
          cardCount: 4,
          gameWidth: 1000,
          safeAreaPadding: anyNamed('safeAreaPadding'),
          cardWidth: anyNamed('cardWidth'),
          baseRadius: anyNamed('baseRadius'),
        )).called(1);

        // Should calculate position, rotation, and priority for each card
        verify(mockLayoutStrategy.calculateCardPosition(
          cardIndex: anyNamed('cardIndex'),
          totalCards: 4,
          centerX: anyNamed('centerX'),
          centerY: anyNamed('centerY'),
          radius: anyNamed('radius'),
        )).called(4);

        verify(mockLayoutStrategy.calculateCardRotation(
          cardIndex: anyNamed('cardIndex'),
          totalCards: 4,
        )).called(4);

        verify(mockLayoutStrategy.calculateCardPriority(
          cardIndex: anyNamed('cardIndex'),
          totalCards: 4,
        )).called(4);
      });

      test('buildDeck clears and populates collection', () async {
        await controller.buildDeck(deckComponent, Vector2(800, 600));

        verify(mockCollectionManager.clearAllCards()).called(1);
        verify(mockCollectionManager.addCard(any)).called(4);
      });

      test('buildDeck adds cards to deck component', () async {
        final addedComponents = <Component>[];
        deckComponent.add = (Component component) {
          addedComponents.add(component);
          return Future.value();
        };

        await controller.buildDeck(deckComponent, Vector2(800, 600));

        expect(addedComponents.length, equals(4));
        expect(addedComponents.every((c) => c is GameCard), true);
      });
    });

    group('Card Management', () {
      setUp(() {
        controller = CardDeckController(
          layoutStrategy: mockLayoutStrategy,
          selectionManager: mockSelectionManager,
          collectionManager: mockCollectionManager,
          initialCardCount: 3,
        );
      });

      test('setCardCount updates count and rebuilds deck', () {
        controller.setCardCount(7, deckComponent, Vector2(800, 600));

        expect(controller.cardCount, equals(7));
        
        // Should have cleared and rebuilt with new count
        verify(mockCollectionManager.clearAllCards()).called(1);
        verify(mockLayoutStrategy.calculateCardPosition(
          cardIndex: anyNamed('cardIndex'),
          totalCards: 7,
          centerX: anyNamed('centerX'),
          centerY: anyNamed('centerY'),
          radius: anyNamed('radius'),
        )).called(7);
      });

      test('resetAllCards clears selection and rebuilds', () {
        controller.resetAllCards(deckComponent, Vector2(800, 600));

        verify(mockSelectionManager.clearSelection()).called(1);
        verify(mockCollectionManager.clearAllCards()).called(1);
      });

      test('getCardPriority delegates to collection manager', () {
        final mockCard = MockGameCard();
        when(mockCollectionManager.indexOf(mockCard)).thenReturn(2);

        final priority = controller.getCardPriority(mockCard);

        verify(mockCollectionManager.indexOf(mockCard)).called(1);
        verify(mockLayoutStrategy.calculateCardPriority(
          cardIndex: 2,
          totalCards: 3,
        )).called(1);
      });

      test('getCardPriority returns 0 for unknown card', () {
        final mockCard = MockGameCard();
        when(mockCollectionManager.indexOf(mockCard)).thenReturn(-1);

        final priority = controller.getCardPriority(mockCard);

        expect(priority, equals(0));
        verifyNever(mockLayoutStrategy.calculateCardPriority(
          cardIndex: anyNamed('cardIndex'),
          totalCards: anyNamed('totalCards'),
        ));
      });
    });

    group('Property Access', () {
      setUp(() {
        controller = CardDeckController(
          layoutStrategy: mockLayoutStrategy,
          selectionManager: mockSelectionManager,
          collectionManager: mockCollectionManager,
          initialCardCount: 5,
        );
      });

      test('cards property delegates to collection manager', () {
        final mockCards = [MockGameCard(), MockGameCard()];
        when(mockCollectionManager.cards).thenReturn(mockCards);

        expect(controller.cards, equals(mockCards));
        verify(mockCollectionManager.cards).called(1);
      });

      test('selectedCard property delegates to selection manager', () {
        final mockCard = MockGameCard();
        when(mockSelectionManager.selectedCard).thenReturn(mockCard);

        expect(controller.selectedCard, equals(mockCard));
        verify(mockSelectionManager.selectedCard).called(1);
      });

      test('cardCount returns current count', () {
        expect(controller.cardCount, equals(5));
      });
    });

    group('Edge Cases', () {
      test('handles zero card count', () {
        controller = CardDeckController(
          layoutStrategy: mockLayoutStrategy,
          selectionManager: mockSelectionManager,
          collectionManager: mockCollectionManager,
          initialCardCount: 0,
        );

        controller.buildDeck(deckComponent, Vector2(800, 600));

        verify(mockCollectionManager.clearAllCards()).called(1);
        verifyNever(mockCollectionManager.addCard(any));
        verifyNever(mockLayoutStrategy.calculateCardPosition(
          cardIndex: anyNamed('cardIndex'),
          totalCards: anyNamed('totalCards'),
          centerX: anyNamed('centerX'),
          centerY: anyNamed('centerY'),
          radius: anyNamed('radius'),
        ));
      });

      test('handles large card count', () {
        controller = CardDeckController(
          layoutStrategy: mockLayoutStrategy,
          selectionManager: mockSelectionManager,
          collectionManager: mockCollectionManager,
          initialCardCount: 50,
        );

        controller.buildDeck(deckComponent, Vector2(800, 600));

        verify(mockCollectionManager.addCard(any)).called(50);
        verify(mockLayoutStrategy.calculateCardPosition(
          cardIndex: anyNamed('cardIndex'),
          totalCards: 50,
          centerX: anyNamed('centerX'),
          centerY: anyNamed('centerY'),
          radius: anyNamed('radius'),
        )).called(50);
      });

      test('handles very small game size', () {
        controller = CardDeckController(
          layoutStrategy: mockLayoutStrategy,
          selectionManager: mockSelectionManager,
          collectionManager: mockCollectionManager,
          initialCardCount: 3,
        );

        controller.buildDeck(deckComponent, Vector2(100, 100));

        verify(mockLayoutStrategy.calculateFanCenter(
          gameWidth: 100,
          gameHeight: 100,
          bottomMargin: anyNamed('bottomMargin'),
          fanCenterOffset: anyNamed('fanCenterOffset'),
        )).called(1);
      });
    });

    group('Integration Scenarios', () {
      test('multiple deck operations work together', () {
        controller = CardDeckController(
          layoutStrategy: mockLayoutStrategy,
          selectionManager: mockSelectionManager,
          collectionManager: mockCollectionManager,
          initialCardCount: 3,
        );

        // Build initial deck
        controller.buildDeck(deckComponent, Vector2(800, 600));
        
        // Change card count
        controller.setCardCount(5, deckComponent, Vector2(800, 600));
        
        // Reset deck
        controller.resetAllCards(deckComponent, Vector2(800, 600));

        // Verify all operations called appropriate methods
        verify(mockCollectionManager.clearAllCards()).called(3); // build + setCount + reset
        verify(mockSelectionManager.clearSelection()).called(1); // reset only
      });
    });
  });
}