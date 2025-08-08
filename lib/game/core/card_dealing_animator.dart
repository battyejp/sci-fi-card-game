import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import '../card/card.dart';
import '../data/game_constants.dart';
import '../deck/card_hand.dart';

class CardDealingAnimator {
  static Future<void> dealCardsWithAnimation({
    required Component gameComponent,
    required Vector2 deckPosition,
    required CardHand targetHand,
    required int cardCount,
  }) async {
    for (int i = 0; i < cardCount; i++) {
      await _dealSingleCard(
        gameComponent: gameComponent,
        deckPosition: deckPosition,
        targetHand: targetHand,
        cardIndex: i,
      );
      
      // Small delay between each card for better visual effect
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }
  
  static Future<void> _dealSingleCard({
    required Component gameComponent,
    required Vector2 deckPosition,
    required CardHand targetHand,
    required int cardIndex,
  }) async {
    // Create a temporary card for animation
    final animCard = GameCard();
    await animCard.onLoad();
    
    // Start at deck position
    animCard.position = deckPosition.clone();
    animCard.priority = 1000; // High priority to appear on top
    
    gameComponent.add(animCard);
    
    // Add the actual card to the hand (invisible initially)
    final currentCardCount = targetHand.cardCount;
    targetHand.controller.setCardCount(currentCardCount + 1, targetHand, gameComponent.game.size);
    
    // Get the target position of the newly added card
    final targetCard = targetHand.cards.last;
    final targetPosition = targetCard.originalPosition;
    final targetRotation = targetCard.cardRotation;
    
    // Make the actual card invisible during animation
    targetCard.opacity = 0.0;
    
    // Animate the temporary card to the target position
    final moveEffect = MoveToEffect(
      targetPosition,
      EffectController(duration: GameConstants.cardAnimationDuration),
    );
    
    final rotateEffect = RotateEffect.to(
      targetRotation,
      EffectController(duration: GameConstants.cardAnimationDuration),
    );
    
    animCard.add(moveEffect);
    animCard.add(rotateEffect);
    
    // Wait for animation to complete
    await Future.delayed(Duration(milliseconds: (GameConstants.cardAnimationDuration * 1000).round()));
    
    // Remove the animation card and make the real card visible
    animCard.removeFromParent();
    targetCard.opacity = 1.0;
  }
}