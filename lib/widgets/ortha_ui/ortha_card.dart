import 'package:flutter/material.dart';

import '../../theme/ortha_colors.dart';
import 'ortha_responsive.dart';

class OrthaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color backgroundColor;
  final double? borderRadius;
  final bool elevated;

  const OrthaCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor = OrthaColors.surface,
    this.borderRadius,
    this.elevated = true,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = OrthaResponsive.of(context);

    final effectivePadding = padding ?? EdgeInsets.all(responsive.cardPadding);
    final effectiveBorderRadius = borderRadius ?? responsive.cardRadius;

    return Container(
      width: double.infinity,
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        border: Border.all(color: OrthaColors.border),
        boxShadow: elevated
            ? const [
                BoxShadow(
                  color: OrthaColors.shadow,
                  blurRadius: 28,
                  offset: Offset(0, 14),
                ),
              ]
            : const [],
      ),
      child: child,
    );
  }
}
