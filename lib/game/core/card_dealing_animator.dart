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
    // For now, just add cards one by one with a simple delay
    // TODO: Add proper flying animation in a future iteration
    
    for (int i = 0; i < cardCount; i++) {
      // Add card to hand
      final currentCardCount = targetHand.cardCount;
      targetHand.controller.setCardCount(currentCardCount + 1, targetHand, gameComponent.game.size);
      
      // Small delay between each card for better visual effect
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }
}