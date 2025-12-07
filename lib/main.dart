import 'package:flutter/material.dart';
import 'package:linksoap/core/logging.dart';
import 'package:linksoap/core/laundromat.dart';
import 'package:linksoap/core/storage.dart';
import 'package:linksoap/home/page.dart';
import 'package:linksoap/app/wash_helper.dart';
import 'package:linksoap/window/tray.dart';
import 'package:linksoap/window/setup.dart';
import 'package:linksoap/window/frame.dart';

late Storage storage;

Future<void> main(List<String> arguments) async {
  WidgetsFlutterBinding.ensureInitialized();

  await ensureSingleInstance(arguments);

  setupLogging();

  storage = await Storage.init();

  Laundromat.instance.addTransformer((data) => processText(data, storage));

  await Laundromat.instance.setup();

  await setupWindow(
    visible: storage.isWindowVisible(),
    onVisibilityChange: (visible) => storage.setWindowVisible(visible),
  );

  await setupSystemTray();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LinkSoap',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return WindowFrame(child: child ?? const SizedBox.shrink());
      },
      home: HomePage(storage: storage),
    );
  }
}
