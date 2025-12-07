import 'package:flutter/widgets.dart';
import 'package:linksoap/core/laundromat.dart';
import 'package:linksoap/core/logging.dart';
import 'package:linksoap/core/storage.dart';
import 'package:linksoap/app/wash_helper.dart';

@pragma('vm:entry-point')
Future<void> backgroundEntryPoint() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupLogging();

  final storage = await Storage.init();

  Laundromat.instance.addTransformer((data) => processText(data, storage));

  await Laundromat.instance.setup();
}
