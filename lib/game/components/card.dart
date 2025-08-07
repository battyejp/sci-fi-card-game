import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:sci_fi_card_game/game/components/card_deck.dart';
import 'package:sci_fi_card_game/game/components/play_area.dart';
import '../data/game_constants.dart';

class GameCard extends SpriteComponent with HasGameReference, TapCallbacks, HasDragCallbacks {
  late Vector2 _originalPosition;
  late Vector2 _originalSize;
  double _rotation = 0.0;
  bool _isSelected = false;
  bool _isAnimating = false;
  bool _isDragging = false;
  bool _isDragStarted = false;
  Vector2? _dragStartPosition;
  Vector2? _dragStartCardPosition;
  late Vector2 _dragOffset;
  
  static const double dragThreshold = 10.0; // Minimum distance to start drag
  static const double dragScale = 0.7; // Scale factor when dragging
  static const double dragOpacity = 0.8; // Opacity when dragging
  
  // Callback for when card selection changes
  Function(GameCard)? onSelectionChanged;
  // Callback for when card is dropped in play area
  Function(GameCard)? onCardPlayedToArea;
  
  @override
  Future<void> onLoad() async {
    // Load the card sprite
    sprite = await Sprite.load('card.png');
    
    // Set card dimensions using constants (smaller size for hand)
    size = Vector2(GameConstants.handCardWidth, GameConstants.handCardHeight);
    _originalSize = size.clone();
    
    // Store original position
    _originalPosition = position.clone();
    
    // Set anchor to center for proper rotation
    anchor = Anchor.center;
  }
  
  @override
  bool onTapDown(TapDownEvent event) {
    if (!_isAnimating && !_isDragging) {
      _selectCardAtPosition(event.localPosition);
      _dragStartPosition = event.localPosition;
      _isDragStarted = false;
    }
    return true;
  }

  @override
  bool onTapUp(TapUpEvent event) {
    if (_isSelected && !_isAnimating && !_isDragging) {
      _deselectCard();
    }
    _resetDragState();
    return true;
  }

  @override
  bool onTapCancel(TapCancelEvent event) {
    if (_isSelected && !_isAnimating && !_isDragging) {
      _deselectCard();
    }
    _resetDragState();
    return true;
  }

  @override
  bool onDragStart(DragStartEvent event) {
    if (_isSelected && !_isAnimating) {
      _startDragging(event.localPosition);
      return true;
    }
    return false;
  }

  @override
  bool onDragUpdate(DragUpdateEvent event) {
    if (_isDragging) {
      _updateDragPosition(event.localPosition);
      _checkPlayAreaHighlight();
      return true;
    } else if (_isSelected && _dragStartPosition != null) {
      // Check if we should start dragging based on distance moved
      final distance = (event.localPosition - _dragStartPosition!).length;
      if (distance > dragThreshold) {
        _startDragging(event.localPosition);
        return true;
      }
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

  void _startDragging(Vector2 localPosition) {
    if (_isDragging || _isAnimating) return;
    
    _isDragging = true;
    _isDragStarted = true;
    _dragOffset = localPosition;
    _dragStartCardPosition = position.clone();
    
    // Set highest priority to appear on top of everything
    priority = 2000;
    
    // Scale down and make semi-transparent
    add(ScaleEffect.to(
      Vector2.all(dragScale),
      EffectController(duration: 0.1),
    ));
    
    // Make semi-transparent
    add(OpacityEffect.to(
      dragOpacity,
      EffectController(duration: 0.1),
    ));
  }
  
  void _updateDragPosition(Vector2 localPosition) {
    if (!_isDragging || _dragStartCardPosition == null) return;
    
    // Calculate new position based on the drag movement
    final deltaPosition = localPosition - _dragOffset;
    position = _dragStartCardPosition! + deltaPosition;
  }
  
  void _checkPlayAreaHighlight() {
    // Find the play area component by traversing the game's children
    PlayArea? playArea;
    for (final component in game.children) {
      if (component is PlayArea) {
        playArea = component;
        break;
      }
    }
    
    if (playArea != null) {
      final cardCenter = position + size / 2;
      final isOverPlayArea = playArea.containsPoint(cardCenter);
      playArea.setHighlighted(isOverPlayArea);
    }
  }
  
  void _endDragging() {
    if (!_isDragging) return;
    
    // Check if card is dropped in play area
    PlayArea? playArea;
    for (final component in game.children) {
      if (component is PlayArea) {
        playArea = component;
        break;
      }
    }
    
    bool droppedInPlayArea = false;
    
    if (playArea != null) {
      final cardCenter = position + size / 2;
      droppedInPlayArea = playArea.containsPoint(cardCenter);
      playArea.setHighlighted(false);
    }
    
    _isDragging = false;
    _isAnimating = true;
    
    if (droppedInPlayArea) {
      // Card played to area - notify callback and remove from hand
      onCardPlayedToArea?.call(this);
      _animateToPlayArea();
    } else {
      // Return to original position
      _returnToHand();
    }
  }
  
  void _animateToPlayArea() {
    // Animate to center of play area and then remove
    PlayArea? playArea;
    for (final component in game.children) {
      if (component is PlayArea) {
        playArea = component;
        break;
      }
    }
    
    if (playArea != null) {
      final targetPosition = playArea.position + playArea.size / 2 - size / 2;
      
      final moveEffect = MoveEffect.to(
        targetPosition,
        EffectController(duration: GameConstants.cardAnimationDuration),
      );
      
      final scaleEffect = ScaleEffect.to(
        Vector2.all(0.5),
        EffectController(duration: GameConstants.cardAnimationDuration),
      );
      
      final fadeEffect = OpacityEffect.to(
        0.0,
        EffectController(duration: GameConstants.cardAnimationDuration),
      );
      
      moveEffect.onComplete = () {
        removeFromParent();
      };
      
      add(moveEffect);
      add(scaleEffect);
      add(fadeEffect);
    }
  }
  
  void _returnToHand() {
    // Animate back to original position and properties
    final moveEffect = MoveEffect.to(
      _originalPosition,
      EffectController(duration: GameConstants.cardAnimationDuration),
    );
    
    final scaleEffect = ScaleEffect.to(
      Vector2.all(1.0),
      EffectController(duration: GameConstants.cardAnimationDuration),
    );
    
    final opacityEffect = OpacityEffect.to(
      1.0,
      EffectController(duration: GameConstants.cardAnimationDuration),
    );
    
    final rotateEffect = RotateEffect.to(
      _rotation,
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
    add(scaleEffect);
    add(opacityEffect);
    add(rotateEffect);
  }
  
  void _resetDragState() {
    _dragStartPosition = null;
    _dragStartCardPosition = null;
    _isDragStarted = false;
  }
}
