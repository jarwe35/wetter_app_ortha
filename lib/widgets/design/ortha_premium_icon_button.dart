import 'package:flutter/material.dart';
import 'package:wetter_app_ortha/theme/ortha_design_system.dart';

class OrthaPremiumIconButton extends StatelessWidget {
  const OrthaPremiumIconButton({
    required this.icon,
    required this.onPressed,
    super.key,
    this.selected = false,
    this.size = 72,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool selected;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final Color accent = selected
        ? OrthaColors.gold
        : OrthaColors.textSecondary;

    final Widget button = SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(OrthaRadii.medium),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              selected ? const Color(0x5CFFB536) : const Color(0xCC182936),
              const Color(0xD108151F),
            ],
          ),
          border: Border.all(
            color: selected ? OrthaColors.borderGold : OrthaColors.borderSoft,
            width: selected ? 1.2 : 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? OrthaColors.gold.withAlpha(40)
                  : Colors.black.withAlpha(58),
              blurRadius: selected ? 24 : 18,
              spreadRadius: selected ? -5 : -8,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(OrthaRadii.medium),
            child: Center(
              child: Icon(icon, color: accent, size: size * 0.43),
            ),
          ),
        ),
      ),
    );

    if (tooltip == null || tooltip!.trim().isEmpty) {
      return button;
    }

    return Tooltip(message: tooltip!, child: button);
  }
}
