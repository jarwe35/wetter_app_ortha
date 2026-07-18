import 'package:flutter/material.dart';

import 'ortha_responsive.dart';

class OrthaAdaptiveLayout extends StatelessWidget {
  final List<Widget> children;

  const OrthaAdaptiveLayout({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final ui = OrthaResponsive.of(context);

    if (ui.preferredColumnCount <= 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: children.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ui.preferredColumnCount,
        crossAxisSpacing: ui.cardSpacing,
        mainAxisSpacing: ui.cardSpacing,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, index) => children[index],
    );
  }
}
