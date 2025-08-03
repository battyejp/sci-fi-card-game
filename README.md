# Flutter Flame Game

This project is a Flutter application that utilizes the Flame game engine to create a simple game. Below are the instructions for setting up and running the project.

## Prerequisites


## Getting Started

1. **Clone the repository:**

   ```bash
   git clone https://github.com/yourusername/flutter-flame-game.git
   cd flutter-flame-game
   ```

2. **Open the project in your IDE.**

3. **Install dependencies:**

   Run the following command to get the required packages:

   ```bash
   flutter pub get
   ```

4. **Run the application:**

   You can run the application using the following command:

   ```bash
   flutter run
   ```

## Sci-Fi Card Game

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