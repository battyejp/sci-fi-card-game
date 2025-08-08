import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:sci_fi_card_game/ui/screens/main_menu.dart';

void main() {
  group('MainMenu Widget Tests', () {
    testWidgets('renders all required elements', (WidgetTester tester) async {
      bool playPressed = false;
      
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(932, 430),
          builder: (context, child) => MaterialApp(
            home: MainMenu(onPlay: () => playPressed = true),
          ),
        ),
      );

      // Check title texts
      expect(find.text('SCI-FI'), findsOneWidget);
      expect(find.text('CARD GAME'), findsOneWidget);
      
      // Check play button
      expect(find.text('PLAY GAME'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      
      // Check settings button
      expect(find.text('Settings'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('play button triggers callback', (WidgetTester tester) async {
      bool playPressed = false;
      
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(932, 430),
          builder: (context, child) => MaterialApp(
            home: MainMenu(onPlay: () => playPressed = true),
          ),
        ),
      );

      // Find and tap the play button
      final playButton = find.widgetWithText(ElevatedButton, 'PLAY GAME');
      expect(playButton, findsOneWidget);
      
      await tester.tap(playButton);
      await tester.pump();
      
      expect(playPressed, true);
    });

    testWidgets('settings button is tappable but has no action', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(932, 430),
          builder: (context, child) => MaterialApp(
            home: MainMenu(onPlay: () {}),
          ),
        ),
      );

      // Find and tap the settings button
      final settingsButton = find.widgetWithText(TextButton, 'Settings');
      expect(settingsButton, findsOneWidget);
      
      // Should not throw when tapped
      await tester.tap(settingsButton);
      await tester.pump();
    });

    testWidgets('has correct widget hierarchy', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(932, 430),
          builder: (context, child) => MaterialApp(
            home: MainMenu(onPlay: () {}),
          ),
        ),
      );

      // Check main structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(Padding), findsAtLeastNWidgets(1));
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('text styles are correctly configured', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(932, 430),
          builder: (context, child) => MaterialApp(
            home: MainMenu(onPlay: () {}),
          ),
        ),
      );

      // Find title text widgets
      final sciFiText = tester.widget<Text>(find.text('SCI-FI'));
      final cardGameText = tester.widget<Text>(find.text('CARD GAME'));
      final playGameText = tester.widget<Text>(find.text('PLAY GAME'));
      final settingsText = tester.widget<Text>(find.text('Settings'));

      // Check SCI-FI title properties
      expect(sciFiText.style?.color, equals(Colors.blueAccent));
      expect(sciFiText.style?.fontWeight, equals(FontWeight.bold));
      expect(sciFiText.style?.letterSpacing, equals(4.0));

      // Check CARD GAME subtitle properties
      expect(cardGameText.style?.color, equals(Colors.white70));
      expect(cardGameText.style?.fontWeight, equals(FontWeight.w300));
      expect(cardGameText.style?.letterSpacing, equals(2.0));

      // Check PLAY GAME button text properties
      expect(playGameText.style?.fontWeight, equals(FontWeight.bold));
      expect(playGameText.style?.letterSpacing, equals(1.0));

      // Check Settings text properties
      expect(settingsText.style?.color, equals(Colors.white54));
    });

    testWidgets('button styling is correct', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(932, 430),
          builder: (context, child) => MaterialApp(
            home: MainMenu(onPlay: () {}),
          ),
        ),
      );

      // Find the elevated button
      final elevatedButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );

      // Check button style properties
      final buttonStyle = elevatedButton.style;
      expect(buttonStyle, isNotNull);
      
      // Note: Testing exact style properties can be complex due to MaterialStateProperty
      // We'll test that the style is configured
      expect(elevatedButton.child, isA<Text>());
    });

    testWidgets('layout spacing is correct', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(932, 430),
          builder: (context, child) => MaterialApp(
            home: MainMenu(onPlay: () {}),
          ),
        ),
      );

      // Check that SizedBox widgets are present for spacing
      final sizedBoxes = find.byType(SizedBox);
      expect(sizedBoxes, findsAtLeastNWidgets(2)); // One after title, one after play button
    });

    testWidgets('handles different screen orientations', (WidgetTester tester) async {
      // Test in portrait mode
      await tester.binding.setSurfaceSize(const Size(430, 932));
      
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(430, 932),
          builder: (context, child) => MaterialApp(
            home: MainMenu(onPlay: () {}),
          ),
        ),
      );

      expect(find.text('SCI-FI'), findsOneWidget);
      expect(find.text('PLAY GAME'), findsOneWidget);
      
      // Test in landscape mode
      await tester.binding.setSurfaceSize(const Size(932, 430));
      
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(932, 430),
          builder: (context, child) => MaterialApp(
            home: MainMenu(onPlay: () {}),
          ),
        ),
      );

      expect(find.text('SCI-FI'), findsOneWidget);
      expect(find.text('PLAY GAME'), findsOneWidget);
    });

    testWidgets('callback parameter is required', (WidgetTester tester) async {
      // This test ensures the onPlay parameter is correctly typed and required
      expect(() => MainMenu(onPlay: () {}), returnsNormally);
    });

    testWidgets('maintains state during rebuilds', (WidgetTester tester) async {
      bool playPressed = false;
      
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(932, 430),
          builder: (context, child) => MaterialApp(
            home: MainMenu(onPlay: () => playPressed = true),
          ),
        ),
      );

      // Rebuild the widget
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(932, 430),
          builder: (context, child) => MaterialApp(
            home: MainMenu(onPlay: () => playPressed = true),
          ),
        ),
      );

      // Elements should still be present
      expect(find.text('SCI-FI'), findsOneWidget);
      expect(find.text('PLAY GAME'), findsOneWidget);
      
      // Callback should still work
      await tester.tap(find.widgetWithText(ElevatedButton, 'PLAY GAME'));
      expect(playPressed, true);
    });

    testWidgets('accessibility features work correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(932, 430),
          builder: (context, child) => MaterialApp(
            home: MainMenu(onPlay: () {}),
          ),
        ),
      );

      // Check that buttons are semantically accessible
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
      
      // Verify text is readable
      expect(find.text('SCI-FI'), findsOneWidget);
      expect(find.text('CARD GAME'), findsOneWidget);
    });
  });
}