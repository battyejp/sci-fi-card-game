import 'package:flame/components.dart';
import '../../data/game_constants.dart';
import 'layout_strategy.dart';

class PileLayoutCalculator implements CardLayoutStrategy {
  @override
  Vector2 calculateCardPosition({
    required int cardIndex,
    required int totalCards,
    required double centerX,
    required double centerY,
    required double radius, // Not used for pile layout
  }) {
    // Stack cards with slight offset to create pile effect
    return Vector2(
      centerX + (cardIndex * GameConstants.deckPileCardOffset),
      centerY + (cardIndex * GameConstants.deckPileCardOffset),
    );
  }

  @override
  double calculateCardRotation({
    required int cardIndex,
    required int totalCards,
  }) {
    // No rotation for pile cards
    return 0.0;
  }

  @override
  int calculateCardPriority({
    required int cardIndex,
    required int totalCards,
  }) {
    // Higher index = higher priority (top of pile)
    return cardIndex;
  }

  @override
  double calculateAdjustedRadius({
    required int cardCount,
    required double gameWidth,
    required double safeAreaPadding,
    required double cardWidth,
    required double baseRadius,
  }) {
    // Not used for pile layout
    return 0.0;
  }

  @override
  Vector2 calculateFanCenter({
    required double gameWidth,
    required double gameHeight,
    required double bottomMargin,
    required double fanCenterOffset,
  }) {
    // Position pile on the left side
    return Vector2(
      GameConstants.deckPileLeftMargin + (GameConstants.handCardWidth / 2),
      gameHeight - GameConstants.deckPileBottomMargin - (GameConstants.handCardHeight / 2),
    );
  }
}