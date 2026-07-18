import 'package:flutter/material.dart';

import 'ortha_responsive.dart';

class OrthaResponsivePage extends StatelessWidget {
  final Widget child;

  const OrthaResponsivePage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final ui = OrthaResponsive.of(context);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: ui.maxContentWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ui.horizontalPadding,
              vertical: ui.verticalPadding,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
