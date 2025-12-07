import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:linksoap/window/platform.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:window_manager/window_manager.dart';
import 'package:windows_single_instance/windows_single_instance.dart';

const String _kSingleInstanceBaseIdentifier =
    "linksoap_067f5bd1_29aa_444e_9b46_78120639b0a2";

String _buildMode() {
  if (kReleaseMode) return 'release';
  if (kProfileMode) return 'profile';
  return 'debug';
}

Future<String> _getSingleInstanceIdentifier() async {
  final packageInfo = await PackageInfo.fromPlatform();
  final mode = _buildMode();
  final version = packageInfo.version;
  return '${_kSingleInstanceBaseIdentifier}_${mode}_$version';
}

Future<void> ensureSingleInstance(List<String> arguments) async {
  if (!Platform.isWindows) return;

  final identifier = await _getSingleInstanceIdentifier();
  await WindowsSingleInstance.ensureSingleInstance(arguments, identifier,
      onSecondWindow: (args) async {
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
