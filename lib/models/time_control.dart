import 'dart:async';

enum PlayerTurn { player1, player2, none }

enum TimerStatus { idle, running, paused, finished }

class TimeControl {
  final String name;
  final int minutes;
  final int incrementSeconds;
  final bool isCustom;

  const TimeControl(
    this.name,
    this.minutes,
    this.incrementSeconds, {
    this.isCustom = false,
  });

  static const List<TimeControl> presets = [
    TimeControl('Bullet 1+0', 1, 0),
    TimeControl('Bullet 1+1', 1, 1),
    TimeControl('Bullet 2+1', 2, 1),
    TimeControl('Blitz 3+0', 3, 0),
    TimeControl('Blitz 3+2', 3, 2),
    TimeControl('Blitz 5+0', 5, 0),
    TimeControl('Blitz 5+3', 5, 3),
    TimeControl('Rapid 10+0', 10, 0),
    TimeControl('Rapid 15+10', 15, 10),
    TimeControl('Classical 30+0', 30, 0),
  ];

  // Convert to JSON for storage
  Map<String, dynamic> toJson() => {
        'name': name,
        'minutes': minutes,
        'incrementSeconds': incrementSeconds,
        'isCustom': isCustom,
      };

  // Create from JSON
  factory TimeControl.fromJson(Map<String, dynamic> json) {
    return TimeControl(
      json['name'] as String,
      json['minutes'] as int,
      json['incrementSeconds'] as int,
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeControl &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          minutes == other.minutes &&
          incrementSeconds == other.incrementSeconds;

  @override
  int get hashCode => name.hashCode ^ minutes.hashCode ^ incrementSeconds.hashCode;
}
