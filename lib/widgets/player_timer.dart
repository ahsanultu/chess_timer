import 'dart:async';

import 'package:flutter/material.dart';

import '../models/player.dart';
import '../utils/audio_manager.dart';
import '../utils/time_formatter.dart';

class PlayerTimer extends StatefulWidget {
  final Player player;
  final bool isActive;
  final VoidCallback onTap;
  final Function(String)? onTimeOut;

  const PlayerTimer({
    super.key,
    required this.player,
    required this.isActive,
    required this.onTap,
    this.onTimeOut,
  });

  @override
  State<PlayerTimer> createState() => _PlayerTimerState();
}

class _PlayerTimerState extends State<PlayerTimer> {
  Timer? _timer;

  @override
  void didUpdateWidget(PlayerTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _startTimer();
      } else {
        _stopTimer();
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        if (widget.player.timeLeft.inMilliseconds > 0) {
          widget.player.timeLeft -= const Duration(milliseconds: 100);

          // Low time warning
          if (widget.player.timeLeft.inSeconds <= 10) {
            AudioManager.playLowTime();
          }
        } else {
          _stopTimer();
          widget.player.timeLeft = Duration.zero;

          // Game over - player lost on time
          if (widget.onTimeOut != null) {
            AudioManager.playTimeout();
            widget.onTimeOut!(widget.player.name);
          }
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        color: _getBackgroundColor(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.player.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              TimeFormatter.format(widget.player.timeLeft),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getTimeColor(),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Moves: ${widget.player.movesPlayed}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    if (!widget.isActive) return Theme.of(context).colorScheme.surface;
    return Theme.of(context).colorScheme.primaryContainer;
  }

  Color _getTimeColor() {
    if (widget.player.timeLeft.inSeconds <= 30) {
      return Colors.red;
    }
    if (widget.player.timeLeft.inSeconds <= 60) {
      return Colors.orange;
    }
    return Colors.green;
  }
}
