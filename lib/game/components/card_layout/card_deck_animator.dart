import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/foundation.dart';
import '../card.dart';
import '../../data/game_constants.dart';
import 'fan_layout_calculator.dart';

/// Handles animations for card deck operations
class CardDeckAnimator {
  final FanLayoutCalculator _layoutCalculator;
  
  CardDeckAnimator(this._layoutCalculator);
  
  /// Animates cards to new positions with the given layout parameters
  void animateToNewLayout({
    required List<GameCard> cards,
    required int targetCardCount,
    required Vector2 fanCenter,
    required double adjustedRadius,
  }) {
    // Animate all cards to new positions
    for (int i = 0; i < targetCardCount && i < cards.length; i++) {
      final card = cards[i];
      final position = _layoutCalculator.calculateCardPosition(
        cardIndex: i,
        totalCards: targetCardCount,
        centerX: fanCenter.x,
        centerY: fanCenter.y,
        radius: adjustedRadius,
      );
      final rotation = _layoutCalculator.calculateCardRotation(
        cardIndex: i,
        totalCards: targetCardCount,
      );
      final priority = _layoutCalculator.calculateCardPriority(
        cardIndex: i,
        totalCards: targetCardCount,
      );
      
      // Animate to new position
      card.add(MoveEffect.to(
        position,
        EffectController(duration: GameConstants.cardAnimationDuration),
      ));
      
      // Animate to new rotation
      card.add(RotateEffect.to(
        rotation,
        EffectController(duration: GameConstants.cardAnimationDuration),
      ));
      
      // Set new priority
      card.priority = priority;
    }
  }
  
  /// Animates cards out of the deck with a scale-down effect
  void animateCardsOut({
    required List<GameCard> cardsToRemove,
    required VoidCallback onComplete,
  }) {
    int completedAnimations = 0;
    final totalAnimations = cardsToRemove.length;
    
    if (totalAnimations == 0) {
      onComplete();
      return;
    }
    
    for (final card in cardsToRemove) {
      card.add(ScaleEffect.to(
        Vector2.zero(),
        EffectController(duration: GameConstants.cardAnimationDuration),
        onComplete: () {
          card.removeFromParent();
          completedAnimations++;
          if (completedAnimations == totalAnimations) {
            onComplete();
          }
        },
      ));
    }
  }
  
  /// Animates new cards into the deck with a scale-up effect
  void animateCardsIn({
    required List<GameCard> newCards,
    required Vector2 fanCenter,
    required double adjustedRadius,
    required int startIndex,
    required int totalCards,
  }) {
    for (int i = 0; i < newCards.length; i++) {
      final cardIndex = startIndex + i;
      final card = newCards[i];
      
      // Start with zero scale
      card.scale = Vector2.zero();
      
      // Calculate target position
      final position = _layoutCalculator.calculateCardPosition(
        cardIndex: cardIndex,
        totalCards: totalCards,
        centerX: fanCenter.x,
        centerY: fanCenter.y,
        radius: adjustedRadius,
      );
      final rotation = _layoutCalculator.calculateCardRotation(
        cardIndex: cardIndex,
        totalCards: totalCards,
      );
      final priority = _layoutCalculator.calculateCardPriority(
        cardIndex: cardIndex,
        totalCards: totalCards,
      );
      
      // Set position and rotation immediately
      card.setOriginalPosition(position);
      card.setRotation(rotation);
      card.priority = priority;
      
      // Animate scale up
      card.add(ScaleEffect.to(
        Vector2.all(1.0),
        EffectController(duration: GameConstants.cardAnimationDuration),
      ));
    }
  }
}
