import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../data/game_constants.dart';

class PlayArea extends RectangleComponent with HasGameReference {
  bool _isHighlighted = false;
  late Paint _normalPaint;
  late Paint _highlightedPaint;
  
  @override
  Future<void> onLoad() async {
    // Set size and position for the play area
    size = Vector2(GameConstants.playAreaWidth, GameConstants.playAreaHeight);
    
    // Center the play area on screen
    final gameSize = game.size;
    position = Vector2(
      (gameSize.x - size.x) / 2,
      (gameSize.y - size.y) / 2,
    );
    
    // Set anchor to top-left for easier positioning
    anchor = Anchor.topLeft;
    
    // Initialize paint objects
    _normalPaint = Paint()
      ..color = GameConstants.playAreaColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = GameConstants.playAreaBorderWidth;
    
    _highlightedPaint = Paint()
      ..color = GameConstants.playAreaHighlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = GameConstants.playAreaBorderWidth;
    
    // Set initial paint
    paint = _normalPaint;
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
  
  /// Highlights the play area when a card is being dragged over it
  void highlight() {
    if (!_isHighlighted) {
      _isHighlighted = true;
      paint = _highlightedPaint;
    }
  }
  
  /// Removes highlight from the play area
  void removeHighlight() {
    if (_isHighlighted) {
      _isHighlighted = false;
      paint = _normalPaint;
    }
  }
  
  /// Checks if a point is inside the play area
  @override
  bool containsPoint(Vector2 point) {
    final localPoint = absoluteToLocal(point);
    return localPoint.x >= 0 && 
           localPoint.x <= size.x && 
           localPoint.y >= 0 && 
           localPoint.y <= size.y;
  }
  
  /// Checks if a card (represented by its center position) is over the play area
  bool isCardOver(Vector2 cardPosition) {
    return containsPoint(cardPosition);
  }
  
  // Getters
  bool get isHighlighted => _isHighlighted;
}