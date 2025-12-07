import 'dart:io';
import 'package:linksoap/window/platform.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

Future<void> setupSystemTray() async {
  if (!isDesktop()) return;

  WindowManager windowManager = WindowManager.instance;
  await windowManager.ensureInitialized();

  String iconPath =
      Platform.isWindows ? 'assets/icon/icon.ico' : 'assets/icon/icon.png';

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
        onClicked: (item) => windowManager.hide(),
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
    }
    if (event == kSystemTrayEventRightClick) {
      tray.popUpContextMenu();
    }
  });
}
