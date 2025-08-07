import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../data/game_constants.dart';

class PlayArea extends RectangleComponent with HasGameReference {
  bool _isHighlighted = false;
  late Paint _normalPaint;
  late Paint _highlightedPaint;
  
  @override
  Future<void> onLoad() async {
    // Set size and position
    size = Vector2(
      GameConstants.playAreaWidth.w, 
      GameConstants.playAreaHeight.h
    );
    
    // Center the play area on screen
    position = Vector2(
      (game.size.x - size.x) / 2,
      (game.size.y - size.y) / 2,
    );
    
    // Set anchor to top-left for easier positioning
    anchor = Anchor.topLeft;
    
    // Initialize paints
    _normalPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
      
    _highlightedPaint = Paint()
      ..color = Colors.green.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    
    // Set initial paint
    paint = _normalPaint;
  }
  
  @override
  void render(Canvas canvas) {
    // Draw rounded rectangle
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(
      rect, 
      Radius.circular(GameConstants.playAreaCornerRadius.r)
    );
    
    canvas.drawRRect(rrect, paint);
    
    // Draw border if highlighted
    if (_isHighlighted) {
      final borderPaint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawRRect(rrect, borderPaint);
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
  
  /// Highlight the play area to indicate it's a valid drop target
  void setHighlighted(bool highlighted) {
    if (_isHighlighted != highlighted) {
      _isHighlighted = highlighted;
      paint = highlighted ? _highlightedPaint : _normalPaint;
    }
  }
  
  /// Get the center position of the play area
  Vector2 get centerPosition => position + size / 2;
  
  /// Check if highlighted
  bool get isHighlighted => _isHighlighted;
}