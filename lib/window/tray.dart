import 'dart:io';

import 'package:linksoap/core/storage.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

Future<void> setupSystemTray(Storage storage) async {
  WindowManager windowManager = WindowManager.instance;
  await windowManager.ensureInitialized();

  String iconPath = Platform.isWindows ? 'assets/icon.ico' : 'assets/icon.png';

  SystemTray tray = SystemTray();
  await tray.initSystemTray(
    iconPath: iconPath,
    toolTip: 'LinkSoap',
  );

  Menu menu = Menu();
  await menu.buildFrom(
    [
      MenuItemLabel(
        label: 'Hide',
        onClicked: (item) async {
          await windowManager.hide();
          await storage.setWindowVisible(false);
        },
      ),
      MenuItemLabel(
        label: 'Exit',
        onClicked: (item) {
          windowManager.setPreventClose(false);
          windowManager.close();
        },
      ),
    ],
  );

  await tray.setContextMenu(menu);

  tray.registerSystemTrayEventHandler((event) async {
    if (event == kSystemTrayEventClick) {
      await windowManager.show();
      await storage.setWindowVisible(true);
    }
    if (event == kSystemTrayEventRightClick) {
      tray.popUpContextMenu();
    }
  });
}
