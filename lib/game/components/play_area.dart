import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../data/game_constants.dart';

/// Central play area where cards can be dropped
class PlayArea extends RectangleComponent with HasGameReference, HasCollisionDetection {
  static const double playAreaWidth = 300.0;
  static const double playAreaHeight = 200.0;
  static const double cornerRadius = 20.0;
  
  bool _isHighlighted = false;
  late Paint _normalPaint;
  late Paint _highlightedPaint;
  
  @override
  Future<void> onLoad() async {
    // Position at center of screen
    final gameSize = game.size;
    position = Vector2(
      (gameSize.x - playAreaWidth) / 2,
      (gameSize.y - playAreaHeight) / 2,
    );
    size = Vector2(playAreaWidth, playAreaHeight);
    
    // Set up paints for normal and highlighted states
    _normalPaint = Paint()
      ..color = const Color(0xFF2A2A3E).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
      
    _highlightedPaint = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    
    paint = _normalPaint;
    
    // Add collision detection
    add(RectangleHitbox());
  }
  
  @override
  void render(Canvas canvas) {
    // Draw rounded rectangle
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(cornerRadius));
    
    canvas.drawRRect(rrect, paint);
    
    // Add a subtle fill when highlighted
    if (_isHighlighted) {
      final fillPaint = Paint()
        ..color = const Color(0xFF4CAF50).withOpacity(0.1)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rrect, fillPaint);
    }
  }
  
  /// Highlight the play area when a card is being dragged over it
  void setHighlighted(bool highlighted) {
    if (_isHighlighted != highlighted) {
      _isHighlighted = highlighted;
      paint = highlighted ? _highlightedPaint : _normalPaint;
    }
  }
  
  /// Check if a point is inside the play area
  bool containsPoint(Vector2 point) {
    final localPoint = point - position;
    return localPoint.x >= 0 && 
           localPoint.x <= size.x && 
           localPoint.y >= 0 && 
           localPoint.y <= size.y;
  }
  
  bool get isHighlighted => _isHighlighted;
}