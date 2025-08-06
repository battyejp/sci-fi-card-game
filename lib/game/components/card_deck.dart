import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;
import 'card.dart';
import '../data/game_constants.dart';

class CardDeck extends Component with HasGameReference {
  late List<GameCard> cards;
  int _currentCardCount = GameConstants.cardCount;
  GameCard? _selectedCard;
  
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
    final bottomMargin = GameConstants.deckBottomMargin.h;
    final fanCenterOffset = GameConstants.fanCenterOffset.h;
    final safeAreaPadding = GameConstants.safeAreaPadding.w;
    
    // Calculate fan center position with safe area consideration
    final fanCenterX = gameSize.x / 2;
    final fanCenterY = gameSize.y - bottomMargin - fanCenterOffset;
    
    // Ensure the fan doesn't extend beyond screen bounds
    final maxFanWidth = gameSize.x - (safeAreaPadding * 2);
    final estimatedFanWidth = cardCount * cardWidth * 0.7; // Rough estimate with overlap
    
    // Adjust fan radius if needed to keep cards on screen
    var adjustedRadius = GameConstants.fanRadius.w;
    if (estimatedFanWidth > maxFanWidth) {
      adjustedRadius = adjustedRadius * (maxFanWidth / estimatedFanWidth);
    }
    
    // Create cards with fanned positioning
    for (int i = 0; i < cardCount; i++) {
      final card = GameCard();
      
      // Set the selection change callback
      card.onSelectionChanged = _onCardSelectionChanged;
      
      // Calculate position and rotation for this card
      final fanPosition = _calculateFanPositionWithRadius(i, cardCount, fanCenterX, fanCenterY, adjustedRadius);
      final rotation = _calculateFanRotation(i, cardCount);
      
      // Set card position and rotation
      card.setOriginalPosition(fanPosition);
      card.setRotation(rotation);
      
      // Set priority so cards overlap correctly (center cards on top)
      final centerIndex = (cardCount - 1) / 2;
      final distanceFromCenter = (i - centerIndex).abs();
      card.priority = (cardCount - distanceFromCenter).toInt();
      
      cards.add(card);
      add(card);
    }
  }
  
  Vector2 _calculateFanPositionWithRadius(int cardIndex, int totalCards, double centerX, double centerY, double radius) {
    if (totalCards == 1) {
      return Vector2(centerX, centerY);
    }
    
    // Calculate the angle for this card in the fan
    final angleRange = GameConstants.degreesToRadians(GameConstants.maxFanRotation * 2); // Total fan spread
    final angleStep = angleRange / (totalCards - 1);
    final cardAngle = -GameConstants.degreesToRadians(GameConstants.maxFanRotation) + (cardIndex * angleStep);
    
    // Calculate position along the fan arc
    final x = centerX + radius * math.sin(cardAngle);
    final y = centerY + radius * (1 - math.cos(cardAngle)); // Add to curve downward
    
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
    // Cards should overlap horizontally to create a natural fan effect
    // Cards closer to the edges should be pushed inward slightly
    final centerIndex = (totalCards - 1) / 2;
    final distanceFromCenter = (cardIndex - centerIndex).abs();
    
    // Create horizontal spacing that decreases toward the center
    final overlapFactor = distanceFromCenter / totalCards * 2;
    final direction = cardIndex < centerIndex ? 1 : -1; // Left cards move right, right cards move left
    // Increase the multiplier for more horizontal movement
    return direction * overlapFactor * GameConstants.cardOverlap.w * 1.2;
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
    // Create new layout with smooth transitions
    final gameSize = game.size;
    final bottomMargin = GameConstants.deckBottomMargin.h;
    final fanCenterOffset = GameConstants.fanCenterOffset.h;
    final safeAreaPadding = GameConstants.safeAreaPadding.w;
    
    final fanCenterX = gameSize.x / 2;
    final fanCenterY = gameSize.y - bottomMargin - fanCenterOffset;
    
    // Calculate adjusted radius for screen bounds
    final maxFanWidth = gameSize.x - (safeAreaPadding * 2);
    final estimatedFanWidth = _currentCardCount * GameConstants.handCardWidth.w * 0.7;
    var adjustedRadius = GameConstants.fanRadius.w;
    if (estimatedFanWidth > maxFanWidth) {
      adjustedRadius = adjustedRadius * (maxFanWidth / estimatedFanWidth);
    }
    
    // If we have more cards than before, add new ones
    if (_currentCardCount > cards.length) {
      for (int i = cards.length; i < _currentCardCount; i++) {
        final card = GameCard();
        // Set the selection change callback for new cards
        card.onSelectionChanged = _onCardSelectionChanged;
        cards.add(card);
        add(card);
      }
    }
    // If we have fewer cards, remove excess ones with animation
    else if (_currentCardCount < cards.length) {
      final cardsToRemove = cards.skip(_currentCardCount).toList();
      for (final card in cardsToRemove) {
        // Animate card out before removing
        card.add(ScaleEffect.to(
          Vector2.zero(),
          EffectController(duration: GameConstants.cardAnimationDuration),
          onComplete: () => card.removeFromParent(),
        ));
      }
      cards.removeRange(_currentCardCount, cards.length);
    }
    
    // Animate all remaining cards to new positions
    for (int i = 0; i < _currentCardCount; i++) {
      final card = cards[i];
      final fanPosition = _calculateFanPositionWithRadius(i, _currentCardCount, fanCenterX, fanCenterY, adjustedRadius);
      final rotation = _calculateFanRotation(i, _currentCardCount);
      
      // Animate to new position
      card.add(MoveEffect.to(
        fanPosition,
        EffectController(duration: GameConstants.cardAnimationDuration),
      ));
      
      // Animate to new rotation
      card.add(RotateEffect.to(
        rotation,
        EffectController(duration: GameConstants.cardAnimationDuration),
      ));
      
      // Set new priority
      final centerIndex = (_currentCardCount - 1) / 2;
      final distanceFromCenter = (i - centerIndex).abs();
      card.priority = (_currentCardCount - distanceFromCenter).toInt();
    }
  }
  
  // Method to reset all cards to their original positions
  void resetAllCards() {
    _selectedCard = null;
    _createFannedHand(_currentCardCount);
  }
  
  // Callback for when a card's selection changes
  void _onCardSelectionChanged(GameCard selectedCard) {
    // If another card is already selected, deselect it
    if (_selectedCard != null && _selectedCard != selectedCard) {
      _selectedCard!.forceDeselect();
    }
    
    // Update the currently selected card
    _selectedCard = selectedCard.isSelected ? selectedCard : null;
  }
  
  // Method to get the original priority for a card
  int getCardPriority(GameCard card) {
    final index = cards.indexOf(card);
    if (index == -1) return 0;
    
    final centerIndex = (_currentCardCount - 1) / 2;
    final distanceFromCenter = (index - centerIndex).abs();
    return (_currentCardCount - distanceFromCenter).toInt();
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
  
  // Getter for currently selected card
  GameCard? get selectedCard => _selectedCard;
}
