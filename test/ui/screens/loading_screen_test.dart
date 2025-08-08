import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:sci_fi_card_game/ui/screens/loading_screen.dart';

void main() {
  group('LoadingScreen Widget Tests', () {
    testWidgets('renders loading indicator and text', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(932, 430),
          builder: (context, child) => const MaterialApp(
            home: LoadingScreen(),
          ),
        ),
      );

      // Check for loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Check for loading text
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('has correct widget hierarchy', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(932, 430),
          builder: (context, child) => const MaterialApp(
            home: LoadingScreen(),
          ),
        ),
      );

      // Check main structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('loading indicator has correct properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(932, 430),
          builder: (context, child) => const MaterialApp(
            home: LoadingScreen(),
          ),
        ),
      );

      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );

      expect(progressIndicator.strokeWidth, equals(3.0));
      expect(progressIndicator.valueColor, isA<AlwaysStoppedAnimation<Color>>());
      
      final valueColor = progressIndicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(valueColor.value, equals(Colors.blueAccent));
    });

    testWidgets('loading text has correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(932, 430),
          builder: (context, child) => const MaterialApp(
            home: LoadingScreen(),
          ),
        ),
      );

      final loadingText = tester.widget<Text>(find.text('Loading...'));
      
      expect(loadingText.style?.color, equals(Colors.white70));
      // Font size will be scaled by ScreenUtil, so we check that a style is applied
      expect(loadingText.style?.fontSize, isNotNull);
    });

    testWidgets('layout spacing is correct', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(932, 430),
          builder: (context, child) => const MaterialApp(
            home: LoadingScreen(),
          ),
        ),
      );

      // Check that there's spacing between the progress indicator and text
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('column alignment is centered', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(932, 430),
          builder: (context, child) => const MaterialApp(
            home: LoadingScreen(),
          ),
        ),
      );

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.mainAxisAlignment, equals(MainAxisAlignment.center));
    });

    testWidgets('handles different screen sizes', (WidgetTester tester) async {
      // Test portrait orientation
      await tester.binding.setSurfaceSize(const Size(430, 932));
      
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(430, 932),
          builder: (context, child) => const MaterialApp(
            home: LoadingScreen(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
      
      // Test landscape orientation
      await tester.binding.setSurfaceSize(const Size(932, 430));
      
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(932, 430),
          builder: (context, child) => const MaterialApp(
            home: LoadingScreen(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('is a StatelessWidget', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(932, 430),
          builder: (context, child) => const MaterialApp(
            home: LoadingScreen(),
          ),
        ),
      );

      final loadingScreen = tester.widget(find.byType(LoadingScreen));
      expect(loadingScreen, isA<StatelessWidget>());
    });

    testWidgets('maintains consistent appearance across rebuilds', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(932, 430),
          builder: (context, child) => const MaterialApp(
            home: LoadingScreen(),
          ),
        ),
      );

      // Initial state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);

      // Rebuild
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(932, 430),
          builder: (context, child) => const MaterialApp(
            home: LoadingScreen(),
          ),
        ),
      );

      // Should still be the same
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('loading indicator animates', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(932, 430),
          builder: (context, child) => const MaterialApp(
            home: LoadingScreen(),
          ),
        ),
      );

      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );

      // Progress indicator should be indeterminate (value is null)
      expect(progressIndicator.value, isNull);
    });

    testWidgets('accessibility features work correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(932, 430),
          builder: (context, child) => const MaterialApp(
            home: LoadingScreen(),
          ),
        ),
      );

      // The loading text should be readable by screen readers
      expect(find.text('Loading...'), findsOneWidget);
      
      // Progress indicator should be present for accessibility tools
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('uses correct color scheme', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(932, 430),
          builder: (context, child) => const MaterialApp(
            home: LoadingScreen(),
          ),
        ),
      );

      // Check that the color scheme is consistent with app theme
      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      
      final valueColor = progressIndicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(valueColor.value, equals(Colors.blueAccent));

      final loadingText = tester.widget<Text>(find.text('Loading...'));
      expect(loadingText.style?.color, equals(Colors.white70));
    });
  });
}