import 'package:window_manager/window_manager.dart';

Future<void> setupWindow({required bool visible}) async {
  WindowManager windowManager = WindowManager.instance;

  await windowManager.ensureInitialized();
  await windowManager.setTitleBarStyle(TitleBarStyle.hidden);

  windowManager.setPreventClose(true);
  windowManager.addListener(_HideWindowListener(windowManager));

  if (!visible) {
    await windowManager.hide();
  }
}

class _HideWindowListener extends WindowListener {
  _HideWindowListener(this.manager);

  WindowManager manager;

  @override
  void onWindowMinimize() => manager.hide();

  @override
  void onWindowClose() => manager.hide();
}
