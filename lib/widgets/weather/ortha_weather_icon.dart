import 'package:flutter/material.dart';

/// Fachlich normalisierte Wetterzustände für die ORTHA-Icon-Darstellung.
enum OrthaWeatherCondition {
  clear,
  partlyCloudy,
  cloudy,
  fog,
  drizzle,
  rain,
  snow,
  shower,
  thunderstorm,
  unknown,
}

/// Zentrale Zuordnung von WMO-Wettercodes zu ORTHA-Wetterzuständen.
abstract final class OrthaWeatherCodeMapper {
  static OrthaWeatherCondition fromWmoCode(int weatherCode) {
    return switch (weatherCode) {
      0 => OrthaWeatherCondition.clear,
      1 || 2 => OrthaWeatherCondition.partlyCloudy,
      3 => OrthaWeatherCondition.cloudy,
      45 || 48 => OrthaWeatherCondition.fog,
      51 || 53 || 55 || 56 || 57 => OrthaWeatherCondition.drizzle,
      61 || 63 || 65 || 66 || 67 => OrthaWeatherCondition.rain,
      71 || 73 || 75 || 77 => OrthaWeatherCondition.snow,
      80 || 81 || 82 || 85 || 86 => OrthaWeatherCondition.shower,
      95 || 96 || 99 => OrthaWeatherCondition.thunderstorm,
      _ => OrthaWeatherCondition.unknown,
    };
  }
}

/// Skalierbares Wettericon mit einer dezenten Semi-3D-Grunddarstellung.
///
/// Die Komponente verwendet vorerst Flutter-Materialsymbole. Schatten,
/// Farbverlauf und Glanzfläche bilden die technische Grundlage für die
/// spätere eigenständige ORTHA-Symbolsprache.
class OrthaWeatherIcon extends StatelessWidget {
  const OrthaWeatherIcon({
    super.key,
    required this.weatherCode,
    this.size = 64,
    this.isNight = false,
    this.semanticLabel,
  });

  final int weatherCode;
  final double size;
  final bool isNight;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final condition = OrthaWeatherCodeMapper.fromWmoCode(weatherCode);
    final style = _styleFor(condition);

    return Semantics(
      image: true,
      label: semanticLabel ?? _descriptionFor(condition),
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: const Alignment(-0.35, -0.4),
              radius: 0.95,
              colors: <Color>[
                Color.lerp(style.highlight, Colors.black, 0.05)!,
                Color.lerp(style.base, Colors.black, 0.05)!,
                Color.lerp(style.shadow, Colors.black, 0.05)!,
              ],
              stops: const <double>[0, 0.58, 1],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: size * 0.018,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: size * 0.16,
                offset: Offset(0, size * 0.09),
              ),
              BoxShadow(
                color: style.base.withValues(alpha: 0.2),
                blurRadius: size * 0.12,
                spreadRadius: size * 0.015,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Icon(style.icon, size: size * 0.55, color: style.iconColor),
              Positioned(
                top: size * 0.13,
                left: size * 0.22,
                child: Container(
                  width: size * 0.28,
                  height: size * 0.11,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(size),
                    gradient: LinearGradient(
                      colors: <Color>[
                        Colors.white.withValues(alpha: 0.42),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              if (isNight)
                Positioned(
                  right: size * 0.11,
                  top: size * 0.11,
                  child: Icon(
                    Icons.nightlight_round,
                    size: size * 0.24,
                    color: const Color(0xFFEAF1FF),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static _OrthaWeatherIconStyle _styleFor(OrthaWeatherCondition condition) {
    return switch (condition) {
      OrthaWeatherCondition.clear => const _OrthaWeatherIconStyle(
        icon: Icons.wb_sunny_rounded,
        highlight: Color(0xFFFFF2A6),
        base: Color(0xFFFFC940),
        shadow: Color(0xFFCF7A00),
        iconColor: Color(0xFFFFF8D5),
      ),
      OrthaWeatherCondition.partlyCloudy => const _OrthaWeatherIconStyle(
        icon: Icons.wb_cloudy_rounded,
        highlight: Color(0xFFDFF3FF),
        base: Color(0xFF79BFE8),
        shadow: Color(0xFF315D83),
        iconColor: Color(0xFFF2F2F2),
      ),
      OrthaWeatherCondition.cloudy => const _OrthaWeatherIconStyle(
        icon: Icons.cloud_rounded,
        highlight: Color(0xFFE5EDF4),
        base: Color(0xFF90A4B7),
        shadow: Color(0xFF46596C),
        iconColor: Color(0xFFF2F2F2),
      ),
      OrthaWeatherCondition.fog => const _OrthaWeatherIconStyle(
        icon: Icons.blur_on_rounded,
        highlight: Color(0xFFE8F0F2),
        base: Color(0xFFA7BAC0),
        shadow: Color(0xFF52666D),
        iconColor: Color(0xFFF2F2F2),
      ),
      OrthaWeatherCondition.drizzle => const _OrthaWeatherIconStyle(
        icon: Icons.grain_rounded,
        highlight: Color(0xFFD9F2FF),
        base: Color(0xFF5FA8D3),
        shadow: Color(0xFF245578),
        iconColor: Color(0xFFF2F2F2),
      ),
      OrthaWeatherCondition.rain => const _OrthaWeatherIconStyle(
        icon: Icons.water_drop_rounded,
        highlight: Color(0xFFCBEAFF),
        base: Color(0xFF3389C8),
        shadow: Color(0xFF17436A),
        iconColor: Color(0xFFF2F2F2),
      ),
      OrthaWeatherCondition.snow => const _OrthaWeatherIconStyle(
        icon: Icons.ac_unit_rounded,
        highlight: Color(0xFFF2F2F2),
        base: Color(0xFFB8DDF2),
        shadow: Color(0xFF628CA8),
        iconColor: Color(0xFFF2F2F2),
      ),
      OrthaWeatherCondition.shower => const _OrthaWeatherIconStyle(
        icon: Icons.shower_rounded,
        highlight: Color(0xFFCDEEFF),
        base: Color(0xFF4B9AC8),
        shadow: Color(0xFF1F4F70),
        iconColor: Color(0xFFF2F2F2),
      ),
      OrthaWeatherCondition.thunderstorm => const _OrthaWeatherIconStyle(
        icon: Icons.thunderstorm_rounded,
        highlight: Color(0xFFE9E1FF),
        base: Color(0xFF7257B5),
        shadow: Color(0xFF31205F),
        iconColor: Color(0xFFFFE56B),
      ),
      OrthaWeatherCondition.unknown => const _OrthaWeatherIconStyle(
        icon: Icons.question_mark_rounded,
        highlight: Color(0xFFE2E8EE),
        base: Color(0xFF778899),
        shadow: Color(0xFF354452),
        iconColor: Color(0xFFF2F2F2),
      ),
    };
  }

  static String _descriptionFor(OrthaWeatherCondition condition) {
    return switch (condition) {
      OrthaWeatherCondition.clear => 'Klar',
      OrthaWeatherCondition.partlyCloudy => 'Teilweise bewölkt',
      OrthaWeatherCondition.cloudy => 'Bewölkt',
      OrthaWeatherCondition.fog => 'Nebel',
      OrthaWeatherCondition.drizzle => 'Nieselregen',
      OrthaWeatherCondition.rain => 'Regen',
      OrthaWeatherCondition.snow => 'Schnee',
      OrthaWeatherCondition.shower => 'Schauer',
      OrthaWeatherCondition.thunderstorm => 'Gewitter',
      OrthaWeatherCondition.unknown => 'Unbekannter Wetterzustand',
    };
  }
}

class _OrthaWeatherIconStyle {
  const _OrthaWeatherIconStyle({
    required this.icon,
    required this.highlight,
    required this.base,
    required this.shadow,
    required this.iconColor,
  });

  final IconData icon;
  final Color highlight;
  final Color base;
  final Color shadow;
  final Color iconColor;
}
