import 'package:flutter/material.dart';

import '../models/player.dart';
import '../models/time_control.dart';
import '../utils/audio_manager.dart';
import '../widgets/control_panel.dart';
import '../widgets/player_timer.dart';
import '../widgets/settings_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Player player1;
  late Player player2;
  late TimeControl timeControl;
  bool isGameActive = false;
  bool isPaused = false;
  int activePlayer = 1;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    AudioManager.init();
  }

  void _initializeGame() {
    timeControl = const TimeControl(
      initialTime: Duration(minutes: 5),
      increment: Duration(seconds: 3),
      isDelayMode: false,
      delay: Duration(seconds: 2),
    );

    player1 = Player(
      name: 'Player 1',
      timeLeft: timeControl.initialTime,
      movesPlayed: 0,
    );

    player2 = Player(
      name: 'Player 2',
      timeLeft: timeControl.initialTime,
      movesPlayed: 0,
    );
  }

  void _togglePlayer() {
    if (!isGameActive || isPaused) return;

    setState(() {
      if (activePlayer == 1) {
        _addIncrementOrDelay(player1);
        activePlayer = 2;
      } else {
        _addIncrementOrDelay(player2);
        activePlayer = 1;
      }
      AudioManager.playMove();
    });
  }

  void _addIncrementOrDelay(Player player) {
    if (timeControl.isDelayMode) {
      // Implementation for delay mode
    } else {
      player.timeLeft += timeControl.increment;
      player.movesPlayed++;
    }
  }

  void _startGame() {
    setState(() {
      isGameActive = true;
      isPaused = false;
    });
    AudioManager.playStart();
  }

  void _pauseGame() {
    setState(() {
      isPaused = true;
    });
    AudioManager.playPause();
  }

  void _resetGame() {
    setState(() {
      _initializeGame();
      isGameActive = false;
      isPaused = false;
      activePlayer = 1;
    });
    AudioManager.playReset();
  }

  void _showSettings() async {
    if (isGameActive && !isPaused) {
      _pauseGame();
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => SettingsDialog(
        currentTimeControl: timeControl,
        player1Name: player1.name,
        player2Name: player2.name,
      ),
    );

    if (result != null) {
      setState(() {
        timeControl = result['timeControl'] as TimeControl;
        player1.name = result['player1Name'] as String;
        player2.name = result['player2Name'] as String;

        // Reset timers with new time control
        player1.timeLeft = timeControl.initialTime;
        player2.timeLeft = timeControl.initialTime;
        player1.movesPlayed = 0;
        player2.movesPlayed = 0;

        isGameActive = false;
        isPaused = false;
        activePlayer = 1;
      });
    }
  }

  void _handleTimeOut(String playerName) {
    setState(() {
      isGameActive = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('$playerName lost on time!'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: const Text('New Game'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RotatedBox(
                quarterTurns: 2,
                child: PlayerTimer(
                  player: player2,
                  isActive: isGameActive && !isPaused && activePlayer == 2,
                  onTap: _togglePlayer,
                  onTimeOut: _handleTimeOut,
                ),
              ),
            ),
            ControlPanel(
              isGameActive: isGameActive,
              isPaused: isPaused,
              onStart: _startGame,
              onPause: _pauseGame,
              onReset: _resetGame,
              onSettings: _showSettings,
            ),
            Expanded(
              child: PlayerTimer(
                player: player1,
                isActive: isGameActive && !isPaused && activePlayer == 1,
                onTap: _togglePlayer,
                onTimeOut: _handleTimeOut,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
