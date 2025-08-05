import 'package:flame/components.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;
import 'card.dart';

class CardDeck extends Component with HasGameRef {
  static const int cardCount = 5;
  static const double fanRadius = 180.0; // Radius for the fan arc
  static const double fanAngleSpan = math.pi / 3; // Total angle span (60 degrees)
  static const double deckBottomMargin = 60.0; // More margin for fan layout
  
  late List<GameCard> cards;
  GameCard? _selectedCard;
  
  @override
  Future<void> onLoad() async {
    cards = [];
    
    // Calculate fan center position
    final gameSize = gameRef.size;
    final fanCenterX = gameSize.x / 2;
    final fanCenterY = gameSize.y - deckBottomMargin.h;
    
    // Create and position cards in fan layout
    for (int i = 0; i < cardCount; i++) {
      final card = GameCard();
      
      // Calculate angle for this card
      final angleStep = fanAngleSpan / (cardCount - 1);
      final angle = -fanAngleSpan / 2 + (i * angleStep);
      
      // Calculate position on the arc
      final cardX = fanCenterX + (fanRadius.w * math.cos(angle + math.pi / 2));
      final cardY = fanCenterY + (fanRadius.h * math.sin(angle + math.pi / 2));
      
      card.setOriginalPosition(Vector2(cardX, cardY));
      card.setOriginalAngle(angle);
      card.priority = i;
      card.onCardSelected = _onCardSelected;
      
      cards.add(card);
      add(card);
    }
  }
  
  // Method to handle card selection
  void _onCardSelected(GameCard selectedCard) {
    // If there's already a selected card, deselect it
    if (_selectedCard != null && _selectedCard != selectedCard) {
      _selectedCard!.deselectCard();
    }
    
    // Update the selected card reference
    _selectedCard = selectedCard.isSelected ? selectedCard : null;
    
    // Update priorities to bring selected card to front
    if (_selectedCard != null) {
      _selectedCard!.priority = 1000; // Highest priority
    }
  }
  
  // Method to reset all cards to their unhighlighted state
  void resetAllCards() {
    _selectedCard = null;
    for (int i = 0; i < cards.length; i++) {
      final card = cards[i];
      card.deselectCard();
      card.priority = i;
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