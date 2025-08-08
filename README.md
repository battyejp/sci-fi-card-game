## Sci‑Fi Card Game (Flutter + Flame)

Interactive card hand fan built with Flame, showcasing SOLID refactors: controllers, strategies, managers, and testable factories.

### Key Features
* Loading screen → Main menu → Game screen navigation
* Dynamic fanned hand layout (radius + rotation + overlap adaptation)
* Tap selection animation (scale + bring to front)
* Clean separation: Card vs Interaction vs Deck Controller vs Layout Strategy

---
### Tech Stack
Flutter, Flame, Dart. Tested with `flutter_test` (logic-level unit tests).

---
### Current Architecture Overview
```
lib/
   main.dart                # App bootstrap
   app.dart                 # MaterialApp + root wiring
   game/
      core/
         game_root.dart       # Loading/menu/game host widget
         my_game.dart         # FlameGame implementation
      data/
         game_constants.dart  # Tunable game + layout numbers
      card/
         card.dart            # GameCard (visual + layout state)
         card_interaction_controller.dart
         interaction_constants.dart
      deck/
         card_deck.dart       # Thin component delegating to controller
         card_deck_controller.dart  # Builds & manages hand
         layout/
            layout_strategy.dart       # Strategy interface
            fan_layout_calculator.dart # Concrete layout math
            card_selection_manager.dart
            card_collection_manager.dart
   ui/ ... (screens + theme)
test/
   game/deck/layout/        # Layout & manager tests
   game/deck/               # Deck controller tests
   game/card/               # Card serialization test
```

### Responsibility Split
| Layer | Responsibility |
|-------|----------------|
| GameCard | Sprite + base position/rotation + serialization |
| CardInteractionController | Tap/selection animations only |
| CardDeckController | Create/reset deck, compute layout via strategy, manage selection/collection |
| CardLayoutStrategy | Pure math for position/rotation/priority/radius/center |
| Managers | Selection state & card list lifecycle |

---
### Running
Web (Chrome):
```bash
flutter run -d chrome
```
Generic web server:
```bash
flutter run -d web-server --web-port=8080
```
All tests:
```bash
flutter test
```

### Adding / Adjusting Layout Algorithms
1. Create a new class implementing `CardLayoutStrategy` in `deck/layout/`.
2. Inject it via `CardDeckController(layoutStrategy: YourStrategy())`.
3. Write focused tests exercising its math (see `fan_layout_calculator_test.dart`).

### Tuning Layout / Interaction
Edit numeric values in `game_constants.dart` and `interaction_constants.dart` (scale, priority, rotation, overlap, radius, padding).

---
### Testing Overview
Current unit coverage targets logic (not Flame rendering):
* `fan_layout_calculator_test.dart` – geometric fan math
* `card_selection_manager_test.dart` – single-selection rules
* `card_collection_manager_test.dart` – add/remove/index behaviour
* `card_deck_controller_test.dart` – deck build with mock strategy
* `game_card_interaction_test.dart` – basic GameCard serialization

Potential next tests (not yet implemented):
* Interaction animation lifecycle (using Flame tester utilities)
* Radius shrink behaviour with extreme card counts
* Priority restoration after deselect
* Strategy swap mid‑game (dynamic injection scenario)

---
### Contributing
1. Branch from `main`
2. Keep logic inside controllers/strategies; avoid leaking Flame specifics into pure math code
3. Add/update tests for new behaviours

---
### License
MIT – see [LICENSE](LICENSE)

---
### Quick Reference (Key Constants)
| Constant | Purpose |
|----------|---------|
| `handCardWidth/Height` | Card sprite size in hand |
| `maxFanRotation` | Max degree tilt outer cards |
| `fanRadius` | Arc radius before adaptive shrink |
| `cardOverlap` | Horizontal overlap tuning |
| `fanCenterOffset` | Vertical lift of fan center |
| `safeAreaPadding` | Left/right shrink for safe area |
| `selectedScale` | Enlargement on selection |
| `selectedPriority` | z-order when selected |

---
### Future Ideas
* Drag & drop to play zone
* Card metadata / decks / shuffling
* Animated dealing sequence
* Multi-touch selection queue
* Alternate layout strategies (grid, cascade)

---
Happy hacking – adjust a constant and re-run tests to iterate quickly.