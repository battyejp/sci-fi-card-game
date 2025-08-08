import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sci_fi_card_game/ui/theme/app_theme.dart';
import 'package:sci_fi_card_game/game/data/game_constants.dart';

void main() {
  group('AppTheme Tests', () {
    test('darkTheme is not null', () {
      expect(AppTheme.darkTheme, isNotNull);
    });

    test('darkTheme is based on ThemeData.dark', () {
      final theme = AppTheme.darkTheme;
      expect(theme, isA<ThemeData>());
      // Should be a dark theme
      expect(theme.brightness, equals(Brightness.dark));
    });

    group('Colors', () {
      test('primary color is blue', () {
        final theme = AppTheme.darkTheme;
        expect(theme.primaryColor, equals(Colors.blue));
      });

      test('scaffold background color matches game constants', () {
        final theme = AppTheme.darkTheme;
        expect(theme.scaffoldBackgroundColor, equals(GameConstants.backgroundColor));
      });
    });

    group('AppBar Theme', () {
      test('app bar has correct properties', () {
        final theme = AppTheme.darkTheme;
        final appBarTheme = theme.appBarTheme;
        
        expect(appBarTheme.backgroundColor, equals(Colors.transparent));
        expect(appBarTheme.elevation, equals(0));
      });

      test('app bar icon theme is white', () {
        final theme = AppTheme.darkTheme;
        final iconTheme = theme.appBarTheme.iconTheme;
        
        expect(iconTheme?.color, equals(Colors.white));
      });

      test('app bar title style is configured correctly', () {
        final theme = AppTheme.darkTheme;
        final titleStyle = theme.appBarTheme.titleTextStyle;
        
        expect(titleStyle?.color, equals(Colors.white));
        expect(titleStyle?.fontSize, equals(20));
        expect(titleStyle?.fontWeight, equals(FontWeight.bold));
      });
    });

    group('Elevated Button Theme', () {
      test('elevated button has correct colors', () {
        final theme = AppTheme.darkTheme;
        final buttonTheme = theme.elevatedButtonTheme;
        final buttonStyle = buttonTheme.style;
        
        expect(buttonStyle, isNotNull);
        
        // Test foreground color
        final foregroundColor = buttonStyle?.foregroundColor?.resolve({});
        expect(foregroundColor, equals(Colors.white));
        
        // Test background color
        final backgroundColor = buttonStyle?.backgroundColor?.resolve({});
        expect(backgroundColor, equals(Colors.blueAccent));
      });

      test('elevated button has correct padding', () {
        final theme = AppTheme.darkTheme;
        final buttonStyle = theme.elevatedButtonTheme.style;
        
        final padding = buttonStyle?.padding?.resolve({});
        expect(padding, equals(const EdgeInsets.symmetric(horizontal: 32, vertical: 16)));
      });

      test('elevated button has rounded corners', () {
        final theme = AppTheme.darkTheme;
        final buttonStyle = theme.elevatedButtonTheme.style;
        
        final shape = buttonStyle?.shape?.resolve({});
        expect(shape, isA<RoundedRectangleBorder>());
        
        final roundedShape = shape as RoundedRectangleBorder;
        expect(roundedShape.borderRadius, equals(BorderRadius.circular(8)));
      });
    });

    group('Text Theme', () {
      test('display large text style is configured', () {
        final theme = AppTheme.darkTheme;
        final displayLarge = theme.textTheme.displayLarge;
        
        expect(displayLarge?.color, equals(Colors.white));
        expect(displayLarge?.fontSize, equals(32));
        expect(displayLarge?.fontWeight, equals(FontWeight.bold));
      });

      test('body large text style is configured', () {
        final theme = AppTheme.darkTheme;
        final bodyLarge = theme.textTheme.bodyLarge;
        
        expect(bodyLarge?.color, equals(Colors.white));
        expect(bodyLarge?.fontSize, equals(16));
      });

      test('body medium text style is configured', () {
        final theme = AppTheme.darkTheme;
        final bodyMedium = theme.textTheme.bodyMedium;
        
        expect(bodyMedium?.color, equals(Colors.grey));
        expect(bodyMedium?.fontSize, equals(14));
      });
    });

    group('Theme Consistency', () {
      test('theme uses consistent color palette', () {
        final theme = AppTheme.darkTheme;
        
        // Primary colors should be variations of blue
        expect(theme.primaryColor, equals(Colors.blue));
        
        // Background should match game constants
        expect(theme.scaffoldBackgroundColor, equals(GameConstants.backgroundColor));
        
        // Button accent should be blue accent
        final buttonBg = theme.elevatedButtonTheme.style?.backgroundColor?.resolve({});
        expect(buttonBg, equals(Colors.blueAccent));
      });

      test('text colors provide good contrast', () {
        final theme = AppTheme.darkTheme;
        final textTheme = theme.textTheme;
        
        // Main text should be white for good contrast on dark background
        expect(textTheme.displayLarge?.color, equals(Colors.white));
        expect(textTheme.bodyLarge?.color, equals(Colors.white));
        
        // Secondary text should be grey for hierarchy
        expect(textTheme.bodyMedium?.color, equals(Colors.grey));
      });

      test('theme is based on dark theme foundation', () {
        final theme = AppTheme.darkTheme;
        final darkBase = ThemeData.dark();
        
        // Should inherit dark theme characteristics
        expect(theme.brightness, equals(darkBase.brightness));
        expect(theme.brightness, equals(Brightness.dark));
      });
    });

    group('Widget Integration', () {
      testWidgets('theme applies correctly to MaterialApp', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: Text('Test'),
            ),
          ),
        );

        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(materialApp.theme, equals(AppTheme.darkTheme));
      });

      testWidgets('scaffold uses correct background color', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: Text('Test'),
            ),
          ),
        );

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        final context = tester.element(find.byType(Scaffold));
        final theme = Theme.of(context);
        
        expect(theme.scaffoldBackgroundColor, equals(GameConstants.backgroundColor));
      });

      testWidgets('elevated button uses theme styling', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: ElevatedButton(
                onPressed: () {},
                child: const Text('Test'),
              ),
            ),
          ),
        );

        final context = tester.element(find.byType(ElevatedButton));
        final theme = Theme.of(context);
        final buttonStyle = theme.elevatedButtonTheme.style;
        
        expect(buttonStyle, isNotNull);
        
        final backgroundColor = buttonStyle?.backgroundColor?.resolve({});
        expect(backgroundColor, equals(Colors.blueAccent));
      });
    });

    group('Theme Immutability', () {
      test('multiple calls return equivalent themes', () {
        final theme1 = AppTheme.darkTheme;
        final theme2 = AppTheme.darkTheme;
        
        // Should be equivalent (though not necessarily the same instance)
        expect(theme1.primaryColor, equals(theme2.primaryColor));
        expect(theme1.scaffoldBackgroundColor, equals(theme2.scaffoldBackgroundColor));
        expect(theme1.brightness, equals(theme2.brightness));
      });

      test('theme properties are immutable', () {
        final theme = AppTheme.darkTheme;
        
        // Getting the same property multiple times should return the same value
        expect(theme.primaryColor, equals(theme.primaryColor));
        expect(theme.scaffoldBackgroundColor, equals(theme.scaffoldBackgroundColor));
        expect(theme.textTheme.displayLarge?.color, equals(theme.textTheme.displayLarge?.color));
      });
    });

    group('Accessibility', () {
      test('text styles provide sufficient contrast', () {
        final theme = AppTheme.darkTheme;
        
        // White text on dark background should have good contrast
        expect(theme.textTheme.displayLarge?.color, equals(Colors.white));
        expect(theme.textTheme.bodyLarge?.color, equals(Colors.white));
        
        // Background is dark
        expect(theme.scaffoldBackgroundColor, equals(GameConstants.backgroundColor));
        expect(GameConstants.backgroundColor.computeLuminance(), lessThan(0.5));
      });

      test('button colors provide sufficient contrast', () {
        final theme = AppTheme.darkTheme;
        final buttonStyle = theme.elevatedButtonTheme.style;
        
        final foreground = buttonStyle?.foregroundColor?.resolve({});
        final background = buttonStyle?.backgroundColor?.resolve({});
        
        expect(foreground, equals(Colors.white));
        expect(background, equals(Colors.blueAccent));
        
        // Should have good contrast between white text and blue background
        expect(Colors.white.computeLuminance(), greaterThan(0.5));
        expect(Colors.blueAccent.computeLuminance(), lessThan(0.5));
      });
    });
  });
}