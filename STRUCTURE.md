# Sci-Fi Card Game - Project Structure

This document outlines the reorganized folder structure for better maintainability and scalability.

## Folder Structure

```
lib/
├── main.dart                    # Entry point and app initialization
├── game/                        # Game-specific code
│   ├── my_game.dart            # Main Flame game class
│   ├── components/             # Game components
│   │   ├── card.dart           # Individual card component with animations
│   │   └── card_deck.dart      # Card deck management
│   ├── systems/                # Game logic systems
│   │   ├── game_state.dart     # Game state management
│   │   └── card_manager.dart   # Card logic and management
│   └── data/                   # Game data and constants
│       └── game_constants.dart # Constants (dimensions, colors, etc.)
├── ui/                         # User interface components
│   ├── screens/                # App screens
│   │   ├── loading_screen.dart # Loading screen
│   │   ├── main_menu.dart      # Main menu screen
│   │   └── game_screen.dart    # Game screen wrapper
│   ├── widgets/                # Reusable UI widgets
│   └── theme/                  # App theming
│       └── app_theme.dart      # Centralized theme configuration
├── models/                     # Data models
│   └── card_model.dart         # Card data structure
└── utils/                      # Utility functions and extensions
    ├── extensions.dart         # Dart extensions
    └── helpers.dart           # Helper functions
```

## Key Benefits

### 1. **Separation of Concerns**
- Game logic separated from UI code
- Clear boundaries between different system responsibilities
- Easier to locate and modify specific functionality

### 2. **Scalability**
- Easy to add new game features without cluttering existing code
- New developers can quickly understand the codebase structure
- Support for complex features like multiplayer, AI, or deck building

### 3. **Maintainability**
- Related code grouped together logically
- Constants centralized for easy configuration
- Consistent naming conventions throughout

### 4. **Testing**
- Isolated components are easier to unit test
- Game logic can be tested independently of UI
- Mock dependencies can be easily created

## Architecture Overview

### Game Layer (`game/`)
- **Components**: Individual game entities (cards, deck, board)
- **Systems**: Game logic managers (state, cards, players)
- **Data**: Constants and configuration

### UI Layer (`ui/`)
- **Screens**: Full-screen views (menu, game, settings)
- **Widgets**: Reusable UI components
- **Theme**: Centralized styling and theming

### Models (`models/`)
- Data structures representing game entities
- Business logic validation
- Serialization for save/load functionality

### Utils (`utils/`)
- Helper functions used across the app
- Dart language extensions
- Utility classes for common operations

## Future Expansion Ideas

With this structure, you can easily add:

- **Additional Game Features**:
  - Different card types and abilities
  - Game board/battlefield
  - Player vs AI or multiplayer
  - Deck building system
  - Campaign mode

- **UI Enhancements**:
  - Settings screen
  - Inventory/collection screen
  - Leaderboards
  - Animations and effects

- **Systems**:
  - Save/load game state
  - Achievement system
  - Sound and music management
  - Network multiplayer

## Usage

The restructured code maintains all existing functionality while providing a much cleaner foundation for future development. All animations, card interactions, and game flow remain exactly the same from the user perspective.
