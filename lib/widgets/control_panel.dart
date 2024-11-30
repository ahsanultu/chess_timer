import 'package:flutter/material.dart';

class ControlPanel extends StatefulWidget {
  final bool isGameActive;
  final bool isPaused;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onReset;
  final VoidCallback onSettings;

  const ControlPanel({
    super.key,
    required this.isGameActive,
    required this.isPaused,
    required this.onStart,
    required this.onPause,
    required this.onReset,
    required this.onSettings,
  });

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  @override
  Widget build(BuildContext context) {
    bool isLightMode = Theme.of(context).brightness == Brightness.light;
    Color currentColor = isLightMode ? Colors.black : Colors.white;
    return Container(
      color: isLightMode ? const Color(0xFFDFE3E8) : const Color(0xFF252527),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: widget.onReset,
            icon: Icon(
              Icons.refresh,
              color: currentColor,
            ),
            tooltip: 'Reset',
          ),
          IconButton(
            onPressed: !widget.isGameActive || widget.isPaused ? widget.onStart : widget.onPause,
            icon: Icon(
              !widget.isGameActive || widget.isPaused ? Icons.play_arrow : Icons.pause,
              color: currentColor,
            ),
            tooltip: !widget.isGameActive || widget.isPaused ? 'Start' : 'Pause',
          ),
          IconButton(
            onPressed: widget.onSettings,
            icon: Icon(
              Icons.settings,
              color: currentColor,
            ),
            tooltip: 'Settings',
          ),
        ],
      ),
    );
  }
}
