import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ui/screens/loading_screen.dart';
import 'ui/screens/main_menu.dart';
import 'ui/screens/game_screen.dart';
import 'ui/theme/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'game/data/game_constants.dart';


void main() {
  // Force landscape orientation for mobile
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  // Hide status bar for immersive experience
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // Use responsive design based on actual screen size
      designSize: _getDesignSize(),
      minTextAdapt: true,
      splitScreenMode: true, // Better support for different screen sizes
      builder: (context, child) {
        return MaterialApp(
          title: 'Sci-Fi Card Game',
          theme: AppTheme.darkTheme,
          home: const GameRoot(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
  
  // Calculate design size based on common mobile landscape dimensions
  Size _getDesignSize() {
    // Use MediaQuery to get actual screen size if available
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final screenSize = view.physicalSize / view.devicePixelRatio;
    
    // If screen is wider than our standard, use actual size
    // Otherwise use our standard mobile landscape size
    if (screenSize.width > GameConstants.gameWidth) {
      return Size(screenSize.width, screenSize.height);
    }
    
    return const Size(GameConstants.gameWidth, GameConstants.gameHeight);
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
