import 'dart:io';
import 'package:linksoap/core/share.dart';
import 'package:linksoap/core/storage.dart';
import 'package:linksoap/app/wash_helper.dart';

Future<void> setupShare(Storage storage) async {
  if (!Platform.isAndroid) return;

  ShareHandler.addTransformer((data) {
    return processText(data, storage);
  });

  await ShareHandler.init();
}
