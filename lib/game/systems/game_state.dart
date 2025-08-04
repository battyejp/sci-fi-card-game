enum GameState {
  loading,
  menu,
  playing,
  paused,
  gameOver,
}

class GameStateManager {
  GameState _currentState = GameState.loading;
  
  GameState get currentState => _currentState;
  
  void setState(GameState newState) {
    _currentState = newState;
  }
  
  bool isInGame() {
    return _currentState == GameState.playing;
  }
  
  bool isPaused() {
    return _currentState == GameState.paused;
  }
  
  bool isInMenu() {
    return _currentState == GameState.menu;
  }
}
