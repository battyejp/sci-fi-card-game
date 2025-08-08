import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'dart:ui';
import '../deck/card_deck.dart';
import '../data/game_constants.dart';

class MyGame extends FlameGame with HasGameReference {
  late CardDeck cardDeck;

  @override
  Future<void> onLoad() async {
    final screenSize = size;
    add(RectangleComponent(
      size: screenSize,
      paint: Paint()..color = GameConstants.backgroundColor,
    ));
    cardDeck = CardDeck();
    add(cardDeck);
  }

  void resetGame() => cardDeck.resetAllCards();
  CardDeck get deck => cardDeck;
}
