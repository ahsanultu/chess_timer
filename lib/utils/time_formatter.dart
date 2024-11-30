class TimeFormatter {
  static String format(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    if (duration.inHours > 0) {
      return '${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}';
    }

    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final tenths = (duration.inMilliseconds % 1000 ~/ 100);

    if (duration.inMinutes > 0) {
      return '$minutes:$seconds';
    }

    return '$seconds.$tenths';
  }
}
