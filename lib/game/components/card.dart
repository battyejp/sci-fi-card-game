import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sci_fi_card_game/game/components/card_deck.dart';
import 'package:sci_fi_card_game/game/components/play_area.dart';
import '../data/game_constants.dart';

class GameCard extends SpriteComponent with HasGameReference, TapCallbacks, HasDragCallbacks {
  late Vector2 _originalPosition;
  late Vector2 _originalSize;
  double _rotation = 0.0;
  bool _isSelected = false;
  bool _isAnimating = false;
  
  // Drag-related properties
  bool _isDragging = false;
  Vector2? _dragStartPosition;
  Vector2? _tapStartPosition;
  late Paint _normalPaint;
  late Paint _dragPaint;
  PlayArea? _playArea;
  
  // Callback for when card selection changes
  Function(GameCard)? onSelectionChanged;
  
  @override
  Future<void> onLoad() async {
    // Load the card sprite
    sprite = await Sprite.load('card.png');
    
    // Set card dimensions using constants (smaller size for hand)
    size = Vector2(GameConstants.handCardWidth.w, GameConstants.handCardHeight.h);
    _originalSize = size.clone();
    
    // Store original position
    _originalPosition = position.clone();
    
    // Set anchor to center for proper rotation
    anchor = Anchor.center;
    
    // Initialize paint objects for drag effects
    _normalPaint = Paint()..color = Colors.white;
    _dragPaint = Paint()
      ..color = Colors.white.withOpacity(GameConstants.dragCardOpacity);
    
    // Set initial paint
    paint = _normalPaint;
  }
  
  @override
  bool onTapDown(TapDownEvent event) {
    if (!_isAnimating && !_isDragging) {
      _tapStartPosition = event.localPosition.clone();
      _selectCardAtPosition(event.localPosition);
    }
    return true;
  }

  @override
  bool onTapUp(TapUpEvent event) {
    if (_isSelected && !_isAnimating && !_isDragging) {
      _deselectCard();
    }
    _tapStartPosition = null;
    return true;
  }

  @override
  bool onTapCancel(TapCancelEvent event) {
    if (_isSelected && !_isAnimating && !_isDragging) {
      _deselectCard();
    }
    _tapStartPosition = null;
    return true;
  }
  
  @override
  bool onDragStart(DragStartEvent event) {
    // Only start dragging if the card is selected and we have a tap start position
    if (_isSelected && _tapStartPosition != null && !_isAnimating) {
      final dragDistance = (event.localPosition - _tapStartPosition!).length;
      if (dragDistance >= GameConstants.dragThreshold) {
        _startDragging(event.localPosition);
        return true;
      }
    }
    return false;
  }
  
  @override
  bool onDragUpdate(DragUpdateEvent event) {
    if (_isDragging) {
      _updateDragPosition(event.localPosition);
      return true;
    }
    return false;
  }
  
  @override
  bool onDragEnd(DragEndEvent event) {
    if (_isDragging) {
      _endDragging();
      return true;
    }
    return false;
  }
  
  @override
  bool onDragCancel(DragCancelEvent event) {
    if (_isDragging) {
      _cancelDragging();
      return true;
    }
    return false;
  }
  
  void _selectCardAtPosition(Vector2 pressPosition) {
    if (_isSelected || _isAnimating) return;

    _isSelected = true;
    _isAnimating = true;

    // Notify parent about selection change
    onSelectionChanged?.call(this);

    // Set highest priority to appear on top
    priority = 1000;

    // Calculate the new Y position so the enlarged card is fully in view
    const scale = 2.5;
    final enlargedHeight = _originalSize.y * scale;
    final gameSize = game.size;
    double targetY = position.y;
    // If the bottom of the enlarged card would be off screen, move it up
    final bottomOfCard = position.y + enlargedHeight / 2;
    if (bottomOfCard > gameSize.y) {
      targetY -= (bottomOfCard - gameSize.y);
    }
    // If the top would be off screen, clamp to top
    final topOfCard = targetY - enlargedHeight / 2;
    if (topOfCard < 0) {
      targetY -= topOfCard;
    }

    final moveEffect = MoveEffect.to(
      Vector2(position.x, targetY),
      EffectController(duration: GameConstants.cardAnimationDuration),
    );
    final scaleEffect = ScaleEffect.to(
      Vector2.all(scale),
      EffectController(duration: GameConstants.cardAnimationDuration),
    );
    final rotateEffect = RotateEffect.to(
      0.0,
      EffectController(duration: GameConstants.cardAnimationDuration),
    );

    moveEffect.onComplete = () {
      _isAnimating = false;
    };

    add(moveEffect);
    add(scaleEffect);
    add(rotateEffect);
  }
  
  void _deselectCard() {
    if (!_isSelected || _isAnimating) return;
    
    _isSelected = false;
    _isAnimating = true;
    
    // Reset priority to original value
    final parent = this.parent;
    if (parent is CardDeck) {
      priority = parent.getCardPriority(this);
    }
    
    // Animate back to original position and size
    final moveEffect = MoveEffect.to(
      _originalPosition,
      EffectController(duration: GameConstants.cardAnimationDuration),
    );
    
    final scaleEffect = ScaleEffect.to(
      Vector2.all(1.0), // Back to original scale
      EffectController(duration: GameConstants.cardAnimationDuration),
    );
    
    final rotateEffect = RotateEffect.to(
      _rotation, // Back to original rotation
      EffectController(duration: GameConstants.cardAnimationDuration),
    );
    
    // Add completion callback
    moveEffect.onComplete = () {
      _isAnimating = false;
    };
    
    add(moveEffect);
    add(scaleEffect);
    add(rotateEffect);
  }
  
  void setOriginalPosition(Vector2 newPosition) {
    _originalPosition = newPosition.clone();
    position = newPosition.clone();
  }
  
  void setRotation(double rotationAngle) {
    _rotation = rotationAngle;
    angle = _rotation;
  }
  
  // Force deselect this card (called when another card is selected)
  void forceDeselect() {
    if (_isSelected && !_isAnimating && !_isDragging) {
      _deselectCard();
    }
  }
  
  // Drag-related methods
  void _startDragging(Vector2 startPosition) {
    _isDragging = true;
    _dragStartPosition = position.clone();
    
    // Apply drag visual effects
    paint = _dragPaint;
    scale = Vector2.all(GameConstants.dragCardScale);
    
    // Set highest priority to appear on top during drag
    priority = 2000;
  }
  
  void _updateDragPosition(Vector2 localPosition) {
    if (!_isDragging) return;
    
    // Update card position directly with the drag delta
    position = _dragStartPosition! + (localPosition - _tapStartPosition!);
    
    // Check if card is over play area and update highlight
    if (_playArea != null) {
      final isOverPlayArea = _playArea!.isCardOver(position, size * scale.x);
      if (isOverPlayArea && !_playArea!.isHighlighted) {
        _playArea!.highlight();
      } else if (!isOverPlayArea && _playArea!.isHighlighted) {
        _playArea!.removeHighlight();
      }
    }
  }
  
  void _endDragging() {
    if (!_isDragging) return;
    
    bool droppedInPlayArea = false;
    
    // Check if card was dropped in play area
    if (_playArea != null) {
      droppedInPlayArea = _playArea!.isCardOver(position, size * scale.x);
      _playArea!.removeHighlight();
      
      if (droppedInPlayArea) {
        // Remove card from hand (handled by parent CardDeck)
        final parent = this.parent;
        if (parent is CardDeck) {
          parent.removeCardFromHand(this);
        }
        return;
      }
    }
    
    // If not dropped in play area, return to original position
    _returnToOriginalPosition();
  }
  
  void _cancelDragging() {
    if (!_isDragging) return;
    
    // Remove play area highlight if present
    if (_playArea != null) {
      _playArea!.removeHighlight();
    }
    
    // Return to original position
    _returnToOriginalPosition();
  }
  
  void _returnToOriginalPosition() {
    _isDragging = false;
    _isAnimating = true;
    
    // Reset visual effects
    paint = _normalPaint;
    
    // Reset priority to original value
    final parent = this.parent;
    if (parent is CardDeck) {
      priority = parent.getCardPriority(this);
    }
    
    // Animate back to original position, scale, and rotation
    final moveEffect = MoveEffect.to(
      _originalPosition,
      EffectController(duration: GameConstants.cardAnimationDuration),
    );
    
    final scaleEffect = ScaleEffect.to(
      Vector2.all(1.0),
      EffectController(duration: GameConstants.cardAnimationDuration),
    );
    
    final rotateEffect = RotateEffect.to(
      _rotation,
      EffectController(duration: GameConstants.cardAnimationDuration),
    );
    
    moveEffect.onComplete = () {
      _isAnimating = false;
      _isSelected = false;
    };
    
    add(moveEffect);
    add(scaleEffect);
    add(rotateEffect);
  }
  
  // Method to set the play area reference
  void setPlayArea(PlayArea? playArea) {
    _playArea = playArea;
  }
  
  // Getters for external access
  Vector2 get originalPosition => _originalPosition.clone();
  double get cardRotation => _rotation;
  bool get isSelected => _isSelected;
  bool get isAnimating => _isAnimating;
  bool get isDragging => _isDragging;
}
