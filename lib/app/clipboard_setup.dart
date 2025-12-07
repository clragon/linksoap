import 'dart:io';
import 'package:linksoap/core/clipboard.dart';
import 'package:linksoap/core/storage.dart';
import 'package:linksoap/app/wash_helper.dart';

Future<void> setupClipboard(Storage storage) async {
  if (Platform.isAndroid) return;

  await ClipboardManager.instance.init();

  ClipboardManager.instance.addTransformer((data) {
    return processText(data, storage);
  });
}
