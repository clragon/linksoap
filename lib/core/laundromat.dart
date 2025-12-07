import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:linksoap/core/background_entry.dart';

typedef TextTransformer = String Function(String data);
typedef TextListener = void Function();

class Laundromat {
  Laundromat._();

  static final Laundromat _instance = Laundromat._();
  static Laundromat get instance => _instance;

  static const _channel = MethodChannel('net.clynamic.linksoap/laundromat');

  final List<TextTransformer> _transformers = [];
  final List<TextListener> _listeners = [];

  void addTransformer(TextTransformer transformer) =>
      _transformers.add(transformer);

  void removeTransformer(TextTransformer transformer) =>
      _transformers.remove(transformer);

  void addListener(TextListener listener) => _listeners.add(listener);

  void removeListener(TextListener listener) => _listeners.remove(listener);

  String _processText(String text) {
    String result = text;
    for (final transformer in _transformers) {
      result = transformer(result);
    }
    return result;
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  Future<bool> isSetupBoot() async {
    if (!Platform.isAndroid) return false;
    try {
      final result = await _channel.invokeMethod<bool>('isSetupBoot');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> setup() async {
    _channel.setMethodCallHandler((call) async {
      if (call.method == "processText") {
        String content = call.arguments as String;
        final cleaned = _processText(content);
        _notifyListeners();
        return cleaned;
      }
      return null;
    });

    final config = <String, dynamic>{};
    if (Platform.isAndroid) {
      final handle = PluginUtilities.getCallbackHandle(backgroundEntryPoint);
      if (handle != null) {
        config['callbackHandle'] = handle.toRawHandle();
      }
    }

    await _channel.invokeMethod('setupNativeChannel', config);
  }
}
