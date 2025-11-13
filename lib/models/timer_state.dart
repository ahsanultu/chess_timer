import 'dart:async';

enum PlayerTurn { player1, player2, none }

enum TimerStatus { idle, running, paused, finished }

class TimeControl {
  final String name;
  final int minutes;
  final int incrementSeconds;

  const TimeControl(this.name, this.minutes, this.incrementSeconds);

  static const List<TimeControl> presets = [
    TimeControl('Bullet 1+0', 1, 0),
    TimeControl('Bullet 1+1', 1, 1),
    TimeControl('Bullet 2+1', 2, 1),
    TimeControl('Blitz 3+0', 3, 0),
    TimeControl('Blitz 3+2', 3, 2),
    TimeControl('Blitz 5+0', 5, 0),
    TimeControl('Blitz 5+3', 5, 3),
    TimeControl('Rapid 10+0', 10, 0),
    TimeControl('Rapid 15+10', 15, 10),
    TimeControl('Classical 30+0', 30, 0),
  ];
}

class ChessTimerState {
  int player1TimeMs;
  int player2TimeMs;
  final int incrementMs;
  PlayerTurn currentTurn;
  TimerStatus status;
  Timer? _timer;
  DateTime? _lastTick;

  ChessTimerState({
    required this.player1TimeMs,
    required this.player2TimeMs,
    required this.incrementMs,
    this.currentTurn = PlayerTurn.none,
    this.status = TimerStatus.idle,
  });

  factory ChessTimerState.fromTimeControl(TimeControl control) {
    return ChessTimerState(
      player1TimeMs: control.minutes * 60 * 1000,
      player2TimeMs: control.minutes * 60 * 1000,
      incrementMs: control.incrementSeconds * 1000,
    );
  }

  void startTimer(Function onTick, Function onGameOver) {
    if (status == TimerStatus.running) return;

    status = TimerStatus.running;
    _lastTick = DateTime.now();

    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      final now = DateTime.now();
      final elapsed = now.difference(_lastTick!).inMilliseconds;
      _lastTick = now;

      if (currentTurn == PlayerTurn.player1) {
        player1TimeMs -= elapsed;
        if (player1TimeMs <= 0) {
          player1TimeMs = 0;
          stopTimer();
          status = TimerStatus.finished;
          onGameOver(PlayerTurn.player2);
        }
      } else if (currentTurn == PlayerTurn.player2) {
        player2TimeMs -= elapsed;
        if (player2TimeMs <= 0) {
          player2TimeMs = 0;
          stopTimer();
          status = TimerStatus.finished;
          onGameOver(PlayerTurn.player1);
        }
      }

      onTick();
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
    status = TimerStatus.paused;
  }

  void switchPlayer() {
    if (status == TimerStatus.finished) return;

    // Add increment to the player who just finished their turn
    if (currentTurn == PlayerTurn.player1) {
      player1TimeMs += incrementMs;
      currentTurn = PlayerTurn.player2;
    } else if (currentTurn == PlayerTurn.player2) {
      player2TimeMs += incrementMs;
      currentTurn = PlayerTurn.player1;
    } else {
      // First move - no increment
      currentTurn = PlayerTurn.player1;
    }

    _lastTick = DateTime.now();
  }

  void reset(TimeControl control) {
    stopTimer();
    player1TimeMs = control.minutes * 60 * 1000;
    player2TimeMs = control.minutes * 60 * 1000;
    currentTurn = PlayerTurn.none;
    status = TimerStatus.idle;
  }

  void dispose() {
    _timer?.cancel();
  }

  String formatTime(int milliseconds) {
    final totalSeconds = (milliseconds / 1000).floor();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final ms = (milliseconds % 1000) ~/ 100;

    if (minutes > 0) {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '$seconds.$ms';
    }
  }
}
