import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GameCard extends SpriteComponent with HasGameRef, TapCallbacks, HoverCallbacks {
  static const double cardWidth = 70.0;
  static const double cardHeight = 100.0;
  static const double cardScale = 1.0;
  static const double highlightScale = 1.4;
  
  bool _isHighlighted = false;
  late Vector2 _originalPosition;
  // Removed unused _originalSize
  bool _isAnimating = false;
  
  @override
  Future<void> onLoad() async {
    // Load the card sprite
    sprite = await Sprite.load('card.png');
    
    // Set card dimensions
    size = Vector2(cardWidth.w, cardHeight.h);
    
    // Store original position
    _originalPosition = position.clone();
  }
  
  @override
  void onHoverEnter() {
    if (!_isAnimating) {
      _highlightCard();
    }
  }

  @override
  void onHoverExit() {
    if (!_isAnimating) {
      _unhighlightCard();
    }
  }
  
  @override
  bool onTapDown(TapDownEvent event) {
    if (!_isAnimating) {
      if (_isHighlighted) {
        _unhighlightCard();
      } else {
        _highlightCard();
      }
    }
    return true;
  }
  
  void _highlightCard() {
    if (_isHighlighted || _isAnimating) return;
    
    _isAnimating = true;
    _isHighlighted = true;
    
    // Bring card to front by adjusting priority
    priority = 100;
    
    // Calculate new position (move up and center a bit)
    final newPosition = Vector2(
      _originalPosition.x,
      _originalPosition.y - (cardHeight * (highlightScale - 1) * 0.5).h,
    );
    
    // Scale and position animation
    final scaleEffect = ScaleEffect.to(
      Vector2.all(highlightScale),
      EffectController(duration: 0.2),
    );
    
    final moveEffect = MoveEffect.to(
      newPosition,
      EffectController(duration: 0.2),
    );
    
    scaleEffect.onComplete = () {
      _isAnimating = false;
    };
    
    add(scaleEffect);
    add(moveEffect);
  }
  
  void _unhighlightCard() {
    if (!_isHighlighted || _isAnimating) return;
    
    _isAnimating = true;
    _isHighlighted = false;
    
    // Reset priority
    priority = 0;
    
    // Scale and position animation back to original
    final scaleEffect = ScaleEffect.to(
      Vector2.all(cardScale),
      EffectController(duration: 0.2),
    );
    
    final moveEffect = MoveEffect.to(
      _originalPosition,
      EffectController(duration: 0.2),
    );
    
    scaleEffect.onComplete = () {
      _isAnimating = false;
    };
    
    add(scaleEffect);
    add(moveEffect);
  }
  
  void setOriginalPosition(Vector2 newPosition) {
    _originalPosition = newPosition.clone();
    position = newPosition.clone();
  }
}