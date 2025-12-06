import 'package:flutter/services.dart';

typedef ClipboardTransformer = String Function(String clipboardContent);
typedef ClipboardListener = void Function();

class ClipboardManager {
  ClipboardManager._();

  static final ClipboardManager _instance = ClipboardManager._();

  static ClipboardManager get instance => _instance;

  static const MethodChannel _channel = MethodChannel('clipboard_manager');

  final List<ClipboardTransformer> _transformers = [];
  final List<ClipboardListener> _listeners = [];

  Future<void> init() async {
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == "onClipboardChanged") {
        String content = call.arguments as String;
        for (final transformer in _transformers) {
          content = transformer(content);
        }
        for (final listener in _listeners) {
          listener();
        }
        return content;
      }
      return null;
    });

    await _channel.invokeMethod("initClipboardListener");
  }

  void addTransformer(ClipboardTransformer transformer) =>
      _transformers.add(transformer);

  void removeTransformer(ClipboardTransformer transformer) =>
      _transformers.remove(transformer);

  void addListener(ClipboardListener listener) => _listeners.add(listener);

  void removeListener(ClipboardListener listener) =>
      _listeners.remove(listener);
}
