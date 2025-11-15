import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/timer_controller.dart';
import '../models/time_control.dart';
import '../widgets/settings_bottom_sheet.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TimerController());

    final screenHeight = MediaQuery.of(context).size.height;
    final controlBarHeight = 80.0;
    final playerAreaHeight = (screenHeight - controlBarHeight) / 2;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Player 2 Area (Top - rotated 180°)
            Obx(() => _buildPlayerArea(
                  context: context,
                  controller: controller,
                  player: PlayerTurn.player2,
                  height: playerAreaHeight,
                  isRotated: true,
                  timeMs: controller.player2TimeMs.value,
                )),

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
                    context: context,
                    icon: Icons.settings,
                    onPressed: () {
                      controller.onSettingsOpen();
                      if (controller.status.value == TimerStatus.running) {
                        controller.stopTimer();
                      }
                      Get.bottomSheet(
                        const SettingsBottomSheet(),
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                      );
                    },
                    tooltip: 'Settings',
                  ),
                  Obx(() => _buildControlButton(
                        context: context,
                        icon: controller.status.value == TimerStatus.running
                            ? Icons.pause
                            : Icons.play_arrow,
                        onPressed: controller.status.value != TimerStatus.idle
                            ? () => controller.togglePauseResume()
                            : null,
                        tooltip: controller.status.value == TimerStatus.running
                            ? 'Pause'
                            : 'Resume',
                      )),
                  Obx(() => _buildControlButton(
                        context: context,
                        icon: Icons.refresh,
                        onPressed: () => controller.resetTimer(controller.selectedControl.value),
                        tooltip: 'Reset',
                      )),
                ],
              ),
            ),

            // Player 1 Area (Bottom)
            Obx(() => _buildPlayerArea(
                  context: context,
                  controller: controller,
                  player: PlayerTurn.player1,
                  height: playerAreaHeight,
                  isRotated: false,
                  timeMs: controller.player1TimeMs.value,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerArea({
    required BuildContext context,
    required TimerController controller,
    required PlayerTurn player,
    required double height,
    required bool isRotated,
    required int timeMs,
  }) {
    final isActive = controller.currentTurn.value == player &&
        controller.status.value == TimerStatus.running;
    final isFinished = controller.status.value == TimerStatus.finished;
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
      onTap: () => controller.switchPlayer(),
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
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1000),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: 0.3 + (0.2 * (1 - value)),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        ),
                      ),
                    );
                  },
                  onEnd: () {
                    // Restart animation
                    if (isActive) {
                      (context as Element).markNeedsBuild();
                    }
                  },
                ),

              // Time display
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      controller.formatTime(timeMs),
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
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withOpacity(0.6),
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
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 1.0, end: 1.2),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Icon(
                          Icons.play_circle_filled,
                          color: Theme.of(context).colorScheme.primary,
                          size: 32,
                        ),
                      );
                    },
                    onEnd: () {
                      // Restart animation
                      if (isActive) {
                        (context as Element).markNeedsBuild();
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required BuildContext context,
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
