import 'package:flutter/cupertino.dart';

class ControlPanelIos extends StatelessWidget {
  final bool isGameActive;
  final bool isPaused;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onReset;
  final VoidCallback onSettings;

  const ControlPanelIos({
    super.key,
    required this.isGameActive,
    required this.isPaused,
    required this.onStart,
    required this.onPause,
    required this.onReset,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    bool isLightMode = CupertinoTheme.brightnessOf(context) == Brightness.light;
    Color currentColor = isLightMode ? CupertinoColors.black : CupertinoColors.white;

    return Container(
      color: isLightMode ? CupertinoColors.systemGrey6 : CupertinoColors.systemGrey,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onReset,
            child: Icon(
              CupertinoIcons.refresh,
              color: currentColor,
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: !isGameActive || isPaused ? onStart : onPause,
            child: Icon(
              !isGameActive || isPaused ? CupertinoIcons.play_arrow : CupertinoIcons.pause,
              color: currentColor,
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onSettings,
            child: Icon(
              CupertinoIcons.settings,
              color: currentColor,
            ),
          ),
        ],
      ),
    );
  }
}
