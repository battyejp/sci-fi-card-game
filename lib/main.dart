import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'my_game.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(800, 450),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Flutter Flame Game',
          theme: ThemeData.dark(),
          home: const GameRoot(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

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

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 800.w,
          height: 450.h,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

class MainMenu extends StatelessWidget {
  final VoidCallback onPlay;
  const MainMenu({super.key, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 800.w,
          height: 450.h,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Sci-Fi Card Game', style: TextStyle(fontSize: 32.sp)),
              SizedBox(height: 32.h),
              ElevatedButton(
                onPressed: onPlay,
                child: Text('Play Game', style: TextStyle(fontSize: 18.sp)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  final VoidCallback onBack;
  const GameScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: const Text('Game'),
      ),
      body: GameWidget(game: MyGame()),
    );
  }
}
