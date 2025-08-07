import 'package:flame/components.dart';
import 'dart:math' as math;
import '../../data/game_constants.dart';

/// Handles all calculations for positioning cards in a fan layout
class FanLayoutCalculator {
  /// Calculates the position for a card in the fan layout
  Vector2 calculateCardPosition({
    required int cardIndex,
    required int totalCards,
    required double centerX,
    required double centerY,
    required double radius,
  }) {
    if (totalCards == 1) {
      return Vector2(centerX, centerY);
    }
    
    // Calculate the angle for this card in the fan
    final angleRange = GameConstants.degreesToRadians(GameConstants.maxFanRotation * 2);
    final angleStep = angleRange / (totalCards - 1);
    final cardAngle = -GameConstants.degreesToRadians(GameConstants.maxFanRotation) + (cardIndex * angleStep);
    
    // Calculate position along the fan arc
    final x = centerX + radius * math.sin(cardAngle);
    final y = centerY + radius * (1 - math.cos(cardAngle));
    
    // Add overlap effect - cards closer to center are brought forward
    final overlapOffset = _calculateOverlapOffset(cardIndex, totalCards);
    
    return Vector2(x + overlapOffset, y);
  }
  
  /// Calculates the rotation for a card in the fan layout
  double calculateCardRotation({
    required int cardIndex,
    required int totalCards,
  }) {
    if (totalCards == 1) {
      return 0.0;
    }
    
    // Calculate rotation based on distance from center
    final centerIndex = (totalCards - 1) / 2;
    final distanceFromCenter = cardIndex - centerIndex;
    final maxDistance = totalCards / 2;
    
    // Linear interpolation for rotation
    final rotationFactor = distanceFromCenter / maxDistance;
    return GameConstants.degreesToRadians(GameConstants.maxFanRotation * rotationFactor);
  }
  
  /// Calculates the priority for proper card layering
  int calculateCardPriority({
    required int cardIndex,
    required int totalCards,
  }) {
    final centerIndex = (totalCards - 1) / 2;
    final distanceFromCenter = (cardIndex - centerIndex).abs();
    return (totalCards - distanceFromCenter).toInt();
  }
  
  /// Calculates the adjusted radius to keep cards within screen bounds
  double calculateAdjustedRadius({
    required int cardCount,
    required double gameWidth,
    required double safeAreaPadding,
    required double cardWidth,
    required double baseRadius,
  }) {
    final maxFanWidth = gameWidth - (safeAreaPadding * 2);
    final estimatedFanWidth = cardCount * cardWidth * 0.7; // Rough estimate with overlap
    
    if (estimatedFanWidth > maxFanWidth) {
      return baseRadius * (maxFanWidth / estimatedFanWidth);
    }
    return baseRadius;
  }
  
  /// Calculates the fan center position
  Vector2 calculateFanCenter({
    required double gameWidth,
    required double gameHeight,
    required double bottomMargin,
    required double fanCenterOffset,
  }) {
    final fanCenterX = gameWidth / 2;
    final fanCenterY = gameHeight - bottomMargin - fanCenterOffset;
    return Vector2(fanCenterX, fanCenterY);
  }
  
  double _calculateOverlapOffset(int cardIndex, int totalCards) {
    final centerIndex = (totalCards - 1) / 2;
    final distanceFromCenter = (cardIndex - centerIndex).abs();
    
    // Create horizontal spacing that decreases toward the center
    final overlapFactor = distanceFromCenter / totalCards * 2;
    final direction = cardIndex < centerIndex ? 1 : -1;
    return direction * overlapFactor * GameConstants.cardOverlap * 1.2;
  }
}
