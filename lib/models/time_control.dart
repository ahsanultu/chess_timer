class TimeControl {
  final Duration initialTime;
  final Duration increment;
  final bool isDelayMode;
  final Duration delay;

  const TimeControl({
    required this.initialTime,
    required this.increment,
    required this.isDelayMode,
    required this.delay,
  });

  factory TimeControl.blitz() {
    return const TimeControl(
      initialTime: Duration(minutes: 3),
      increment: Duration(seconds: 2),
      isDelayMode: false,
      delay: Duration(seconds: 0),
    );
  }

  factory TimeControl.rapid() {
    return const TimeControl(
      initialTime: Duration(minutes: 10),
      increment: Duration(seconds: 5),
      isDelayMode: false,
      delay: Duration(seconds: 0),
    );
  }

  factory TimeControl.classical() {
    return const TimeControl(
      initialTime: Duration(minutes: 30),
      increment: Duration(seconds: 30),
      isDelayMode: false,
      delay: Duration(seconds: 0),
    );
  }
}
