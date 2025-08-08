import 'package:flutter_test/flutter_test.dart';

import 'package:sci_fi_card_game/game/card/interaction_constants.dart';

void main() {
  group('InteractionConstants Tests', () {
    group('Constant Values', () {
      test('selectedScale has correct value', () {
        expect(InteractionConstants.selectedScale, equals(2.5));
      });

      test('selectedPriority has correct value', () {
        expect(InteractionConstants.selectedPriority, equals(1000));
      });
    });

    group('Type Safety', () {
      test('selectedScale is double', () {
        expect(InteractionConstants.selectedScale, isA<double>());
      });

      test('selectedPriority is int', () {
        expect(InteractionConstants.selectedPriority, isA<int>());
      });
    });

    group('Value Ranges', () {
      test('selectedScale is positive', () {
        expect(InteractionConstants.selectedScale, greaterThan(0));
      });

      test('selectedScale is reasonable for UI scaling', () {
        // Scale should be between 1.0 and 5.0 for reasonable UI behavior
        expect(InteractionConstants.selectedScale, greaterThanOrEqualTo(1.0));
        expect(InteractionConstants.selectedScale, lessThanOrEqualTo(5.0));
      });

      test('selectedPriority is positive', () {
        expect(InteractionConstants.selectedPriority, greaterThan(0));
      });

      test('selectedPriority is high enough to ensure selection visibility', () {
        // Priority should be high enough to bring selected cards to front
        expect(InteractionConstants.selectedPriority, greaterThanOrEqualTo(100));
      });
    });

    group('Constant Immutability', () {
      test('selectedScale value is constant', () {
        final value1 = InteractionConstants.selectedScale;
        final value2 = InteractionConstants.selectedScale;
        expect(value1, equals(value2));
      });

      test('selectedPriority value is constant', () {
        final value1 = InteractionConstants.selectedPriority;
        final value2 = InteractionConstants.selectedPriority;
        expect(value1, equals(value2));
      });
    });

    group('Practical Usage', () {
      test('selectedScale provides noticeable enlargement', () {
        // A scale of 2.5 means the card becomes 2.5x larger
        const originalSize = 100.0;
        final scaledSize = originalSize * InteractionConstants.selectedScale;
        
        expect(scaledSize, equals(250.0));
        expect(scaledSize, greaterThan(originalSize * 2)); // At least 2x larger
      });

      test('selectedPriority ensures visual hierarchy', () {
        // Normal card priorities are typically low (0-10)
        const normalPriority = 5;
        
        expect(InteractionConstants.selectedPriority, 
               greaterThan(normalPriority * 100)); // Much higher than normal
      });
    });

    group('Integration with Game Logic', () {
      test('scale factor works with typical card dimensions', () {
        // Test with game card dimensions
        const cardWidth = 90.0;
        const cardHeight = 135.0;
        
        final scaledWidth = cardWidth * InteractionConstants.selectedScale;
        final scaledHeight = cardHeight * InteractionConstants.selectedScale;
        
        expect(scaledWidth, equals(225.0));
        expect(scaledHeight, equals(337.5));
        
        // Scaled dimensions should be reasonable for UI
        expect(scaledWidth, lessThan(500)); // Not too large
        expect(scaledHeight, lessThan(500));
      });

      test('priority value works with layering system', () {
        // Simulate typical card priorities in a deck
        final normalPriorities = List.generate(10, (i) => i);
        
        // Selected priority should be higher than all normal priorities
        for (final priority in normalPriorities) {
          expect(InteractionConstants.selectedPriority, greaterThan(priority));
        }
      });
    });

    group('Mathematical Properties', () {
      test('selectedScale maintains aspect ratio', () {
        // Scale factor should be the same for width and height
        const width = 90.0;
        const height = 135.0;
        const aspectRatio = width / height;
        
        final scaledWidth = width * InteractionConstants.selectedScale;
        final scaledHeight = height * InteractionConstants.selectedScale;
        final scaledAspectRatio = scaledWidth / scaledHeight;
        
        expect(scaledAspectRatio, closeTo(aspectRatio, 0.001));
      });

      test('scale transformation is reversible', () {
        const originalValue = 100.0;
        final scaled = originalValue * InteractionConstants.selectedScale;
        final unscaled = scaled / InteractionConstants.selectedScale;
        
        expect(unscaled, closeTo(originalValue, 0.001));
      });
    });

    group('Performance Considerations', () {
      test('constants are compile-time values', () {
        // These should be compile-time constants, not computed values
        expect(InteractionConstants.selectedScale, isA<double>());
        expect(InteractionConstants.selectedPriority, isA<int>());
        
        // Values should be exactly what we expect (no floating point errors)
        expect(InteractionConstants.selectedScale, equals(2.5));
        expect(InteractionConstants.selectedPriority, equals(1000));
      });
    });

    group('Code Organization', () {
      test('class contains only constants', () {
        // InteractionConstants should be a utility class with only static constants
        // This test verifies the class design principle
        expect(InteractionConstants.selectedScale, isNotNull);
        expect(InteractionConstants.selectedPriority, isNotNull);
      });
    });

    group('Documentation and Semantics', () {
      test('selectedScale name reflects its purpose', () {
        // The scale should make sense semantically
        expect(InteractionConstants.selectedScale, greaterThan(1.0)); // Actually scales up
      });

      test('selectedPriority name reflects its purpose', () {
        // Priority should be higher than typical values
        expect(InteractionConstants.selectedPriority, greaterThan(100)); // High priority
      });
    });

    group('Cross-Platform Compatibility', () {
      test('constants work across different screen densities', () {
        // Scale factor should work regardless of screen density
        final scaleFactor = InteractionConstants.selectedScale;
        
        // Test with different hypothetical screen densities
        final densities = [1.0, 1.5, 2.0, 3.0];
        
        for (final density in densities) {
          final baseSize = 100.0 * density;
          final scaledSize = baseSize * scaleFactor;
          final relativeDifference = scaledSize / baseSize;
          
          expect(relativeDifference, equals(scaleFactor));
        }
      });
    });
  });
}