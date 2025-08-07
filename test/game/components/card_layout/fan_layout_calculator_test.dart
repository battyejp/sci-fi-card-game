import 'package:flutter_test/flutter_test.dart';
import 'package:sci_fi_card_game/game/components/card_layout/fan_layout_calculator.dart';
import 'package:sci_fi_card_game/game/data/game_constants.dart';

void main() {
  group('FanLayoutCalculator', () {
    late FanLayoutCalculator calculator;

    setUp(() {
      calculator = FanLayoutCalculator();
    });

    group('calculateCardPosition', () {
      test('should return center position for single card', () {
        final result = calculator.calculateCardPosition(
          cardIndex: 0,
          totalCards: 1,
          centerX: 400,
          centerY: 300,
          radius: 200,
        );

        expect(result.x, equals(400));
        expect(result.y, equals(300));
      });

      test('should calculate different positions for multiple cards', () {
        final position1 = calculator.calculateCardPosition(
          cardIndex: 0,
          totalCards: 3,
          centerX: 400,
          centerY: 300,
          radius: 200,
        );

        final position2 = calculator.calculateCardPosition(
          cardIndex: 1,
          totalCards: 3,
          centerX: 400,
          centerY: 300,
          radius: 200,
        );

        final position3 = calculator.calculateCardPosition(
          cardIndex: 2,
          totalCards: 3,
          centerX: 400,
          centerY: 300,
          radius: 200,
        );

        // Positions should be different
        expect(position1.x, isNot(equals(position2.x)));
        expect(position2.x, isNot(equals(position3.x)));
        
        // Center card (index 1) should be closest to center X
        expect((position2.x - 400).abs(), lessThan((position1.x - 400).abs()));
        expect((position2.x - 400).abs(), lessThan((position3.x - 400).abs()));
      });

      test('should be symmetric around center', () {
        final leftCard = calculator.calculateCardPosition(
          cardIndex: 0,
          totalCards: 5,
          centerX: 400,
          centerY: 300,
          radius: 200,
        );

        final rightCard = calculator.calculateCardPosition(
          cardIndex: 4,
          totalCards: 5,
          centerX: 400,
          centerY: 300,
          radius: 200,
        );

        // Should be symmetric around center
        expect((leftCard.x - 400).abs(), closeTo((rightCard.x - 400).abs(), 0.1));
        expect(leftCard.y, closeTo(rightCard.y, 0.1));
      });
    });

    group('calculateCardRotation', () {
      test('should return zero rotation for single card', () {
        final rotation = calculator.calculateCardRotation(
          cardIndex: 0,
          totalCards: 1,
        );

        expect(rotation, equals(0.0));
      });

      test('should return zero rotation for center card', () {
        final rotation = calculator.calculateCardRotation(
          cardIndex: 2,
          totalCards: 5,
        );

        expect(rotation, closeTo(0.0, 0.01));
      });

      test('should return opposite rotations for symmetric cards', () {
        final leftRotation = calculator.calculateCardRotation(
          cardIndex: 0,
          totalCards: 5,
        );

        final rightRotation = calculator.calculateCardRotation(
          cardIndex: 4,
          totalCards: 5,
        );

        expect(leftRotation, closeTo(-rightRotation, 0.01));
      });

      test('should be within expected range', () {
        for (int i = 0; i < 7; i++) {
          final rotation = calculator.calculateCardRotation(
            cardIndex: i,
            totalCards: 7,
          );

          final maxRotationRadians = GameConstants.degreesToRadians(GameConstants.maxFanRotation);
          expect(rotation.abs(), lessThanOrEqualTo(maxRotationRadians));
        }
      });
    });

    group('calculateCardPriority', () {
      test('should give highest priority to center card', () {
        final priorities = <int>[];
        for (int i = 0; i < 5; i++) {
          priorities.add(calculator.calculateCardPriority(
            cardIndex: i,
            totalCards: 5,
          ));
        }

        final maxPriority = priorities.reduce((a, b) => a > b ? a : b);
        const centerIndex = 2;
        expect(priorities[centerIndex], equals(maxPriority));
      });

      test('should give symmetric priorities', () {
        final leftPriority = calculator.calculateCardPriority(
          cardIndex: 0,
          totalCards: 7,
        );

        final rightPriority = calculator.calculateCardPriority(
          cardIndex: 6,
          totalCards: 7,
        );

        expect(leftPriority, equals(rightPriority));
      });

      test('should decrease priority away from center', () {
        final priorities = <int>[];
        for (int i = 0; i < 5; i++) {
          priorities.add(calculator.calculateCardPriority(
            cardIndex: i,
            totalCards: 5,
          ));
        }

        // Center should have highest priority
        expect(priorities[2], greaterThan(priorities[1]));
        expect(priorities[2], greaterThan(priorities[3]));
        expect(priorities[1], greaterThan(priorities[0]));
        expect(priorities[3], greaterThan(priorities[4]));
      });
    });

    group('calculateAdjustedRadius', () {
      test('should return base radius when cards fit', () {
        final result = calculator.calculateAdjustedRadius(
          cardCount: 3,
          gameWidth: 1000,
          safeAreaPadding: 40,
          cardWidth: 90,
          baseRadius: 400,
        );

        expect(result, equals(400));
      });

      test('should reduce radius when cards exceed screen width', () {
        final result = calculator.calculateAdjustedRadius(
          cardCount: 20, // Many cards
          gameWidth: 500, // Narrow screen
          safeAreaPadding: 40,
          cardWidth: 90,
          baseRadius: 400,
        );

        expect(result, lessThan(400));
      });

      test('should never return negative radius', () {
        final result = calculator.calculateAdjustedRadius(
          cardCount: 100,
          gameWidth: 100,
          safeAreaPadding: 40,
          cardWidth: 90,
          baseRadius: 400,
        );

        expect(result, greaterThan(0));
      });
    });

    group('calculateFanCenter', () {
      test('should calculate center position correctly', () {
        final result = calculator.calculateFanCenter(
          gameWidth: 800,
          gameHeight: 600,
          bottomMargin: 50,
          fanCenterOffset: 100,
        );

        expect(result.x, equals(400)); // Half of width
        expect(result.y, equals(450)); // 600 - 50 - 100
      });

      test('should handle zero margins', () {
        final result = calculator.calculateFanCenter(
          gameWidth: 1000,
          gameHeight: 800,
          bottomMargin: 0,
          fanCenterOffset: 0,
        );

        expect(result.x, equals(500));
        expect(result.y, equals(800));
      });
    });
  });
}
