import 'dart:io';
import 'package:linksoap/window/platform.dart';
import 'package:window_manager/window_manager.dart';
import 'package:windows_single_instance/windows_single_instance.dart';

const String _kSingleInstanceIdentifier =
    "linksoap_067f5bd1_29aa_444e_9b46_78120639b0a2";

Future<void> ensureSingleInstance(List<String> arguments) async {
  if (!Platform.isWindows) return;

  await WindowsSingleInstance.ensureSingleInstance(
      arguments, _kSingleInstanceIdentifier, onSecondWindow: (args) async {
    await windowManager.show();
    await windowManager.focus();
  });
}

Future<void> setupWindow({
  required bool visible,
  required Function(bool visible) onVisibilityChange,
}) async {
  if (!isDesktop()) return;

  WindowManager windowManager = WindowManager.instance;

  await windowManager.ensureInitialized();

  windowManager.setPreventClose(true);
  windowManager
      .addListener(_HideWindowListener(windowManager, onVisibilityChange));

  WindowOptions windowOptions = const WindowOptions(
    titleBarStyle: TitleBarStyle.hidden,
  );

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
