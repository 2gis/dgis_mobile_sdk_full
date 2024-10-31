String formatDuration(Duration duration) {
  var seconds = duration.inSeconds;
  final days = seconds ~/ Duration.secondsPerDay;
  seconds -= days * Duration.secondsPerDay;
  final hours = seconds ~/ Duration.secondsPerHour;
  seconds -= hours * Duration.secondsPerHour;
  final minutes = seconds ~/ Duration.secondsPerMinute;

  final List<String> tokens = [];
  if (days != 0) {
    tokens.add('${days} д');
  }
  if (tokens.isNotEmpty || hours != 0) {
    tokens.add('${hours} ч');
  }
  if (tokens.isNotEmpty || minutes != 0) {
    tokens.add('${minutes} мин');
  }

  return tokens.join(' ');
}
