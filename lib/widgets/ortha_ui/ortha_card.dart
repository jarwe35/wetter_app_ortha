import 'package:flutter/material.dart';

class OrthaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color backgroundColor;
  final double borderRadius;
  final bool elevated;

  const OrthaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.backgroundColor = Colors.white,
    this.borderRadius = 28,
    this.elevated = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: const Color(0xFFD3E2EC)),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ]
            : [],
      ),
      child: child,
    );
  }
}
