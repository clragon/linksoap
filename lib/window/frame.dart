import 'package:flutter/material.dart';
import 'package:linksoap/window/platform.dart';
import 'package:window_manager/window_manager.dart';

class WindowFrame extends StatefulWidget {
  final Widget child;

  const WindowFrame({super.key, required this.child});

  @override
  State<WindowFrame> createState() => _WindowFrameState();
}

class _WindowFrameState extends State<WindowFrame> with WindowListener {
  bool isFullscreen = false;
  bool isFocused = false;
  bool isMaximized = false;
  final bool desktop = isDesktop();

  @override
  void initState() {
    super.initState();
    if (desktop) {
      windowManager.addListener(this);
      _checkWindowState();
    }
  }

  Future<void> _checkWindowState() async {
    if (!desktop) return;
    isFullscreen = await windowManager.isFullScreen();
    isFocused = await windowManager.isFocused();
    isMaximized = await windowManager.isMaximized();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    if (desktop) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  @override
  void onWindowEnterFullScreen() => setState(() => isFullscreen = true);

  @override
  void onWindowLeaveFullScreen() => setState(() => isFullscreen = false);

  @override
  void onWindowFocus() => setState(() => isFocused = true);

  @override
  void onWindowBlur() => setState(() => isFocused = false);

  @override
  void onWindowRestore() => setState(() => isFocused = true);

  @override
  void onWindowMaximize() => setState(() => isMaximized = true);

  @override
  void onWindowUnmaximize() => setState(() => isMaximized = false);

  @override
  Widget build(BuildContext context) {
    if (!desktop) {
      return widget.child;
    }

    return Column(
      children: [
        if (!isFullscreen)
          Material(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onPanStart: (details) => windowManager.startDragging(),
                    onDoubleTap: () async {
                      if (await windowManager.isMaximized()) {
                        await windowManager.unmaximize();
                      } else {
                        await windowManager.maximize();
                      }
                    },
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 4,
                            bottom: 4,
                            left: 12,
                            right: 8,
                          ),
                          child: Image.asset(
                            'assets/icon.png',
                            width: 18,
                            height: 18,
                          ),
                        ),
                        Expanded(
                          child: AnimatedDefaultTextStyle(
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: isFocused
                                      ? null
                                      : Theme.of(context).disabledColor,
                                ),
                            duration: const Duration(milliseconds: 200),
                            child: const Text('LinkSoap'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    TitleBarButton(
                      color: Colors.green,
                      icon: const Icon(Icons.minimize),
                      onPressed: windowManager.minimize,
                    ),
                    TitleBarButton(
                      color: Colors.orange,
                      icon: isMaximized
                          ? const Icon(Icons.fullscreen_exit)
                          : const Icon(Icons.fullscreen),
                      onPressed: () async {
                        if (await windowManager.isFullScreen()) {
                          await windowManager.setFullScreen(false);
                        } else if (await windowManager.isMaximized()) {
                          await windowManager.unmaximize();
                        } else {
                          await windowManager.maximize();
                        }
                      },
                    ),
                    TitleBarButton(
                      color: Colors.red,
                      icon: const Icon(Icons.close),
                      onPressed: windowManager.close,
                    ),
                  ],
                ),
              ],
            ),
          ),
        Expanded(child: ClipRect(child: widget.child)),
      ],
    );
  }
}

class TitleBarButton extends StatelessWidget {
  final Widget icon;
  final Color? color;
  final VoidCallback? onPressed;

  const TitleBarButton({
    super.key,
    required this.icon,
    this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) => IconButton(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        constraints: const BoxConstraints(),
        hoverColor: color?.withAlpha(180),
        highlightColor: color,
        icon: icon,
        onPressed: onPressed,
        splashRadius: 24,
      );
}
