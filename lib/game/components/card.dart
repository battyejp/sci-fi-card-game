import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sci_fi_card_game/game/components/card_deck.dart';
import 'package:sci_fi_card_game/game/components/play_area.dart';
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
  late Vector2 _originalScale;
  late double _originalOpacity;
  
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
    
    // Initialize drag-related variables
    _originalScale = Vector2.all(1.0);
    _originalOpacity = 1.0;
    
    // Set anchor to center for proper rotation
    anchor = Anchor.center;
  }
  
  @override
  bool onTapDown(TapDownEvent event) {
    if (!_isAnimating && !_isDragging) {
      _tapDownPosition = event.localStartPosition;
      _selectCardAtPosition(event.localStartPosition);
    }
    return true;
  }

  @override
  bool onTapUp(TapUpEvent event) {
    if (_isSelected && !_isAnimating) {
      _deselectCard();
    }
    return true;
  }

  @override
  bool onTapCancel(TapCancelEvent event) {
    if (_isSelected && !_isAnimating && !_isDragging) {
      _deselectCard();
    }
    return true;
  }
  
  // Drag event handlers
  @override
  bool onDragStart(DragStartEvent event) {
    if (!_isSelected || _isAnimating) return false;
    
    // Check if we've moved enough to start dragging
    if (_tapDownPosition != null) {
      final distance = (event.localStartPosition - _tapDownPosition!).length;
      if (distance < GameConstants.dragThreshold) {
        return false; // Not enough movement to start drag
      }
    }
    
    _isDragging = true;
    _dragStartPosition = position.clone();
    
    // Set highest priority to appear on top during drag
    priority = 2000;
    
    // Apply drag visual effects
    _applyDragVisualEffects();
    
    return true;
  }
  
  @override
  bool onDragUpdate(DragUpdateEvent event) {
    if (!_isDragging) return false;
    
    // Update card position to follow drag
    position = _dragStartPosition! + event.localDelta;
    
    // Check if we're over the play area and update its highlight
    _updatePlayAreaHighlight();
    
    return true;
  }
  
  @override
  bool onDragEnd(DragEndEvent event) {
    if (!_isDragging) return false;
    
    _isDragging = false;
    
    // Remove play area highlight
    _removePlayAreaHighlight();
    
    // Check if card was dropped in play area
    final playArea = _getPlayArea();
    if (playArea != null && playArea.isCardOver(position)) {
      _handleDropInPlayArea();
    } else {
      _handleDropOutsidePlayArea();
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
    if (_isSelected && !_isAnimating && !_isDragging) {
      _deselectCard();
    }
  }
  
  // Drag helper methods
  void _applyDragVisualEffects() {
    // Scale down and make semi-transparent
    scale = Vector2.all(GameConstants.dragCardScale);
    opacity = GameConstants.dragCardOpacity;
  }
  
  void _removeDragVisualEffects() {
    // Restore original scale and opacity
    scale = _originalScale;
    opacity = _originalOpacity;
  }
  
  PlayArea? _getPlayArea() {
    // Find the play area component in the game
    return game.findByKey(ComponentKey.named('play_area')) as PlayArea?;
  }
  
  void _updatePlayAreaHighlight() {
    final playArea = _getPlayArea();
    if (playArea != null) {
      if (playArea.isCardOver(position)) {
        playArea.highlight();
      } else {
        playArea.removeHighlight();
      }
    }
  }
  
  void _removePlayAreaHighlight() {
    final playArea = _getPlayArea();
    playArea?.removeHighlight();
  }
  
  void _handleDropInPlayArea() {
    // Remove visual effects
    _removeDragVisualEffects();
    
    // Remove card from deck
    final parent = this.parent;
    if (parent is CardDeck) {
      parent.removeCard(this);
    }
    
    // Remove from game
    removeFromParent();
  }
  
  void _handleDropOutsidePlayArea() {
    // Remove visual effects
    _removeDragVisualEffects();
    
    // Reset priority
    final parent = this.parent;
    if (parent is CardDeck) {
      priority = parent.getCardPriority(this);
    }
    
    // Animate back to original position
    _animateToPosition(_originalPosition);
  }
  
  void _animateToPosition(Vector2 targetPosition) {
    _isAnimating = true;
    
    final moveEffect = MoveEffect.to(
      targetPosition,
      EffectController(duration: GameConstants.cardAnimationDuration),
    );
    
    moveEffect.onComplete = () {
      _isAnimating = false;
      position = targetPosition;
    };
    
    add(moveEffect);
  }
  
  // Getters for external access
  Vector2 get originalPosition => _originalPosition.clone();
  double get cardRotation => _rotation;
  bool get isSelected => _isSelected;
  bool get isAnimating => _isAnimating;
  bool get isDragging => _isDragging;
}
