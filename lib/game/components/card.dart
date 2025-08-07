import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sci_fi_card_game/game/components/card_deck.dart';
import 'play_area.dart';
import '../data/game_constants.dart';

class GameCard extends SpriteComponent with HasGameReference, TapCallbacks, DragCallbacks {
  late Vector2 _originalPosition;
  late Vector2 _originalSize;
  double _rotation = 0.0;
  bool _isSelected = false;
  bool _isAnimating = false;
  
  // Drag-related state
  bool _isDragging = false;
  Vector2? _dragStartPosition;
  Vector2? _tapDownPosition;
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
  }
  
  @override
  bool onTapDown(TapDownEvent event) {
    if (!_isAnimating) {
      _tapDownPosition = event.localPosition;
      _selectCardAtPosition(event.localPosition);
    }
    return true;
  }

  @override
  bool onTapUp(TapUpEvent event) {
    if (_isSelected && !_isAnimating && !_isDragging) {
      _deselectCard();
    }
    _tapDownPosition = null;
    return true;
  }

  @override
  bool onTapCancel(TapCancelEvent event) {
    if (_isSelected && !_isAnimating && !_isDragging) {
      _deselectCard();
    }
    _tapDownPosition = null;
    return true;
  }
  
  @override
  bool onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    
    // Only start dragging if the card is selected and we have a tap position
    if (!_isSelected || _tapDownPosition == null) return false;
    
    // Check if the drag distance exceeds the threshold
    final dragDistance = (event.localPosition - _tapDownPosition!).length;
    if (dragDistance < GameConstants.dragThreshold) return false;
    
    _isDragging = true;
    _dragStartPosition = position.clone();
    
    // Apply drag visual effects
    scale = Vector2.all(GameConstants.dragCardScale);
    opacity = GameConstants.dragCardOpacity;
    
    // Set highest priority to appear on top
    priority = 2000;
    
    // Highlight play area if available
    _playArea?.setHighlighted(true);
    
    return true;
  }
  
  @override
  bool onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    
    if (!_isDragging) return false;
    
    // Update card position to follow drag
    position = _dragStartPosition! + event.localDelta;
    
    // Check if dragging over play area and update highlight
    if (_playArea != null) {
      final isOverPlayArea = _playArea!.containsPoint(position);
      _playArea!.setHighlighted(isOverPlayArea);
    }
    
    return true;
  }
  
  @override
  bool onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    
    if (!_isDragging) return false;
    
    _isDragging = false;
    
    // Remove play area highlight
    _playArea?.setHighlighted(false);
    
    // Check if dropped in play area
    bool droppedInPlayArea = false;
    if (_playArea != null && _playArea!.containsPoint(position)) {
      droppedInPlayArea = true;
      _handleSuccessfulDrop();
    } else {
      _handleFailedDrop();
    }
    
    return true;
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
    if (_isSelected && !_isAnimating) {
      _deselectCard();
    }
  }
  
  // Getters for external access
  Vector2 get originalPosition => _originalPosition.clone();
  double get cardRotation => _rotation;
  bool get isSelected => _isSelected;
  bool get isAnimating => _isAnimating;
  bool get isDragging => _isDragging;
  
  // Set play area reference
  void setPlayArea(PlayArea? playArea) {
    _playArea = playArea;
  }
  
  // Handle successful drop in play area
  void _handleSuccessfulDrop() {
    // Notify parent (CardDeck) to remove this card
    final parent = this.parent;
    if (parent is CardDeck) {
      parent.removeCard(this);
    }
  }
  
  // Handle failed drop (return to hand)
  void _handleFailedDrop() {
    _isAnimating = true;
    
    // Reset visual effects
    scale = Vector2.all(1.0);
    paint = Paint(); // Reset to default paint
    
    // Animate back to original position
    final moveEffect = MoveEffect.to(
      _originalPosition,
      EffectController(duration: GameConstants.cardAnimationDuration),
    );
    
    moveEffect.onComplete = () {
      _isAnimating = false;
      _isSelected = false;
      
      // Reset priority to original value
      final parent = this.parent;
      if (parent is CardDeck) {
        priority = parent.getCardPriority(this);
      }
    };
    
    add(moveEffect);
  }
}
