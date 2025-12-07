import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

typedef ShareTransformer = String Function(String data);

final _logger = Logger('ShareHandler');

class ShareHandler {
  static const _channel = MethodChannel('net.clynamic.linksoap/share');
  static ShareTransformer? _transformer;

  static void addTransformer(ShareTransformer transformer) {
    _transformer = transformer;
  }

  static Future<void> init() async {
    _channel.setMethodCallHandler((call) async {
      _logger.info('Received method call: ${call.method}');
      if (call.method == 'processSharedText') {
        final String? sharedText = call.arguments as String?;
        _logger.info('Processing shared text: $sharedText');
        if (sharedText != null && sharedText.isNotEmpty) {
          final cleaned = _transformer?.call(sharedText) ?? sharedText;
          _logger.info('Cleaned text: $cleaned');
          return cleaned;
        }
        return '';
      }
      return null;
    });
  }
}
