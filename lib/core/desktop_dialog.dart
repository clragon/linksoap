import 'package:flutter/material.dart';

Future<T?> showDesktopDialog<T>({
  required BuildContext context,
  required Widget child,
  double maxWidth = 800,
}) =>
    Navigator.push<T>(
      context,
      DialogRoute(
        context: context,
        builder: (context) => DesktopDialog(
          maxWidth: maxWidth,
          child: child,
        ),
        fullscreenDialog: true,
        useSafeArea: false,
      ),
    );

class DesktopDialog extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const DesktopDialog({
    super.key,
    required this.child,
    this.maxWidth = 800,
  });

  static const double breakpoint = 800;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > breakpoint;

        if (!isDesktop) {
          return child;
        }

        return SafeArea(
          minimum: const EdgeInsets.all(48),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
              ),
              child: Material(
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(12),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
