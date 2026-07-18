import 'package:flutter/material.dart';

import 'ortha_responsive.dart';

class OrthaAdaptiveLayout extends StatelessWidget {
  final List<Widget> children;

  const OrthaAdaptiveLayout({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    final ui = OrthaResponsive.of(context);

    if (ui.preferredColumnCount <= 1 || children.length == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index < children.length - 1) SizedBox(height: ui.cardSpacing),
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = ui.preferredColumnCount > children.length
            ? children.length
            : ui.preferredColumnCount;

        final availableWidth =
            constraints.maxWidth - ui.cardSpacing * (columnCount - 1);

        final childWidth = availableWidth / columnCount;

        return Wrap(
          spacing: ui.cardSpacing,
          runSpacing: ui.cardSpacing,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            for (final child in children)
              SizedBox(width: childWidth, child: child),
          ],
        );
      },
    );
  }
}
