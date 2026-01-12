import 'package:logging/logging.dart';

/// Application logger
///
/// Usage:
/// ```dart
/// final _log = KluiLogger('MyClassName');
/// _log.info('Message sent');
/// _log.error('Failed to connect', error, stackTrace);
/// _log.debug('Stream data: $data');
/// ```
///
/// Best Practices:
/// - Use logger at file level (not method level)
/// - Use descriptive logger names (e.g., 'ChatController' not 'log')
/// - Include context in log messages
/// - Log errors with error objects and stack traces
/// - Use appropriate log levels (see CLAUDE.md 11.6)
class KluiLogger {
  final Logger _logger;

  KluiLogger(String name) : _logger = Logger(name);

  /// DEBUG level - Detailed diagnostics (hidden in release mode)
  /// Use for: Variable values, detailed flow, JSON dumps, API request/response bodies
  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.finest(message, error, stackTrace);
  }

  /// INFO level - General information (shown in release mode)
  /// Use for: User actions, API calls, state changes, lifecycle events
  void info(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.info(message, error, stackTrace);
  }

  /// WARNING level - Unexpected but recoverable issues (shown in release mode)
  /// Use for: Retry attempts, fallbacks, deprecated usage, validation failures
  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.warning(message, error, stackTrace);
  }

  /// ERROR level - Errors and exceptions (shown in release mode)
  /// Use for: API failures, uncaught exceptions, critical errors
  /// Always include error object and stackTrace when available
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
/// MUST be called first in main() before runApp()
///
/// Features:
/// - Structured log levels with timestamps
/// - Filters DEBUG logs in release mode
/// - Consistent formatting: [HH:MM:SS] [LEVEL] [LoggerName] Message
/// - Automatic error and stackTrace formatting
///
/// Example:
/// ```dart
/// void main() {
///   initLogging();
///   runApp(MyApp());
/// }
/// ```
void initLogging() {
  // Set global log level to ALL (filtering done in onRecord)
  Logger.root.level = Level.ALL;

  // Add console handler with formatting
  Logger.root.onRecord.listen((record) {
    // Filter DEBUG logs in release mode (dart.vm.product = true)
    if (const bool.fromEnvironment('dart.vm.product') &&
        record.level.value < Level.INFO.value) {
      return;
    }

    // Format: [14:25:30] [    INFO] [   ChatController] Message
    final level = record.level.name.toUpperCase().padRight(8);
    final time = record.time.toIso8601String().substring(11, 19);
    final name = record.loggerName.padRight(20);

    // Print main message
    print('[$time] [$level] [$name] ${record.message}');

    // Print error if present
    if (record.error != null) {
      print('  └─ Error: ${record.error}');
    }

    // Print stack trace if present
    if (record.stackTrace != null) {
      print('  └─ StackTrace:\n${record.stackTrace}');
    }
  });
}
