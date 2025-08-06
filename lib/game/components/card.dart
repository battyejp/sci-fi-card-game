import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../data/game_constants.dart';

class GameCard extends SpriteComponent with HasGameReference, TapCallbacks {
  late Vector2 _originalPosition;
  late Vector2 _originalSize;
  double _rotation = 0.0;
  bool _isSelected = false;
  bool _isAnimating = false;
  
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
      _selectCard();
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
    if (_isSelected && !_isAnimating) {
      _deselectCard();
    }
    return true;
  }
  
  void _selectCard() {
    if (_isSelected || _isAnimating) return;
    
    _isSelected = true;
    _isAnimating = true;
    
    // Notify parent about selection change
    onSelectionChanged?.call(this);
    
    // Calculate center position of the screen
    final gameSize = game.size;
    final centerPosition = Vector2(gameSize.x / 2, gameSize.y / 2);
    
    // Calculate enlarged size
    final enlargedSize = Vector2(GameConstants.enlargedCardWidth.w, GameConstants.enlargedCardHeight.h);
    
    // Set highest priority to appear on top
    priority = 1000;
    
    // Animate to center with enlargement
    final moveEffect = MoveEffect.to(
      centerPosition,
      EffectController(duration: GameConstants.cardAnimationDuration),
    );
    
    final scaleEffect = ScaleEffect.to(
      Vector2.all(enlargedSize.x / _originalSize.x), // Scale factor
      EffectController(duration: GameConstants.cardAnimationDuration),
    );
    
    final rotateEffect = RotateEffect.to(
      0.0, // Remove rotation when centered
      EffectController(duration: GameConstants.cardAnimationDuration),
    );
    
    // Add completion callback to the last effect
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
}
