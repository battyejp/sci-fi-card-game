import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../data/game_constants.dart';

class PlayArea extends RectangleComponent with HasGameReference {
  bool _isHighlighted = false;
  late Paint _normalPaint;
  late Paint _highlightPaint;
  
  @override
  Future<void> onLoad() async {
    // Set size and position
    size = Vector2(GameConstants.playAreaWidth.w, GameConstants.playAreaHeight.h);
    
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
      ..style = PaintingStyle.fill;
    
    _highlightPaint = Paint()
      ..color = GameConstants.playAreaHighlightColor
      ..style = PaintingStyle.fill;
    
    // Set initial paint
    paint = _normalPaint;
    
    // Set a lower priority so cards appear above the play area
    priority = -1;
  }
  
  @override
  void render(Canvas canvas) {
    // Draw the rounded rectangle background
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(GameConstants.playAreaBorderRadius.r),
    );
    
    // Fill the background
    canvas.drawRRect(rrect, paint);
    
    // Draw the border
    final borderPaint = Paint()
      ..color = _isHighlighted ? GameConstants.playAreaHighlightColor : GameConstants.playAreaColor.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = GameConstants.playAreaBorderWidth.w;
    
    canvas.drawRRect(rrect, borderPaint);
  }
  
  /// Highlights the play area to indicate it's a valid drop target
  void highlight() {
    if (!_isHighlighted) {
      _isHighlighted = true;
      paint = _highlightPaint;
    }
  }
  
  /// Removes the highlight from the play area
  void removeHighlight() {
    if (_isHighlighted) {
      _isHighlighted = false;
      paint = _normalPaint;
    }
  }
  
  /// Checks if a card is positioned over the play area
  bool isCardOver(Vector2 cardPosition, Vector2 cardSize) {
    // Calculate card bounds
    final cardLeft = cardPosition.x - cardSize.x / 2;
    final cardRight = cardPosition.x + cardSize.x / 2;
    final cardTop = cardPosition.y - cardSize.y / 2;
    final cardBottom = cardPosition.y + cardSize.y / 2;
    
    // Calculate play area bounds
    final playAreaLeft = position.x;
    final playAreaRight = position.x + size.x;
    final playAreaTop = position.y;
    final playAreaBottom = position.y + size.y;
    
    // Check if card overlaps with play area (at least 50% of card should be over play area)
    final overlapLeft = cardLeft.clamp(playAreaLeft, playAreaRight);
    final overlapRight = cardRight.clamp(playAreaLeft, playAreaRight);
    final overlapTop = cardTop.clamp(playAreaTop, playAreaBottom);
    final overlapBottom = cardBottom.clamp(playAreaTop, playAreaBottom);
    
    final overlapWidth = (overlapRight - overlapLeft).clamp(0.0, double.infinity);
    final overlapHeight = (overlapBottom - overlapTop).clamp(0.0, double.infinity);
    final overlapArea = overlapWidth * overlapHeight;
    
    final cardArea = cardSize.x * cardSize.y;
    
    // Return true if at least 50% of the card is over the play area
    return overlapArea >= (cardArea * 0.5);
  }
  
  @override
  bool containsPoint(Vector2 point) {
    // Check if the point is within the play area bounds
    return point.x >= position.x && 
           point.x <= position.x + size.x &&
           point.y >= position.y && 
           point.y <= position.y + size.y;
  }
  
  /// Gets the center position of the play area
  Vector2 get centerPosition => position + size / 2;
  
  /// Checks if the play area is currently highlighted
  bool get isHighlighted => _isHighlighted;
}