A simple Flutter + Flame game template with a loading screen, main menu, and a blank game screen.

# Sci-Fi Card Game (Flutter Flame)

This project is a Flutter application using the Flame game engine. It includes:
- Loading screen
- Main menu with "Play Game" button
- Blank game screen with back button

---

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-dart) (usually included with Flutter)
- Chrome browser (for web)

---

## Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/flutter-flame-game.git
   cd flutter-flame-game
   ```
2. **Open the project in your IDE or Codespaces.**
3. **Install dependencies:**
   ```bash
   flutter pub get
   ```
4. **Run the game (Web):**
   ```bash
   flutter run -d chrome
   ```
   This will launch the game in Chrome. You can also use `-d web-server` to get a local URL for any browser.

---

## Project Structure

- `lib/main.dart` - App entry, loading, menu, and navigation
- `lib/my_game.dart` - The Flame game class (currently blank)
- `pubspec.yaml` - Dependencies
- `.devcontainer/` - Dev container config for Codespaces/VS Code

---

## Development Container (Codespaces/VS Code)

This project includes a development container configuration. To use it:

1. Open the project in Visual Studio Code.
2. Press `F1` and select `Remote-Containers: Reopen in Container` (or use Codespaces).
3. The container will set up all dependencies automatically.
4. Use the VS Code task **Run Flutter Web Server** to launch the app, or run `flutter run -d web-server` in the terminal.

---

## Notes
- You can develop and run this project in VS Code, Codespaces, or locally.
- For Codespaces or dev containers, all dependencies are pre-installed.
- Expand the game logic in `my_game.dart` as you wish!

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

A simple Flutter + Flame game template with a loading screen, main menu, and a blank game screen.

## Features
- Loading screen
- Main menu with "Play Game" button
- Blank game screen with back button

## Getting Started

### 1. Install Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-dart) (usually included with Flutter)
- Chrome browser (for web)

### 2. Install Dependencies
```
flutter pub get
```

### 3. Run the Game (Web)
```
flutter run -d chrome
```
This will launch the game in Chrome. You can also use `-d web-server` to get a local URL for any browser.

### 4. Project Structure
- `lib/main.dart` - App entry, loading, menu, and navigation
- `lib/my_game.dart` - The Flame game class (currently blank)
- `pubspec.yaml` - Dependencies

---

## Notes
- You can develop and run this project in VS Code, Codespaces, or locally.
- For Codespaces or dev containers, make sure the container has Flutter and Chrome installed.

---

Feel free to expand the game logic in `my_game.dart`!
## Development Container

This project includes a development container configuration. To use it:

1. Open the project in Visual Studio Code.
2. Press `F1` and select `Remote-Containers: Reopen in Container`.

This will set up the development environment with all necessary dependencies.

## Project Structure

- **lib/main.dart**: The entry point of the Flutter application.
- **pubspec.yaml**: Contains project metadata and dependencies.
- **.devcontainer/**: Contains configuration files for the development container.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.