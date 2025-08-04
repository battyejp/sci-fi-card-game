import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../game/my_game.dart';

class GameScreen extends StatelessWidget {
  final VoidCallback onBack;
  const GameScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Game takes full screen
            Positioned.fill(
              child: GameWidget(game: MyGame()),
            ),
            // Back button overlay
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: onBack,
                  iconSize: 24,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
