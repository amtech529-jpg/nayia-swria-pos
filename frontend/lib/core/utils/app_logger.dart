import 'package:flutter/foundation.dart';

class AppLogger {
  static void log(String message) {
    if (kDebugMode) {
      print('[LOG] ${DateTime.now()}: $message');
    }
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('[ERROR] ${DateTime.now()}: $message');
      if (error != null) print(error);
      if (stackTrace != null) print(stackTrace);
    }
  }
}
