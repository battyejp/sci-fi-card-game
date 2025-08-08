import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flame/game.dart';

import 'package:sci_fi_card_game/ui/screens/game_screen.dart';
import 'package:sci_fi_card_game/game/my_game.dart';

void main() {
  group('GameScreen Widget Tests', () {
    testWidgets('renders game widget and back button', (WidgetTester tester) async {
      bool backPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(onBack: () => backPressed = true),
        ),
      );

      // Check for GameWidget
      expect(find.byType(GameWidget<MyGame>), findsOneWidget);
      
      // Check for back button
      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('back button triggers callback', (WidgetTester tester) async {
      bool backPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(onBack: () => backPressed = true),
        ),
      );

      // Find and tap the back button
      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);
      
      await tester.tap(backButton);
      await tester.pump();
      
      expect(backPressed, true);
    });

    testWidgets('has correct widget hierarchy', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(onBack: () {}),
        ),
      );

      // Check main structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(Stack), findsOneWidget);
      expect(find.byType(Positioned), findsNWidgets(2)); // One for game, one for button
    });

    testWidgets('game widget fills entire screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(onBack: () {}),
        ),
      );

      // Find the Positioned widget containing the GameWidget
      final gamePositioned = find.ancestor(
        of: find.byType(GameWidget<MyGame>),
        matching: find.byType(Positioned),
      );
      
      expect(gamePositioned, findsOneWidget);
      
      final positioned = tester.widget<Positioned>(gamePositioned);
      expect(positioned.top, equals(0));
      expect(positioned.left, equals(0));
      expect(positioned.right, equals(0));
      expect(positioned.bottom, equals(0));
    });

    testWidgets('back button is positioned correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(onBack: () {}),
        ),
      );

      // Find the Positioned widget containing the back button
      final buttonPositioned = find.ancestor(
        of: find.byType(Container),
        matching: find.byType(Positioned),
      );
      
      expect(buttonPositioned, findsOneWidget);
      
      final positioned = tester.widget<Positioned>(buttonPositioned);
      expect(positioned.top, equals(16));
      expect(positioned.left, equals(16));
    });

    testWidgets('back button container has correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(onBack: () {}),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      
      expect(decoration.color, equals(Colors.black54));
      expect(decoration.borderRadius, equals(BorderRadius.circular(20)));
    });

    testWidgets('back button icon has correct properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(onBack: () {}),
        ),
      );

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      final icon = iconButton.icon as Icon;
      
      expect(icon.icon, equals(Icons.arrow_back));
      expect(icon.color, equals(Colors.white));
      expect(iconButton.iconSize, equals(24));
      expect(iconButton.padding, equals(const EdgeInsets.all(8)));
    });

    testWidgets('game widget creates MyGame instance', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(onBack: () {}),
        ),
      );

      final gameWidget = tester.widget<GameWidget<MyGame>>(find.byType(GameWidget<MyGame>));
      expect(gameWidget.game, isA<MyGame>());
    });

    testWidgets('callback parameter is required', (WidgetTester tester) async {
      // This test ensures the onBack parameter is correctly typed and required
      expect(() => GameScreen(onBack: () {}), returnsNormally);
    });

    testWidgets('handles multiple back button presses', (WidgetTester tester) async {
      int backPressCount = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(onBack: () => backPressCount++),
        ),
      );

      final backButton = find.byIcon(Icons.arrow_back);
      
      // Press multiple times
      await tester.tap(backButton);
      await tester.pump();
      await tester.tap(backButton);
      await tester.pump();
      await tester.tap(backButton);
      await tester.pump();
      
      expect(backPressCount, equals(3));
    });

    testWidgets('back button is accessible', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(onBack: () {}),
        ),
      );

      // The IconButton should be accessible by default
      final iconButton = find.byType(IconButton);
      expect(iconButton, findsOneWidget);
      
      // Should be tappable
      await tester.tap(iconButton);
      expect(tester.takeException(), isNull);
    });

    testWidgets('maintains state during rebuilds', (WidgetTester tester) async {
      bool backPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(onBack: () => backPressed = true),
        ),
      );

      // Rebuild the widget
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(onBack: () => backPressed = true),
        ),
      );

      // Elements should still be present and functional
      expect(find.byType(GameWidget<MyGame>), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      
      // Callback should still work
      await tester.tap(find.byIcon(Icons.arrow_back));
      expect(backPressed, true);
    });

    testWidgets('handles different screen sizes', (WidgetTester tester) async {
      // Test small screen
      await tester.binding.setSurfaceSize(const Size(320, 568));
      
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(onBack: () {}),
        ),
      );

      expect(find.byType(GameWidget<MyGame>), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      
      // Test large screen
      await tester.binding.setSurfaceSize(const Size(1920, 1080));
      
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(onBack: () {}),
        ),
      );

      expect(find.byType(GameWidget<MyGame>), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('stack layering is correct', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(onBack: () {}),
        ),
      );

      final stack = tester.widget<Stack>(find.byType(Stack));
      expect(stack.children.length, equals(2));
      
      // First child should be the game (Positioned.fill)
      expect(stack.children[0], isA<Positioned>());
      final gamePositioned = stack.children[0] as Positioned;
      expect(gamePositioned.child, isA<GameWidget<MyGame>>());
      
      // Second child should be the back button (Positioned with top/left)
      expect(stack.children[1], isA<Positioned>());
      final buttonPositioned = stack.children[1] as Positioned;
      expect(buttonPositioned.child, isA<Container>());
    });

    testWidgets('is a StatelessWidget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(onBack: () {}),
        ),
      );

      final gameScreen = tester.widget(find.byType(GameScreen));
      expect(gameScreen, isA<StatelessWidget>());
    });

    testWidgets('back button visual feedback works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(onBack: () {}),
        ),
      );

      final backButton = find.byIcon(Icons.arrow_back);
      
      // Test tap down and up (simulates press visual feedback)
      await tester.press(backButton);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      
      // Should complete without error
      expect(tester.takeException(), isNull);
    });

    group('Error Handling', () {
      testWidgets('handles callback that throws exception', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: GameScreen(onBack: () => throw Exception('Test exception')),
          ),
        );

        final backButton = find.byIcon(Icons.arrow_back);
        
        // This should not crash the app
        await tester.tap(backButton);
        
        // Exception should be caught by Flutter's error handling
        expect(tester.takeException(), isNotNull);
      });
    });
  });
}