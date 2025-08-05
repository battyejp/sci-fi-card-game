import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GameCard extends SpriteComponent with HasGameRef, TapCallbacks, HoverCallbacks {
  static const double cardWidth = 50.0;  // Smaller cards in hand
  static const double cardHeight = 70.0; // Smaller cards in hand
  static const double selectedCardWidth = 200.0;  // Much larger when selected
  static const double selectedCardHeight = 280.0; // Much larger when selected
  
  bool _isSelected = false;
  late Vector2 _originalPosition;
  late double _originalAngle;
  bool _isAnimating = false;
  
  // Callback for when this card is selected
  Function(GameCard)? onCardSelected;
  
  @override
  Future<void> onLoad() async {
    // Load the card sprite
    sprite = await Sprite.load('card.png');
    
    // Set initial card dimensions (smaller for hand)
    size = Vector2(cardWidth.w, cardHeight.h);
    
    // Set anchor to center for rotation
    anchor = Anchor.center;
  }
  
  @override
  void onHoverEnter() {
    if (!_isAnimating) {
      _selectCard();
    }
  }

  @override
  void onHoverExit() {
    // Don't auto-deselect on hover exit for better UX
    // Cards will only deselect when another card is selected
  }
  
  @override
  bool onTapDown(TapDownEvent event) {
    if (!_isAnimating) {
      if (_isSelected) {
        _deselectCard();
      } else {
        _selectCard();
      }
    }
    return true;
  }
  
  void _selectCard() {
    if (_isSelected || _isAnimating) return;
    
    _isAnimating = true;
    _isSelected = true;
    
    // Notify the deck about selection
    onCardSelected?.call(this);
    
    // Calculate center position of the game
    final gameSize = gameRef.size;
    final centerPosition = Vector2(gameSize.x / 2, gameSize.y / 2);
    
    // Create simultaneous animations for position, size, and rotation
    final moveEffect = MoveEffect.to(
      centerPosition,
      EffectController(duration: 0.3),
    );
    
    final scaleEffect = ScaleEffect.to(
      Vector2(selectedCardWidth.w / cardWidth.w, selectedCardHeight.h / cardHeight.h),
      EffectController(duration: 0.3),
    );
    
    // Reset rotation to 0 when selected (card becomes upright)
    final rotateEffect = RotateEffect.to(
      0,
      EffectController(duration: 0.3),
    );
    
    // Set completion callback on one of the effects
    moveEffect.onComplete = () {
      _isAnimating = false;
    };
    
    add(moveEffect);
    add(scaleEffect);
    add(rotateEffect);
  }
  
  void _deselectCard() {
    if (!_isSelected || _isAnimating) return;
    
    _isAnimating = true;
    _isSelected = false;
    
    // Return to original position, size, and rotation
    final moveEffect = MoveEffect.to(
      _originalPosition,
      EffectController(duration: 0.3),
    );
    
    final scaleEffect = ScaleEffect.to(
      Vector2.all(1.0), // Return to original scale
      EffectController(duration: 0.3),
    );
    
    final rotateEffect = RotateEffect.to(
      _originalAngle,
      EffectController(duration: 0.3),
    );
    
    moveEffect.onComplete = () {
      _isAnimating = false;
    };
    
    add(moveEffect);
    add(scaleEffect);
    add(rotateEffect);
  }
  
  // Public method to deselect card (called by deck)
  void deselectCard() {
    if (_isSelected && !_isAnimating) {
      _deselectCard();
    }
  }
  
  void setOriginalPosition(Vector2 newPosition) {
    _originalPosition = newPosition.clone();
    position = newPosition.clone();
  }
  
  void setOriginalAngle(double angle) {
    _originalAngle = angle;
    this.angle = angle;
  }
  
  // Getter to check if card is selected (for deck management)
  bool get isSelected => _isSelected;
}