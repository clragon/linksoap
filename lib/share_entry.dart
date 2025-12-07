import 'package:flutter/widgets.dart';
import 'package:linksoap/core/logging.dart';
import 'package:linksoap/core/storage.dart';
import 'package:linksoap/app/share_setup.dart';

@pragma('vm:entry-point')
Future<void> shareEntryPoint() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupLogging();

  final storage = await Storage.init();

  await setupShare(storage);
}
