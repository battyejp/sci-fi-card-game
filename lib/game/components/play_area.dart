import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../data/game_constants.dart';

class PlayArea extends RectangleComponent with HasGameReference {
  bool _isHighlighted = false;
  late Paint _normalPaint;
  late Paint _highlightedPaint;
  
  @override
  Future<void> onLoad() async {
    // Set size and position for the play area
    size = Vector2(GameConstants.playAreaWidth.w, GameConstants.playAreaHeight.h);
    
    // Center the play area on screen
    final gameSize = game.size;
    position = Vector2(
      (gameSize.x - size.x) / 2,
      (gameSize.y - size.y) / 2,
    );
    
    // Set up paints for normal and highlighted states
    _normalPaint = Paint()
      ..color = GameConstants.playAreaColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = GameConstants.playAreaBorderWidth;
    
    _highlightedPaint = Paint()
      ..color = GameConstants.playAreaHighlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = GameConstants.playAreaBorderWidth;
    
    paint = _normalPaint;
    
    // Set up rounded corners
    decorator.addLast(PaintDecorator.blur(0));
  }
  
  @override
  void render(Canvas canvas) {
    // Draw rounded rectangle
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(GameConstants.playAreaCornerRadius),
    );
    
    canvas.drawRRect(rrect, paint);
  }
  
  /// Check if a point is within the play area bounds
  bool containsPoint(Vector2 point) {
    final localPoint = point - position;
    return localPoint.x >= 0 && 
           localPoint.x <= size.x && 
           localPoint.y >= 0 && 
           localPoint.y <= size.y;
  }
  
  /// Highlight the play area when a card is dragged over it
  void highlight() {
    if (!_isHighlighted) {
      _isHighlighted = true;
      paint = _highlightedPaint;
      
      // Add a subtle scale effect for visual feedback
      add(ScaleEffect.to(
        Vector2.all(1.05),
        EffectController(duration: GameConstants.playAreaHighlightDuration),
      ));
    }
  }
  
  /// Remove highlight when card is no longer over the play area
  void removeHighlight() {
    if (_isHighlighted) {
      _isHighlighted = false;
      paint = _normalPaint;
      
      // Return to normal scale
      add(ScaleEffect.to(
        Vector2.all(1.0),
        EffectController(duration: GameConstants.playAreaHighlightDuration),
      ));
    }
  }
  
  /// Get the center position of the play area in world coordinates
  Vector2 get centerPosition => position + size / 2;
  
  /// Check if the play area is currently highlighted
  bool get isHighlighted => _isHighlighted;
}