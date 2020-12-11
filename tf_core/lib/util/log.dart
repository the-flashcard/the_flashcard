import 'package:ansicolor/ansicolor.dart';
import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
import 'package:tf_core/tf_core.dart';

enum LogLevel { DEBUG, INFO, ERROR }

class Log {
  static final _debugColor = _chooseLogColor(LogLevel.DEBUG);
  static final _infoColor = _chooseLogColor(LogLevel.INFO);
  static final _errorColor = _chooseLogColor(LogLevel.ERROR);

  static Uri _uri;

  static LogLevel logLevel = LogLevel.values[Config.getInt("log_level")];

  // static void postLog(String data) {
  //   try {
  //     if (_uri == null) {
  //       var url = Config.getString("log_endpoint");
  //       _uri = Uri.parse(url);
  //     }
  //     if (_uri != null) {
  //       Map<String, dynamic> body = {'data': data};
  //       http.post(_uri, body: jsonEncode(body));
  //     }
  //   } catch (ex) {}
  // }

  static void debug(dynamic data) {
    printConsole(_debugColor, data);
    if (logLevel.index <= LogLevel.DEBUG.index) {
      if (data is Exception) {
        exception(data);
      } else if (data is Error) {
        logError(data);
      }
      // else if (data is String) {
      //   postLog(data);
      // } else {
      //   postLog(data.toString());
      // }
    }
  }

  static void info(dynamic data) {
    printConsole(_infoColor, data);
    if (logLevel.index <= LogLevel.INFO.index) {
      if (data is Exception) {
        exception(data);
      } else if (data is Error) {
        logError(data);
      }
      // else if (data is String) {
      //   postLog(data);
      // } else {
      //   postLog(data.toString());
      // }
    }
  }

  static void error(dynamic data) {
    printConsole(_errorColor, data);
    if (logLevel.index <= LogLevel.ERROR.index) {
      if (data is Exception) {
        exception(data);
      } else if (data is Error) {
        logError(data);
      }
      // else if (data is String) {
      //   postLog(data);
      // } else {
      //   postLog(data.toString());
      // }
    }
  }

  static void exception(Exception exception) {
    printConsole(_errorColor, exception);
    // if (logLevel.index <= LogLevel.ERROR.index) {
    //   postLog(exception.toString());
    // }
  }

  static void logError(Error error) {
    printConsole(_errorColor, error);
    // if (logLevel.index <= LogLevel.ERROR.index) {
    //   var log = {"stack_trace": error?.stackTrace, "message": error?.toString()};
    //   postLog(log.toString());
    // }
  }

  static void printConsole(AnsiPen code, dynamic data) {
    if (!kReleaseMode) {
      // ignore: avoid_print
      print(code(data.toString()));
    }
  }
}

/// Chooses a color based on the logger [level].
AnsiPen _chooseLogColor(LogLevel level) {
  switch (level) {
    case LogLevel.DEBUG:
      return AnsiPen()..green();
    case LogLevel.INFO:
      return AnsiPen()..blue();
    case LogLevel.ERROR:
      return AnsiPen()..red();
    default:
      return AnsiPen()..white();
  }
}
