import 'package:flame/game.dart';
import 'package:flame/components.dart';
// import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'card_deck.dart';

class MyGame extends FlameGame with HasTapCallbacks, HasHoverCallbacks {
  late CardDeck cardDeck;
  @override
  Future<void> onLoad() async {
    // Set a fixed landscape viewport (e.g., 800x450) to mimic a mobile phone
    // Fallback: If FixedResolutionViewport is not available, mimic a fixed landscape viewport by centering and scaling content manually.
    // You can also try using ScreenViewport() or Viewport() if available in your Flame version.
    // Example (no-op if not available):
    // camera.viewport = ScreenViewport();
    // For now, all components are positioned as if the screen is 800x450.

    // Add a simple background color
    add(RectangleComponent(
      size: Vector2(800.w, 450.h),
      paint: Paint()..color = const Color(0xFF1A1A2E),
    ));

    // Add a welcome text component
    add(TextComponent(
      text: 'Welcome to Sci-Fi Card Game!',
      position: Vector2(400.w, 125.h), // Moved up to make room for cards
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 24.sp,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ));

    // Add instructions text
    add(TextComponent(
      text: 'Hover or tap cards below to highlight them',
      position: Vector2(400.w, 175.h), // Updated instructions
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 16.sp,
          color: Colors.grey,
        ),
      ),
    ));

    // Add a simple animated circle
    add(CircleComponent(
      radius: 30.w,
      position: Vector2(400.w, 225.h), // Moved up to make room for cards
      paint: Paint()..color = Colors.blueAccent,
      anchor: Anchor.center,
    ));

    // Add the card deck at the bottom
    cardDeck = CardDeck();
    add(cardDeck);
  }

}
