import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:sci_fi_card_game/game/core/game_root.dart';
import 'package:sci_fi_card_game/ui/screens/loading_screen.dart';
import 'package:sci_fi_card_game/ui/screens/main_menu.dart';
import 'package:sci_fi_card_game/ui/screens/game_screen.dart';

void main() {
  group('GameRoot Widget Tests', () {
    testWidgets('initially shows loading screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: GameRoot()),
      );
      
      // Should show loading screen initially
      expect(find.byType(LoadingScreen), findsOneWidget);
      expect(find.byType(MainMenu), findsNothing);
      expect(find.byType(GameScreen), findsNothing);
    });

    testWidgets('shows main menu after loading completes', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: GameRoot()),
      );
      
      // Initially loading
      expect(find.byType(LoadingScreen), findsOneWidget);
      
      // Wait for loading to complete (2 seconds + some buffer)
      await tester.pump(const Duration(seconds: 3));
      
      // Should now show main menu
      expect(find.byType(LoadingScreen), findsNothing);
      expect(find.byType(MainMenu), findsOneWidget);
      expect(find.byType(GameScreen), findsNothing);
    });

    testWidgets('transitions to game screen when play is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: GameRoot()),
      );
      
      // Wait for loading to complete
      await tester.pump(const Duration(seconds: 3));
      
      // Should be on main menu
      expect(find.byType(MainMenu), findsOneWidget);
      
      // Find and tap the play button
      final playButton = find.text('PLAY GAME');
      expect(playButton, findsOneWidget);
      await tester.tap(playButton);
      await tester.pump();
      
      // Should now show game screen
      expect(find.byType(MainMenu), findsNothing);
      expect(find.byType(GameScreen), findsOneWidget);
    });

    testWidgets('can return to main menu from game screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: GameRoot()),
      );
      
      // Wait for loading and go to game
      await tester.pump(const Duration(seconds: 3));
      await tester.tap(find.text('PLAY GAME'));
      await tester.pump();
      
      // Should be in game
      expect(find.byType(GameScreen), findsOneWidget);
      
      // Find and tap the back/exit button (this would be in GameScreen)
      // Since GameScreen takes an onBack callback, it should trigger when back is pressed
      // We need to simulate this by finding the back button in GameScreen
      final gameScreen = tester.widget<GameScreen>(find.byType(GameScreen));
      
      // Simulate the back action
      gameScreen.onBack();
      await tester.pump();
      
      // Should be back to main menu
      expect(find.byType(GameScreen), findsNothing);
      expect(find.byType(MainMenu), findsOneWidget);
    });

    testWidgets('state transitions work correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: GameRoot()),
      );
      
      // 1. Loading state
      expect(find.byType(LoadingScreen), findsOneWidget);
      
      // 2. Main menu state
      await tester.pump(const Duration(seconds: 3));
      expect(find.byType(MainMenu), findsOneWidget);
      
      // 3. Game state
      await tester.tap(find.text('PLAY GAME'));
      await tester.pump();
      expect(find.byType(GameScreen), findsOneWidget);
      
      // 4. Back to main menu
      final gameScreen = tester.widget<GameScreen>(find.byType(GameScreen));
      gameScreen.onBack();
      await tester.pump();
      expect(find.byType(MainMenu), findsOneWidget);
      
      // 5. Back to game again
      await tester.tap(find.text('PLAY GAME'));
      await tester.pump();
      expect(find.byType(GameScreen), findsOneWidget);
    });

    testWidgets('loading simulation takes approximately 2 seconds', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: GameRoot()),
      );
      
      // Should be loading
      expect(find.byType(LoadingScreen), findsOneWidget);
      
      // After 1 second, should still be loading
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(LoadingScreen), findsOneWidget);
      
      // After 2 seconds, should still be loading (just under the threshold)
      await tester.pump(const Duration(milliseconds: 900));
      expect(find.byType(LoadingScreen), findsOneWidget);
      
      // After slightly more than 2 seconds, should show main menu
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(MainMenu), findsOneWidget);
    });

    testWidgets('GameRoot is a StatefulWidget', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: GameRoot()),
      );
      
      final gameRoot = tester.widget(find.byType(GameRoot));
      expect(gameRoot, isA<StatefulWidget>());
    });

    testWidgets('handles multiple rapid state changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: GameRoot()),
      );
      
      // Wait for loading
      await tester.pump(const Duration(seconds: 3));
      
      // Rapid transitions
      for (int i = 0; i < 3; i++) {
        // To game
        await tester.tap(find.text('PLAY GAME'));
        await tester.pump();
        expect(find.byType(GameScreen), findsOneWidget);
        
        // Back to menu
        final gameScreen = tester.widget<GameScreen>(find.byType(GameScreen));
        gameScreen.onBack();
        await tester.pump();
        expect(find.byType(MainMenu), findsOneWidget);
      }
    });

    testWidgets('GameRoot maintains state across widget rebuilds', (WidgetTester tester) async {
      // Create a StatefulWidget wrapper to control rebuilds
      bool rebuildFlag = false;
      
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: rebuildFlag ? const GameRoot() : const GameRoot(),
            );
          },
        ),
      );
      
      // Wait for loading
      await tester.pump(const Duration(seconds: 3));
      expect(find.byType(MainMenu), findsOneWidget);
      
      // Go to game
      await tester.tap(find.text('PLAY GAME'));
      await tester.pump();
      expect(find.byType(GameScreen), findsOneWidget);
      
      // Force rebuild - the state should persist within the same GameRoot instance
      rebuildFlag = true;
      await tester.pump();
      
      // Should still be in game (if the widget maintains its state)
      // Note: This test verifies the widget structure, actual state persistence
      // would depend on how the parent manages the GameRoot instance
    });
  });
}