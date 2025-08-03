import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class MyGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    // Add a simple background color
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xFF1A1A2E),
    ));
    
    // Add a welcome text component
    add(TextComponent(
      text: 'Welcome to Sci-Fi Card Game!',
      position: Vector2(size.x / 2, size.y / 2 - 50),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ));
    
    // Add instructions text
    add(TextComponent(
      text: 'Game area - Add your game logic here',
      position: Vector2(size.x / 2, size.y / 2 + 20),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    ));
    
    // Add a simple animated circle
    add(CircleComponent(
      radius: 30,
      position: Vector2(size.x / 2, size.y / 2 + 80),
      paint: Paint()..color = Colors.blueAccent,
      anchor: Anchor.center,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Game logic will go here
  }
}
