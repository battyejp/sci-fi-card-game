import 'package:flutter_test/flutter_test.dart';
import 'package:flame/components.dart';
import 'package:sci_fi_card_game/game/deck/card_deck_controller.dart';
import 'package:sci_fi_card_game/game/deck/layout/layout_strategy.dart';
import 'package:sci_fi_card_game/game/card/card.dart';

class _MockLayout implements CardLayoutStrategy {
  @override
  double calculateAdjustedRadius({required int cardCount, required double gameWidth, required double safeAreaPadding, required double cardWidth, required double baseRadius}) => baseRadius;
  @override
  Vector2 calculateCardPosition({required int cardIndex, required int totalCards, required double centerX, required double centerY, required double radius}) => Vector2(centerX + cardIndex.toDouble(), centerY);
  @override
  double calculateCardRotation({required int cardIndex, required int totalCards}) => 0.0;
  @override
  int calculateCardPriority({required int cardIndex, required int totalCards}) => totalCards - cardIndex;
  @override
  Vector2 calculateFanCenter({required double gameWidth, required double gameHeight, required double bottomMargin, required double fanCenterOffset}) => Vector2(gameWidth/2, gameHeight/2);
}

class _DeckComp extends Component {}

void main() {
  test('buildDeck creates expected number & priorities descending', () async {
    final controller = CardDeckController(
      layoutStrategy: _MockLayout(),
      cardFactory: () => GameCard(),
      initialCardCount: 4,
    );
    final deckComp = _DeckComp();
    await controller.buildDeck(deckComp, Vector2(800, 600));
    expect(controller.cards.length, 4);
    // priorities should be descending by mock strategy spec
    final priorities = controller.cards.map((c) => c.priority).toList();
    expect(priorities, orderedEquals([...priorities]..sort((a,b)=> b.compareTo(a))));
  });

  test('setCardCount rebuilds with new size', () async {
    final controller = CardDeckController(layoutStrategy: _MockLayout(), initialCardCount: 2);
    final deckComp = _DeckComp();
    await controller.buildDeck(deckComp, Vector2(500, 400));
    expect(controller.cards.length, 2);
    controller.setCardCount(5, deckComp, Vector2(500, 400));
    expect(controller.cards.length, 5);
  });

  test('resetAllCards recreates deck with same count and new instances', () async {
    final controller = CardDeckController(layoutStrategy: _MockLayout(), initialCardCount: 3);
    final deckComp = _DeckComp();
    await controller.buildDeck(deckComp, Vector2(600, 400));
    final firstIds = controller.cards.map((c)=> c.id).toSet();
    controller.resetAllCards(deckComp, Vector2(600, 400));
    expect(controller.cards.length, 3);
    final secondIds = controller.cards.map((c)=> c.id).toSet();
    // IDs should not be identical set because factory creates new incremented ids
    expect(secondIds.difference(firstIds).isNotEmpty, true);
  });
}
