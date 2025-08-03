import 'package:flame/components.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'card.dart';

class CardDeck extends Component with HasGameRef {
  static const int cardCount = 5;
  static const double cardSpacing = 50.0; // Horizontal spacing for overlap
  static const double deckBottomMargin = 20.0;
  
  late List<GameCard> cards;
  
  @override
  Future<void> onLoad() async {
    cards = [];
    
    // Calculate starting position for the deck (centered at bottom)
    final gameSize = gameRef.size;
    final totalDeckWidth = (cardCount - 1) * cardSpacing.w + GameCard.cardWidth.w;
    final startX = (gameSize.x - totalDeckWidth) / 2;
    final cardY = gameSize.y - GameCard.cardHeight.h - deckBottomMargin.h;
    
    // Create and position cards
    for (int i = 0; i < cardCount; i++) {
      final card = GameCard();
      final cardX = startX + (i * cardSpacing.w);
      
      card.setOriginalPosition(Vector2(cardX, cardY));
      card.priority = i; // Cards on the right have higher priority initially
      
      cards.add(card);
      add(card);
    }
  }
  
  // Method to reset all cards to their unhighlighted state
  void resetAllCards() {
    for (final card in cards) {
      card.priority = cards.indexOf(card);
    }
  }
  
  // Method to get card at specific index
  GameCard? getCardAt(int index) {
    if (index >= 0 && index < cards.length) {
      return cards[index];
    }
    return null;
  }
}