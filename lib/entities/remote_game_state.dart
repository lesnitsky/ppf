import 'package:ppf/entities/game_state.dart';
import 'package:ppf/entities/sender.dart';

class RemoteGameState extends Sender implements GameState {
  RemoteGameState();

  bool isPaused = false;
  bool isStarted = false;
  int health = 5;
  int score = 0;
  int speed = 0;

  @override
  pause() {
    isPaused = true;
    sendMessage({'type': 'pause'});
  }

  @override
  resume() {
    isPaused = false;
    sendMessage({'type': 'resume'});
  }

  _start() {
    isStarted = true;
    isPaused = false;

    score = 0;
    health = 5;
  }

  @override
  start([dynamic config]) {
    _start();

    sendMessage({
      'type': 'start',
      'payload': {'config': config ?? {}}
    });
  }

  @override
  restart([dynamic config]) {
    _start();

    sendMessage({
      'type': 'restart',
      'payload': {'config': config ?? {}}
    });
  }

  kill() {
    sendMessage({'type': 'kill'});
  }
}
