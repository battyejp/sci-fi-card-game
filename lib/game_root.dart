import 'package:flutter/material.dart';
import 'ui/screens/loading_screen.dart';
import 'ui/screens/main_menu.dart';
import 'ui/screens/game_screen.dart';

class GameRoot extends StatefulWidget {
  const GameRoot({super.key});

  @override
  State<GameRoot> createState() => _GameRootState();
}

class _GameRootState extends State<GameRoot> {
  bool _loading = true;
  bool _inGame = false;

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  Future<void> _simulateLoading() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _loading = false;
    });
  }

  void _startGame() {
    setState(() {
      _inGame = true;
    });
  }

  void _exitGame() {
    setState(() {
      _inGame = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const LoadingScreen();
    } else if (_inGame) {
      return GameScreen(onBack: _exitGame);
    } else {
      return MainMenu(onPlay: _startGame);
    }
  }
}
