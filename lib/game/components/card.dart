import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sci_fi_card_game/game/components/card_deck.dart';
import 'package:sci_fi_card_game/game/components/play_area.dart';
import '../data/game_constants.dart';

enum CardState {
  idle,
  selected,
  dragging,
}

class GameCard extends SpriteComponent with HasGameReference, TapCallbacks, HasDragCallbacks {
  late Vector2 _originalPosition;
  late Vector2 _originalSize;
  double _rotation = 0.0;
  CardState _state = CardState.idle;
  bool _isAnimating = false;
  
  // Drag-related properties
  Vector2? _dragStartPosition;
  Vector2? _initialTouchPosition;
  bool _isDragThresholdMet = false;
  
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
  }
  
  @override
  bool onTapDown(TapDownEvent event) {
    if (!_isAnimating && _state == CardState.idle) {
      _initialTouchPosition = event.localPosition;
      _selectCardAtPosition(event.localPosition);
    }
    return true;
  }

  @override
  bool onTapUp(TapUpEvent event) {
    if (_state == CardState.selected && !_isAnimating && !_isDragThresholdMet) {
      _deselectCard();
    }
    _resetDragState();
    return true;
  }

  @override
  bool onTapCancel(TapCancelEvent event) {
    if (_state == CardState.selected && !_isAnimating && !_isDragThresholdMet) {
      _deselectCard();
    }
    _resetDragState();
    return true;
  }
  
  @override
  bool onDragStart(DragStartEvent event) {
    if (_state == CardState.selected && !_isAnimating) {
      _dragStartPosition = position.clone();
      return true;
    }
    return false;
  }
  
  @override
  bool onDragUpdate(DragUpdateEvent event) {
    if (_state == CardState.selected || _state == CardState.dragging) {
      // Check if we've met the drag threshold
      if (!_isDragThresholdMet && _initialTouchPosition != null) {
        final distance = (event.localPosition - _initialTouchPosition!).length;
        if (distance > GameConstants.dragThreshold) {
          _isDragThresholdMet = true;
          _startDragging();
        }
      }
      
      if (_state == CardState.dragging) {
        // Update card position
        position += event.localDelta;
        
        // Check if we're over the play area
        final cardDeck = parent as CardDeck?;
        final playArea = cardDeck?.playArea;
        if (playArea != null) {
          final cardCenter = position + size / 2;
          if (playArea.containsPoint(cardCenter)) {
            playArea.highlight();
          } else {
            playArea.removeHighlight();
          }
        }
      }
      return true;
    }
    return false;
  }
  
  @override
  bool onDragEnd(DragEndEvent event) {
    if (_state == CardState.dragging) {
      _handleDragEnd();
      return true;
    }
    _resetDragState();
    return false;
  }
  
  void _selectCardAtPosition(Vector2 pressPosition) {
    if (_state != CardState.idle || _isAnimating) return;

    _state = CardState.selected;
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
    if (_state != CardState.selected || _isAnimating) return;
    
    _state = CardState.idle;
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
  
  void _startDragging() {
    if (_state != CardState.selected) return;
    
    _state = CardState.dragging;
    
    // Apply drag visual effects
    add(ScaleEffect.to(
      Vector2.all(GameConstants.dragCardScale),
      EffectController(duration: 0.1),
    ));
    
    add(OpacityEffect.to(
      GameConstants.dragCardOpacity,
      EffectController(duration: 0.1),
    ));
  }
  
  void _handleDragEnd() {
    final cardDeck = parent as CardDeck?;
    final playArea = cardDeck?.playArea;
    
    if (playArea != null) {
      final cardCenter = position + size / 2;
      
      if (playArea.containsPoint(cardCenter)) {
        // Card was dropped in play area - remove it from hand
        playArea.removeHighlight();
        cardDeck?.removeCard(this);
        return;
      } else {
        // Card was dropped outside play area - return to hand
        playArea.removeHighlight();
        _returnToHand();
      }
    } else {
      // No play area available - return to hand
      _returnToHand();
    }
  }
  
  void _returnToHand() {
    _state = CardState.idle;
    _isAnimating = true;
    
    // Reset priority
    final parent = this.parent;
    if (parent is CardDeck) {
      priority = parent.getCardPriority(this);
    }
    
    // Animate back to original position, scale, and opacity
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
    
    final opacityEffect = OpacityEffect.to(
      1.0,
      EffectController(duration: GameConstants.cardAnimationDuration),
    );
    
    moveEffect.onComplete = () {
      _isAnimating = false;
    };
    
    add(moveEffect);
    add(scaleEffect);
    add(rotateEffect);
    add(opacityEffect);
  }
  
  void _resetDragState() {
    _dragStartPosition = null;
    _initialTouchPosition = null;
    _isDragThresholdMet = false;
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
    if (_state == CardState.selected && !_isAnimating) {
      _deselectCard();
    }
  }
  
  // Getters for external access
  Vector2 get originalPosition => _originalPosition.clone();
  double get cardRotation => _rotation;
  bool get isSelected => _state == CardState.selected;
  bool get isDragging => _state == CardState.dragging;
  bool get isAnimating => _isAnimating;
  CardState get state => _state;
}
