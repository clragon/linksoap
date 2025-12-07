import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linksoap/app/clipboard_setup.dart';
import 'package:linksoap/app/share_setup.dart';
import 'package:linksoap/core/logging.dart';
import 'package:linksoap/core/storage.dart';
import 'package:linksoap/home/page.dart';
import 'package:linksoap/share_entry.dart';
import 'package:linksoap/window/tray.dart';
import 'package:linksoap/window/setup.dart';
import 'package:linksoap/window/frame.dart';

late Storage storage;

Future<void> main(List<String> arguments) async {
  WidgetsFlutterBinding.ensureInitialized();

  await ensureSingleInstance(arguments);

  setupLogging();

  storage = await Storage.init();

  await setupShare(storage);

  if (Platform.isAndroid) {
    final handle = PluginUtilities.getCallbackHandle(shareEntryPoint);
    if (handle != null) {
      const channel = MethodChannel('net.clynamic.linksoap/share');
      await channel.invokeMethod(
          'registerCallbackHandle', handle.toRawHandle());
    }
  }

  await setupWindow(
    visible: storage.isWindowVisible(),
    onVisibilityChange: (visible) => storage.setWindowVisible(visible),
  );

  await setupSystemTray();

  await setupClipboard(storage);

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
