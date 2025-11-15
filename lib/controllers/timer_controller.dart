import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import '../models/time_control.dart';

class TimerController extends GetxController {
  // Observable state
  final Rx<PlayerTurn> currentTurn = PlayerTurn.none.obs;
  final Rx<TimerStatus> status = TimerStatus.idle.obs;
  final RxInt player1TimeMs = 0.obs;
  final RxInt player2TimeMs = 0.obs;
  final RxInt incrementMs = 0.obs;
  final RxList<TimeControl> customControls = <TimeControl>[].obs;
  final Rx<TimeControl> selectedControl = TimeControl.presets[4].obs; // Blitz 3+2

  Timer? _timer;
  DateTime? _lastTick;
  SharedPreferences? _prefs;

  @override
  void onInit() {
    super.onInit();
    _loadCustomControls();
    resetTimer(selectedControl.value);
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  // Load custom controls from storage
  Future<void> _loadCustomControls() async {
    _prefs = await SharedPreferences.getInstance();
    final customJson = _prefs?.getStringList('custom_controls') ?? [];

    customControls.value = customJson
        .map((json) => TimeControl.fromJson(jsonDecode(json)))
        .toList();
  }

  // Save custom controls to storage
  Future<void> _saveCustomControls() async {
    final customJson = customControls
        .map((control) => jsonEncode(control.toJson()))
        .toList();

    await _prefs?.setStringList('custom_controls', customJson);
  }

  // Add a new custom control
  Future<void> addCustomControl(TimeControl control) async {
    customControls.add(control);
    await _saveCustomControls();
  }

  // Delete a custom control
  Future<void> deleteCustomControl(TimeControl control) async {
    customControls.remove(control);
    await _saveCustomControls();
  }

  // Get all available controls (presets + custom)
  List<TimeControl> get allControls {
    return [...TimeControl.presets, ...customControls];
  }

  // Vibration helper
  Future<void> _vibrate({int duration = 30}) async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: duration);
    }
  }

  // Start the timer
  void startTimer() {
    if (status.value == TimerStatus.running) return;

    status.value = TimerStatus.running;
    _lastTick = DateTime.now();

    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      final now = DateTime.now();
      final elapsed = now.difference(_lastTick!).inMilliseconds;
      _lastTick = now;

      if (currentTurn.value == PlayerTurn.player1) {
        player1TimeMs.value -= elapsed;
        if (player1TimeMs.value <= 0) {
          player1TimeMs.value = 0;
          stopTimer();
          status.value = TimerStatus.finished;
          _onGameOver(PlayerTurn.player2);
        }
      } else if (currentTurn.value == PlayerTurn.player2) {
        player2TimeMs.value -= elapsed;
        if (player2TimeMs.value <= 0) {
          player2TimeMs.value = 0;
          stopTimer();
          status.value = TimerStatus.finished;
          _onGameOver(PlayerTurn.player1);
        }
      }
    });
  }

  // Stop the timer
  void stopTimer() {
    _timer?.cancel();
    _timer = null;
    status.value = TimerStatus.paused;
  }

  // Switch player turn
  void switchPlayer() {
    if (status.value == TimerStatus.finished) return;

    _vibrate();

    // Add increment to the player who just finished their turn
    if (currentTurn.value == PlayerTurn.player1) {
      player1TimeMs.value += incrementMs.value;
      currentTurn.value = PlayerTurn.player2;
    } else if (currentTurn.value == PlayerTurn.player2) {
      player2TimeMs.value += incrementMs.value;
      currentTurn.value = PlayerTurn.player1;
    } else {
      // First move - no increment
      currentTurn.value = PlayerTurn.player1;
    }

    _lastTick = DateTime.now();

    if (status.value == TimerStatus.idle) {
      startTimer();
    }
  }

  // Reset timer with a time control
  void resetTimer(TimeControl control) {
    _vibrate();
    stopTimer();

    selectedControl.value = control;
    player1TimeMs.value = control.minutes * 60 * 1000;
    player2TimeMs.value = control.minutes * 60 * 1000;
    incrementMs.value = control.incrementSeconds * 1000;
    currentTurn.value = PlayerTurn.none;
    status.value = TimerStatus.idle;
  }

  // Pause/Resume toggle
  void togglePauseResume() {
    _vibrate();

    if (status.value == TimerStatus.running) {
      stopTimer();
    } else if (status.value == TimerStatus.paused) {
      startTimer();
    }
  }

  // Handle game over
  void _onGameOver(PlayerTurn winner) {
    _vibrate(duration: 500);

    Get.dialog(
      AlertDialog(
        title: const Text('Game Over!'),
        content: Text(
          winner == PlayerTurn.player1
              ? 'Player 1 (Bottom) Wins!'
              : 'Player 2 (Top) Wins!',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              resetTimer(selectedControl.value);
            },
            child: const Text('New Game'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // Format time for display
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

  // Vibrate on settings open
  void onSettingsOpen() {
    _vibrate();
  }
}
