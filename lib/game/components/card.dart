import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../data/game_constants.dart';

class GameCard extends SpriteComponent with HasGameReference, TapCallbacks, HoverCallbacks {
  bool _isHighlighted = false;
  late Vector2 _originalPosition;
  bool _isAnimating = false;
  
  @override
  Future<void> onLoad() async {
    // Load the card sprite
    sprite = await Sprite.load('card.png');
    
    // Set card dimensions using constants
    size = Vector2(GameConstants.cardWidth.w, GameConstants.cardHeight.h);
    
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
      _originalPosition.y - (GameConstants.cardHeight * (GameConstants.highlightScale - 1) * 0.5).h,
    );
    
    // Scale and position animation
    final scaleEffect = ScaleEffect.to(
      Vector2.all(GameConstants.highlightScale),
      EffectController(duration: GameConstants.cardAnimationDuration),
    );
    
    final moveEffect = MoveEffect.to(
      newPosition,
      EffectController(duration: GameConstants.cardAnimationDuration),
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
      Vector2.all(GameConstants.cardScale),
      EffectController(duration: GameConstants.cardAnimationDuration),
    );
    
    final moveEffect = MoveEffect.to(
      _originalPosition,
      EffectController(duration: GameConstants.cardAnimationDuration),
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
  
  // Getters for external access
  bool get isHighlighted => _isHighlighted;
  bool get isAnimating => _isAnimating;
  Vector2 get originalPosition => _originalPosition.clone();
}
