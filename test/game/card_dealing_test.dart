import 'package:flutter_test/flutter_test.dart';
import 'package:sci_fi_card_game/game/card/card.dart';
import 'package:sci_fi_card_game/game/data/game_constants.dart';

void main() {
  group('Card Dealing Feature Tests', () {
    test('GameCard should support card back display', () {
      final frontCard = GameCard(showBack: false);
      final backCard = GameCard(showBack: true);
      
      expect(frontCard.showBack, isFalse);
      expect(backCard.showBack, isTrue);
    });

    test('Constants should be set correctly for card dealing', () {
      expect(GameConstants.cardsToDealt, equals(5));
      expect(GameConstants.cardDealingDelay, equals(0.2));
      expect(GameConstants.cardAnimationDuration, equals(0.2));
    });
    
    test('Card dealing timing should be reasonable', () {
      const animationDuration = GameConstants.cardAnimationDuration;
      const dealingDelay = GameConstants.cardDealingDelay;
      const totalCards = GameConstants.cardsToDealt;
      
      // Calculate total time for all cards to be dealt
      final totalTime = (totalCards - 1) * dealingDelay + animationDuration;
      
      // Should complete in under 2 seconds for good UX
      expect(totalTime, lessThan(2.0));
    });
  });
}