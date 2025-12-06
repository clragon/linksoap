import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:ansicolor/ansicolor.dart';

void setupLogging() {
  ansiColorDisabled = false;

  final errorPen = AnsiPen()..red();
  final warnPen = AnsiPen()..yellow();
  final infoPen = AnsiPen()..green();
  final debugPen = AnsiPen()..gray();
  final timePen = AnsiPen()..cyan();
  final loggerPen = AnsiPen()..blue();

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    final time = record.time.toIso8601String();
    final level = record.level.name;
    final logger = record.loggerName;
    final msg = record.message;

    String coloredLevel;
    if (record.level >= Level.SEVERE) {
      coloredLevel = errorPen(level);
    } else if (record.level >= Level.WARNING) {
      coloredLevel = warnPen(level);
    } else if (record.level >= Level.INFO) {
      coloredLevel = infoPen(level);
    } else {
      coloredLevel = debugPen(level);
    }

    debugPrint('${timePen('[$time]')} $coloredLevel: ${loggerPen(logger)}: $msg');
  });
}
