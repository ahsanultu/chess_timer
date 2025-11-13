# Chess Timer

Advanced Chess Timer built with Flutter - designed for an effortless, player-focused experience.

## Features

### User-Friendly Design
- **Large Tap Areas**: Full-screen tap zones for each player - no need to aim for small buttons during fast games
- **Rotated Display**: Player 2's time is rotated 180° for easy reading from both sides of the board
- **Clear Visual Feedback**: Active player highlighted with animated pulsing background
- **Haptic Feedback**: Satisfying vibration on every tap to confirm your move without looking at the screen

### Game Features
- **10 Time Control Presets**: From Bullet (1+0) to Classical (30+0)
  - Bullet: 1+0, 1+1, 2+1
  - Blitz: 3+0, 3+2, 5+0, 5+3
  - Rapid: 10+0, 15+10
  - Classical: 30+0
- **Increment Support**: Automatically adds time after each move
- **Precision Display**: Shows tenths of a second when under 1 minute
- **Pause/Resume**: Pause the game anytime and resume when ready
- **Quick Reset**: Start a new game with a single tap

### Visual Enhancements
- **Material Design 3**: Modern, clean interface
- **Dark/Light Mode**: Automatically adapts to system theme
- **Smooth Animations**: Polished transitions and visual feedback
- **Winner/Loser Colors**: Green for winner, red for loser when time runs out
- **Active Turn Indicator**: Play icon shows whose turn it is

## How to Use

1. **Select Time Control**:
   - Tap the ⚙️ Settings button
   - Choose your preferred time control from the list
   - Default is Blitz 3+2

2. **Start the Game**:
   - Player 1 (bottom) taps their area to start their opponent's clock
   - After each move, tap your area to switch to opponent's clock
   - The active player's area is highlighted

3. **Controls**:
   - ⚙️ **Settings**: Change time control
   - ⏸️/▶️ **Pause/Resume**: Pause or resume the game
   - 🔄 **Reset**: Start a new game with current time control

4. **Game Over**:
   - When a player runs out of time, the game ends automatically
   - Winner is shown in a dialog
   - Tap "New Game" to start fresh

## Installation

### Prerequisites
- Flutter SDK (>=3.0.0)
- Android Studio or VS Code with Flutter plugins
- Android device or emulator (for vibration support)

### Build & Run
```bash
# Get dependencies
flutter pub get

# Run on connected device
flutter run

# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

## Why This Design?

Traditional chess timer apps often have small buttons that require precision tapping during fast-paced games. This app eliminates that friction:

- **No aiming required**: Just tap anywhere on your half of the screen
- **Instant feedback**: Vibration confirms your tap without looking
- **Focus on chess**: The UI fades into the background, letting you concentrate on the game
- **No accidental taps**: Smart logic ensures only valid taps are registered

Perfect for over-the-board games where every second counts!

## License

GNU General Public License v3.0 - See LICENSE file for details
