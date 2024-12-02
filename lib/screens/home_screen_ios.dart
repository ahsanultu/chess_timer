import 'package:flutter/cupertino.dart';

import '../models/player.dart';
import '../models/time_control.dart';
import '../utils/audio_manager.dart';
import '../widgets/ios/control_panel_ios.dart'; // Assume an iOS-specific control panel widget
import '../widgets/ios/player_timer_ios.dart'; // Assume an iOS-specific timer widget
import '../widgets/ios/settings_dialog_ios.dart'; // iOS specific settings dialog

class HomeScreenIos extends StatefulWidget {
  const HomeScreenIos({super.key});

  @override
  State<HomeScreenIos> createState() => _HomeScreenIosState();
}

class _HomeScreenIosState extends State<HomeScreenIos> {
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
    final result = await showCupertinoModalPopup<Map<String, dynamic>>(
      context: context,
      builder: (context) => CupertinoPopupSurface(
        child: SettingsDialogIos(
          currentTimeControl: timeControl,
          player1Name: player1.name,
          player2Name: player2.name,
        ),
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

    showCupertinoDialog(
      context: context,
      barrierDismissible: false, // Ensures the dialog can't be dismissed by tapping outside
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Game Over'),
        content: Text('$playerName lost on time!'),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              _resetGame(); // Reset the game
            },
            child: const Text('New Game'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Chess Clock'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _showSettings,
          child: const Icon(CupertinoIcons.settings),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RotatedBox(
                quarterTurns: 2,
                child: PlayerTimerIos(
                  player: player2,
                  isActive: isGameActive && !isPaused && activePlayer == 2,
                  onTap: _togglePlayer,
                  onTimeOut: _handleTimeOut,
                ),
              ),
            ),
            ControlPanelIos(
              isGameActive: isGameActive,
              isPaused: isPaused,
              onStart: _startGame,
              onPause: _pauseGame,
              onReset: _resetGame,
              onSettings: _showSettings,
            ),
            Expanded(
              child: PlayerTimerIos(
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
