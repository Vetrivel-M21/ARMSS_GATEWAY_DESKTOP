import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Wraps the `logger` package and mirrors output to a local rotating
/// log file (`app_logs/app-YYYY-MM-DD.log`). This is the technical/debug
/// trail — separate from the `audit_logs` DB table, which is the business
/// audit trail.
class AppLogger {
  AppLogger._();
  static final AppLogger instance = AppLogger._();

  Logger? _logger;
  IOSink? _sink;

  Future<void> init() async {
    final dir = await getApplicationSupportDirectory();
    final logDir = Directory(p.join(dir.path, 'app_logs'));
    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }
    final today = DateTime.now().toIso8601String().split('T').first;
    final file = File(p.join(logDir.path, 'app-$today.log'));
    _sink = file.openWrite(mode: FileMode.append);

    _logger = Logger(
      printer: SimplePrinter(),
      output: _FileAndConsoleOutput(_sink!),
    );
  }

  void debug(String message) => _logger?.d(message);
  void info(String message) => _logger?.i(message);
  void warning(String message) => _logger?.w(message);
  void error(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger?.e(message, error: error, stackTrace: stackTrace);

  Future<void> dispose() async {
    await _sink?.flush();
    await _sink?.close();
  }
}

class _FileAndConsoleOutput extends LogOutput {
  final IOSink sink;
  _FileAndConsoleOutput(this.sink);

  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      // ignore: avoid_print
      print(line);
      sink.writeln(line);
    }
  }
}
