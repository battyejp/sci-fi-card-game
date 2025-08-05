import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;
import 'card.dart';
import '../data/game_constants.dart';

class CardDeck extends Component with HasGameReference {
  late List<GameCard> cards;
  int _currentCardCount = GameConstants.cardCount;
  
  @override
  Future<void> onLoad() async {
    cards = [];
    _createFannedHand(_currentCardCount);
  }
  
  void _createFannedHand(int cardCount) {
    // Clear existing cards
    for (final card in cards) {
      card.removeFromParent();
    }
    cards.clear();
    
    // Get game dimensions
    final gameSize = game.size;
    final cardWidth = GameConstants.handCardWidth.w;
    final cardHeight = GameConstants.handCardHeight.h;
    final bottomMargin = GameConstants.deckBottomMargin.h;
    final fanCenterOffset = GameConstants.fanCenterOffset.h;
    
    // Calculate fan center position
    final fanCenterX = gameSize.x / 2;
    final fanCenterY = gameSize.y - bottomMargin - fanCenterOffset;
    
    // Create cards with fanned positioning
    for (int i = 0; i < cardCount; i++) {
      final card = GameCard();
      
      // Calculate position and rotation for this card
      final fanPosition = _calculateFanPosition(i, cardCount, fanCenterX, fanCenterY);
      final rotation = _calculateFanRotation(i, cardCount);
      
      // Set card position and rotation
      card.setOriginalPosition(fanPosition);
      card.setRotation(rotation);
      
      // Set priority so cards overlap correctly (leftmost cards on bottom)
      card.priority = i;
      
      cards.add(card);
      add(card);
    }
  }
  
  Vector2 _calculateFanPosition(int cardIndex, int totalCards, double centerX, double centerY) {
    if (totalCards == 1) {
      return Vector2(centerX, centerY);
    }
    
    // Calculate the angle for this card in the fan
    final angleRange = GameConstants.degreesToRadians(GameConstants.maxFanRotation * 2); // Total fan spread
    final angleStep = angleRange / (totalCards - 1);
    final cardAngle = -GameConstants.degreesToRadians(GameConstants.maxFanRotation) + (cardIndex * angleStep);
    
    // Calculate position along the fan arc
    final radius = GameConstants.fanRadius.w;
    final x = centerX + radius * math.sin(cardAngle);
    final y = centerY + radius * math.cos(cardAngle);
    
    // Add overlap effect - cards closer to center are brought forward
    final overlapOffset = _calculateOverlapOffset(cardIndex, totalCards);
    
    return Vector2(x + overlapOffset, y);
  }
  
  double _calculateFanRotation(int cardIndex, int totalCards) {
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
  
  double _calculateOverlapOffset(int cardIndex, int totalCards) {
    // Cards in the middle should be brought forward slightly
    final centerIndex = (totalCards - 1) / 2;
    final distanceFromCenter = (cardIndex - centerIndex).abs();
    final maxDistance = totalCards / 2;
    
    // Cards closer to center get a small forward offset
    final overlapFactor = 1 - (distanceFromCenter / maxDistance);
    return overlapFactor * GameConstants.cardOverlap.w * 0.3; // Subtle overlap effect
  }
  
  // Method to update the number of cards in hand with smooth transition
  void updateCardCount(int newCardCount) {
    if (newCardCount != _currentCardCount) {
      _currentCardCount = newCardCount;
      GameConstants.setCardCount(newCardCount);
      _animateToNewLayout();
    }
  }
  
  void _animateToNewLayout() {
    // Animate existing cards out and new cards in
    _createFannedHand(_currentCardCount);
  }
  
  // Method to reset all cards to their original positions
  void resetAllCards() {
    _createFannedHand(_currentCardCount);
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
  
  // Getter for current card count
  int get cardCount => _currentCardCount;
}
}
