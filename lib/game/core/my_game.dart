import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'dart:ui';
import '../deck/card_hand.dart';
import '../data/game_constants.dart';

class MyGame extends FlameGame with HasGameReference {
  late CardHand cardHand;

  @override
  Future<void> onLoad() async {
    final screenSize = size;
    add(RectangleComponent(
      size: screenSize,
      paint: Paint()..color = GameConstants.backgroundColor,
    ));
  cardHand = CardHand();
  add(cardHand);
  }

  void resetGame() => cardHand.resetAllCards();
  CardHand get hand => cardHand;
}
