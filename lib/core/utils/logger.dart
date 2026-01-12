import 'package:logging/logging.dart';

/// Application logger
///
/// Usage:
/// ```dart
/// final log = KluiLogger('ChatController');
/// log.info('Message sent');
/// log.error('Failed to connect');
/// log.debug('Stream data: $data');
/// ```
class KluiLogger {
  final Logger _logger;

  KluiLogger(String name) : _logger = Logger(name);

  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.finest(message, error, stackTrace);
  }

  void info(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.info(message, error, stackTrace);
  }

  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.warning(message, error, stackTrace);
  }

  void error(String message, [Object? err, StackTrace? stackTrace]) {
    _logger.severe(message, err, stackTrace);
  }

  /// Shorthand for [info]
  void i(String message, [Object? err, StackTrace? stackTrace]) =>
      info(message, err, stackTrace);

  /// Shorthand for [error]
  void e(String message, [Object? err, StackTrace? stackTrace]) =>
      error(message, err, stackTrace);

  /// Shorthand for [debug]
  void d(String message, [Object? err, StackTrace? stackTrace]) =>
      debug(message, err, stackTrace);

  /// Shorthand for [warning]
  void w(String message, [Object? err, StackTrace? stackTrace]) =>
      warning(message, err, stackTrace);
}

/// Initialize logging system
///
/// Call this in main() before runApp()
void initLogging() {
  // Set global log level
  Logger.root.level = Level.ALL;

  // Add console handler with formatting
  Logger.root.onRecord.listen((record) {
    // Only print INFO and above in release mode
    if (const bool.fromEnvironment('dart.vm.product') &&
        record.level.value < Level.INFO.value) {
      return;
    }

    final level = record.level.name.toUpperCase().padRight(8);
    final time = record.time.toIso8601String().substring(11, 19);
    final name = record.loggerName.padRight(20);

    // Color codes for terminal (not used in web)
    // String color;
    // switch (record.level.name) {
    //   case 'SEVERE':
    //     color = '\x1B[31m'; // Red
    //     break;
    //   case 'WARNING':
    //     color = '\x1B[33m'; // Yellow
    //     break;
    //   case 'INFO':
    //     color = '\x1B[32m'; // Green
    //     break;
    //   default:
    //     color = '\x1B[0m'; // Reset
    // }

    print('[$time] [$level] [$name] ${record.message}');

    if (record.error != null) {
      print('  Error: ${record.error}');
    }
    if (record.stackTrace != null) {
      print('  StackTrace:\n${record.stackTrace}');
    }
  });
}
