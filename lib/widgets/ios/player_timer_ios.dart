import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../../models/player.dart';
import '../../utils/audio_manager.dart';
import '../../utils/time_formatter.dart';

class PlayerTimerIos extends StatefulWidget {
  final Player player;
  final bool isActive;
  final VoidCallback onTap;
  final Function(String)? onTimeOut;

  const PlayerTimerIos({
    super.key,
    required this.player,
    required this.isActive,
    required this.onTap,
    this.onTimeOut,
  });

  @override
  State<PlayerTimerIos> createState() => _PlayerTimerIosState();
}

class _PlayerTimerIosState extends State<PlayerTimerIos> {
  Timer? _timer;

  @override
  void didUpdateWidget(PlayerTimerIos oldWidget) {
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
    return CupertinoButton(
      onPressed: widget.onTap,
      padding: const EdgeInsets.all(16),
      color: _getBackgroundColor(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.player.name,
            style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            TimeFormatter.format(widget.player.timeLeft),
            style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: _getTimeColor(),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Moves: ${widget.player.movesPlayed}',
            style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    if (!widget.isActive) {
      return CupertinoColors.systemGrey.withOpacity(0.2);
    }
    return CupertinoColors.activeBlue.withOpacity(0.2);
  }

  Color _getTimeColor() {
    if (widget.player.timeLeft.inSeconds <= 30) {
      return CupertinoColors.destructiveRed;
    }
    if (widget.player.timeLeft.inSeconds <= 60) {
      return CupertinoColors.activeOrange;
    }
    return CupertinoColors.activeGreen;
  }
}
