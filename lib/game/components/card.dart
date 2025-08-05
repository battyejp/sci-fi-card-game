import 'package:flame/components.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../data/game_constants.dart';

class GameCard extends SpriteComponent with HasGameReference {
  late Vector2 _originalPosition;
  double _rotation = 0.0;
  
  @override
  Future<void> onLoad() async {
    // Load the card sprite
    sprite = await Sprite.load('card.png');
    
    // Set card dimensions using constants (smaller size for hand)
    size = Vector2(GameConstants.handCardWidth.w, GameConstants.handCardHeight.h);
    
    // Store original position
    _originalPosition = position.clone();
    
    // Set anchor to center for proper rotation
    anchor = Anchor.center;
  }
  
  void setOriginalPosition(Vector2 newPosition) {
    _originalPosition = newPosition.clone();
    position = newPosition.clone();
  }
  
  void setRotation(double rotationAngle) {
    _rotation = rotationAngle;
    angle = _rotation;
  }
  
  // Getters for external access
  Vector2 get originalPosition => _originalPosition.clone();
  double get cardRotation => _rotation;
}
}
