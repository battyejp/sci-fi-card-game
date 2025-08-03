import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GameCard extends RectangleComponent with HasGameRef, TapCallbacks, HoverCallbacks {
  static const double cardWidth = 70.0;
  static const double cardHeight = 100.0;
  static const double cardScale = 1.0;
  static const double highlightScale = 1.4;
  
  bool _isHighlighted = false;
  late Vector2 _originalPosition;
  late Vector2 _originalSize;
  bool _isAnimating = false;
  
  @override
  Future<void> onLoad() async {
    // Set card dimensions
    _originalSize = Vector2(cardWidth.w, cardHeight.h);
    size = _originalSize.clone();
    
    // Store original position
    _originalPosition = position.clone();
    
    // Create card appearance - placeholder design similar to the sci-fi card shown
    paint = Paint()..color = const Color(0xFF2A2A3E);
    
    // Add card border
    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.w,
      position: Vector2.zero(),
    )..paint.color = const Color(0xFFFFD700)); // Gold border
    
    // Add card cost indicator (top-left circle)
    add(CircleComponent(
      radius: 12.w,
      paint: Paint()..color = const Color(0xFF4A90E2),
      position: Vector2(12.w, 12.h),
    ));
    
    // Add cost number
    add(TextComponent(
      text: '2',
      position: Vector2(12.w, 12.h),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 10.sp,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ));
    
    // Add card title area
    add(RectangleComponent(
      size: Vector2(size.x - 8.w, 16.h),
      paint: Paint()..color = const Color(0xFF4A4A5E),
      position: Vector2(4.w, size.y - 20.h),
    ));
    
    // Add placeholder card title
    add(TextComponent(
      text: 'Sci-Fi Card',
      position: Vector2(size.x / 2, size.y - 12.h),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 8.sp,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    ));
    
    // Add main card artwork area
    add(RectangleComponent(
      size: Vector2(size.x - 8.w, size.y - 50.h),
      paint: Paint()..color = const Color(0xFF1A1A2E),
      position: Vector2(4.w, 30.h),
    ));
    
    // Add artwork placeholder (robot icon representation)
    add(RectangleComponent(
      size: Vector2(20.w, 25.h),
      paint: Paint()..color = const Color(0xFF6A6A7E),
      position: Vector2(size.x / 2 - 10.w, size.y / 2 - 12.h),
    ));
  }
  
  @override
  bool onHoverEnter(PointerHoverEvent event) {
    if (!_isAnimating) {
      _highlightCard();
    }
    return true;
  }
  
  @override
  bool onHoverExit(PointerHoverEvent event) {
    if (!_isAnimating) {
      _unhighlightCard();
    }
    return true;
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
    
    add(scaleEffect);
    add(moveEffect);
    
    // Reset animation flag after animation completes
    Future.delayed(const Duration(milliseconds: 200), () {
      _isAnimating = false;
    });
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
    
    add(scaleEffect);
    add(moveEffect);
    
    // Reset animation flag after animation completes
    Future.delayed(const Duration(milliseconds: 200), () {
      _isAnimating = false;
    });
  }
  
  void setOriginalPosition(Vector2 newPosition) {
    _originalPosition = newPosition.clone();
    position = newPosition.clone();
  }
}