import 'package:flame/components.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'card.dart';
import '../data/game_constants.dart';

class CardDeck extends Component with HasGameReference {
  late List<GameCard> cards;
  
  @override
  Future<void> onLoad() async {
    cards = [];
    
    // Calculate starting position for the deck (centered at bottom)
    final gameSize = game.size;
    final cardWidth = GameConstants.cardWidth.w;
    final cardHeight = GameConstants.cardHeight.h;
    final cardSpacing = GameConstants.cardSpacing.w;
    final bottomMargin = GameConstants.deckBottomMargin.h;
    
    // Calculate total deck width
    final totalDeckWidth = (GameConstants.cardCount - 1) * cardSpacing + cardWidth;
    
    // Ensure deck fits on screen with some padding
    final availableWidth = gameSize.x - (GameConstants.safeAreaPadding * 2);
    final actualSpacing = totalDeckWidth > availableWidth 
        ? (availableWidth - cardWidth) / (GameConstants.cardCount - 1)
        : cardSpacing;
    
    final actualTotalWidth = (GameConstants.cardCount - 1) * actualSpacing + cardWidth;
    final startX = (gameSize.x - actualTotalWidth) / 2;
    final cardY = gameSize.y - cardHeight - bottomMargin;
    
    // Create and position cards
    for (int i = 0; i < GameConstants.cardCount; i++) {
      final card = GameCard();
      final cardX = startX + (i * actualSpacing);
      
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
  
  // Method to get all cards
  List<GameCard> getAllCards() => List.unmodifiable(cards);
  
  // Method to get highlighted cards
  List<GameCard> getHighlightedCards() {
    return cards.where((card) => card.isHighlighted).toList();
  }
}
