import 'package:intl/intl.dart';

class TimeUtils {
  TimeUtils._();

  static String toStringTime(DateTime time) {
    if (time is DateTime) {
      final DateFormat dateFormat = DateFormat.Hm();
      return dateFormat.format(time);
    }
    return '';
  }

  /// Returns a formatted string for the given Duration [d] to be DD:HH:mm:ss
  /// and ignore if 0.
  static String formatDuration(Duration d) {
    var seconds = d.inSeconds;
    final days = seconds ~/ Duration.secondsPerDay;
    seconds -= days * Duration.secondsPerDay;
    final hours = seconds ~/ Duration.secondsPerHour;
    seconds -= hours * Duration.secondsPerHour;
    final minutes = seconds ~/ Duration.secondsPerMinute;
    seconds -= minutes * Duration.secondsPerMinute;

    final List<String> tokens = [];
    if (days != 0) {
      tokens.add('${days}d');
    }
    if (tokens.isNotEmpty || hours != 0) {
      tokens.add('${hours}h');
    }
    if (tokens.isNotEmpty || minutes != 0) {
      tokens.add('${minutes}m');
    }
    tokens.add('${seconds}s');

    return tokens.join(':');
  }

  static Duration getDaysRemain(DateTime dateTime) {
    var today = DateTime.now();
    int milisecondsRemain =
        dateTime.millisecondsSinceEpoch - today.millisecondsSinceEpoch;
    return Duration(milliseconds: milisecondsRemain);
  }
}
