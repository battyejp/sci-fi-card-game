import 'package:flame/components.dart';

abstract class CardLayoutStrategy {
  Vector2 calculateCardPosition({
    required int cardIndex,
    required int totalCards,
    required double centerX,
    required double centerY,
    required double radius,
  });

  double calculateCardRotation({
    required int cardIndex,
    required int totalCards,
  });

  int calculateCardPriority({
    required int cardIndex,
    required int totalCards,
  });

  double calculateAdjustedRadius({
    required int cardCount,
    required double gameWidth,
    required double safeAreaPadding,
    required double cardWidth,
    required double baseRadius,
  });

  Vector2 calculateFanCenter({
    required double gameWidth,
    required double gameHeight,
    required double bottomMargin,
    required double fanCenterOffset,
  });
}
