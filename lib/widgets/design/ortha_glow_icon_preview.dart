import 'package:flutter/material.dart';

import '../../design/ortha_light_engine.dart';
import 'ortha_glow_icon.dart';

class OrthaGlowIconPreview extends StatelessWidget {
  const OrthaGlowIconPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OrthaGlowIcon(
          icon: Icons.home_outlined,
          style: OrthaGlowIconStyle.gold,
          glow: OrthaLightEngine.hero,
          size: 30,
        ),
        SizedBox(width: 8),
        OrthaGlowIcon(
          icon: Icons.cloud_outlined,
          style: OrthaGlowIconStyle.white,
          glow: OrthaLightEngine.strong,
          size: 30,
        ),
        SizedBox(width: 8),
        OrthaGlowIcon(
          icon: Icons.radar,
          style: OrthaGlowIconStyle.silver,
          glow: OrthaLightEngine.subtle,
          size: 28,
        ),
      ],
    );
  }
}
