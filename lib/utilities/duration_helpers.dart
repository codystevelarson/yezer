String durationToText(Duration d,
    {Duration match = Duration.zero, bool milliseconds = false}) {
  Duration compare = match != Duration.zero ? match : d;
  return '${compare.inHours > 0 ? '${d.inHours}:' : ''}${compare.inMinutes > 0 ? padNumber(d.inMinutes) : '00'}:${padNumber(d.inSeconds)}${milliseconds ? '.${d.inMilliseconds}' : ''}';
}

String padNumber(int number, {pad = 2}) {
  return number.toString().padLeft(2, '0');
}
