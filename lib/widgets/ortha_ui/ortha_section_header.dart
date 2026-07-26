import 'package:flutter/material.dart';

class OrthaSectionHeader extends StatelessWidget {
  const OrthaSectionHeader({
    required this.icon,
    required this.title,
    super.key,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  static const Color _gold = Color(0xFFFFB536);
  static const Color _primaryText = Color(0xFFF4F7FA);
  static const Color _secondaryText = Color(0xFFADB9C7);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xE61A2D3C), Color(0xE6091722)],
            ),
            border: Border.all(color: const Color(0x668497A9), width: 0.9),
            boxShadow: const [
              BoxShadow(
                color: Color(0x50000000),
                blurRadius: 20,
                offset: Offset(0, 9),
              ),
              BoxShadow(
                color: Color(0x24FFB536),
                blurRadius: 20,
                spreadRadius: -7,
              ),
            ],
          ),
          child: Icon(icon, color: _gold, size: 27),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 21,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: _primaryText,
                  letterSpacing: -0.25,
                ),
              ),
              if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(
                  subtitle!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.3,
                    fontWeight: FontWeight.w400,
                    color: _secondaryText,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
