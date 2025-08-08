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

class _MockDeckComponent extends Component {}

void main() {
  test('buildDeck creates expected number of cards', () async {
    final controller = CardDeckController(
      layoutStrategy: _MockLayout(),
      cardFactory: () => GameCard(id: 'test'),
      initialCardCount: 3,
    );
    final deckComp = _MockDeckComponent();
    final gameSize = Vector2(800, 600);
    await controller.buildDeck(deckComp, gameSize);
    expect(controller.cards.length, 3);
  });
}
