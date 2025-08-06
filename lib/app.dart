import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'ui/theme/app_theme.dart';
import 'game/data/game_constants.dart';
import 'game_root.dart';

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
