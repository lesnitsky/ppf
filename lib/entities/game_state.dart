abstract class GameState {
  bool isPaused;
  bool isStarted;
  int health;
  int score;

  pause();
  resume();
  start();
  restart();
  kill();
}
