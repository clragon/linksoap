import 'package:flutter/material.dart';

class DesktopDialog extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const DesktopDialog({
    super.key,
    required this.child,
    this.maxWidth = 600,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;

        if (!isDesktop) {
          return child;
        }

        return Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
            ),
            margin: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
