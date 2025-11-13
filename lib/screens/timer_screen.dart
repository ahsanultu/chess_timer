import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../models/timer_state.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with TickerProviderStateMixin {
  late ChessTimerState _timerState;
  TimeControl _selectedControl = TimeControl.presets[4]; // Default: Blitz 3+2
  late AnimationController _pulseController;
  late AnimationController _switchController;

  @override
  void initState() {
    super.initState();
    _timerState = ChessTimerState.fromTimeControl(_selectedControl);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _switchController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _timerState.dispose();
    _pulseController.dispose();
    _switchController.dispose();
    super.dispose();
  }

  void _vibrate({int duration = 30}) async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: duration);
    }
  }

  void _handlePlayerTap(PlayerTurn player) {
    if (_timerState.status == TimerStatus.finished) return;

    // Only allow tap if it's the current player's turn or game hasn't started
    if (_timerState.currentTurn == player || _timerState.currentTurn == PlayerTurn.none) {
      _vibrate();
      _switchController.forward(from: 0);

      setState(() {
        _timerState.switchPlayer();

        if (_timerState.status == TimerStatus.idle) {
          _timerState.startTimer(_onTick, _onGameOver);
        }
      });
    }
  }

  void _onTick() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onGameOver(PlayerTurn winner) {
    _vibrate(duration: 500);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Game Over!'),
          content: Text(
            winner == PlayerTurn.player1
                ? 'Player 1 (Top) Wins!'
                : 'Player 2 (Bottom) Wins!',
            style: const TextStyle(fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetTimer();
              },
              child: const Text('New Game'),
            ),
          ],
        ),
      );
    }
  }

  void _pauseResumeTimer() {
    _vibrate();

    setState(() {
      if (_timerState.status == TimerStatus.running) {
        _timerState.stopTimer();
      } else if (_timerState.status == TimerStatus.paused) {
        _timerState.startTimer(_onTick, _onGameOver);
      }
    });
  }

  void _resetTimer() {
    _vibrate();

    setState(() {
      _timerState.reset(_selectedControl);
    });
  }

  void _showSettings() {
    _vibrate();

    if (_timerState.status == TimerStatus.running) {
      _timerState.stopTimer();
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select Time Control',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: TimeControl.presets.length,
                itemBuilder: (context, index) {
                  final control = TimeControl.presets[index];
                  final isSelected = control == _selectedControl;

                  return Card(
                    elevation: isSelected ? 4 : 1,
                    color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
                    child: ListTile(
                      title: Text(
                        control.name,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected ? const Icon(Icons.check_circle) : null,
                      onTap: () {
                        _vibrate();
                        setState(() {
                          _selectedControl = control;
                          _timerState.reset(control);
                        });
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final controlBarHeight = 80.0;
    final playerAreaHeight = (screenHeight - controlBarHeight) / 2;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Player 2 Area (Top - rotated 180°)
            _buildPlayerArea(
              player: PlayerTurn.player2,
              height: playerAreaHeight,
              isRotated: true,
              timeMs: _timerState.player2TimeMs,
            ),

            // Control Bar
            Container(
              height: controlBarHeight,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton(
                    icon: Icons.settings,
                    onPressed: _showSettings,
                    tooltip: 'Settings',
                  ),
                  _buildControlButton(
                    icon: _timerState.status == TimerStatus.running
                        ? Icons.pause
                        : Icons.play_arrow,
                    onPressed: _timerState.status != TimerStatus.idle
                        ? _pauseResumeTimer
                        : null,
                    tooltip: _timerState.status == TimerStatus.running ? 'Pause' : 'Resume',
                  ),
                  _buildControlButton(
                    icon: Icons.refresh,
                    onPressed: _resetTimer,
                    tooltip: 'Reset',
                  ),
                ],
              ),
            ),

            // Player 1 Area (Bottom)
            _buildPlayerArea(
              player: PlayerTurn.player1,
              height: playerAreaHeight,
              isRotated: false,
              timeMs: _timerState.player1TimeMs,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerArea({
    required PlayerTurn player,
    required double height,
    required bool isRotated,
    required int timeMs,
  }) {
    final isActive = _timerState.currentTurn == player && _timerState.status == TimerStatus.running;
    final isFinished = _timerState.status == TimerStatus.finished;
    final isWinner = isFinished && timeMs > 0;
    final isLoser = isFinished && timeMs <= 0;

    Color backgroundColor;
    if (isWinner) {
      backgroundColor = Colors.green.shade400;
    } else if (isLoser) {
      backgroundColor = Colors.red.shade400;
    } else if (isActive) {
      backgroundColor = Theme.of(context).colorScheme.primaryContainer;
    } else {
      backgroundColor = Theme.of(context).colorScheme.surfaceVariant;
    }

    return GestureDetector(
      onTap: () => _handlePlayerTap(player),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            top: player == PlayerTurn.player1
                ? BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                    width: 1,
                  )
                : BorderSide.none,
            bottom: player == PlayerTurn.player2
                ? BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                    width: 1,
                  )
                : BorderSide.none,
          ),
        ),
        child: Transform.rotate(
          angle: isRotated ? 3.14159 : 0, // 180 degrees in radians
          child: Stack(
            children: [
              // Active indicator pulse
              if (isActive)
                FadeTransition(
                  opacity: _pulseController,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    ),
                  ),
                ),

              // Time display
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _timerState.formatTime(timeMs),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: isActive
                                ? Theme.of(context).colorScheme.onPrimaryContainer
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      player == PlayerTurn.player1 ? 'PLAYER 1' : 'PLAYER 2',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: isActive
                                ? Theme.of(context).colorScheme.onPrimaryContainer
                                : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                            letterSpacing: 2,
                          ),
                    ),
                  ],
                ),
              ),

              // Active turn indicator
              if (isActive)
                Positioned(
                  left: 20,
                  top: 20,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 1.0, end: 1.2).animate(
                      CurvedAnimation(
                        parent: _pulseController,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: Icon(
                      Icons.play_circle_filled,
                      color: Theme.of(context).colorScheme.primary,
                      size: 32,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Icon(
              icon,
              size: 32,
              color: onPressed != null
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }
}
