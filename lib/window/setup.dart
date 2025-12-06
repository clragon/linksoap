import 'package:window_manager/window_manager.dart';

Future<void> setupWindow({
  required bool visible,
  required Function(bool visible) onVisibilityChange,
}) async {
  WindowManager windowManager = WindowManager.instance;

  await windowManager.ensureInitialized();

  windowManager.setPreventClose(true);
  windowManager
      .addListener(_HideWindowListener(windowManager, onVisibilityChange));

  WindowOptions windowOptions = const WindowOptions(
    titleBarStyle: TitleBarStyle.hidden,
  );

  // Requires native modifications: https://leanflutter.dev/documentation/window_manager/quick-start#hidden-at-launch
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    if (visible) {
      await windowManager.show();
      await windowManager.focus();
    }
  });
}

class _HideWindowListener extends WindowListener {
  _HideWindowListener(this.manager, this.onVisibilityChange);

  WindowManager manager;
  Function(bool visible) onVisibilityChange;

  @override
  void onWindowMinimize() async {
    await manager.hide();
    onVisibilityChange(false);
  }

  @override
  void onWindowClose() async {
    await manager.hide();
    onVisibilityChange(false);
  }

  @override
  void onWindowRestore() {
    onVisibilityChange(true);
  }

  @override
  void onWindowFocus() {
    onVisibilityChange(true);
  }
}
