import 'package:flutter/material.dart';

import '../../design/ortha_light_engine.dart';

/// Einheitliche, klar erkennbare Wetterzustände für ORTHA METEO Ω.
enum OrthaWeatherCondition {
  clear,
  mainlyClear,
  partlyCloudy,
  cloudy,
  fog,
  drizzle,
  freezingDrizzle,
  rain,
  freezingRain,
  snow,
  snowGrains,
  rainShower,
  snowShower,
  thunderstorm,
  thunderstormWithHail,
  unknown,
}

/// Ordnet die Wettercodes von Open-Meteo nach dem WMO-Standard zu.
abstract final class OrthaWeatherCodeMapper {
  static OrthaWeatherCondition fromWmoCode(int? weatherCode) {
    return switch (weatherCode) {
      0 => OrthaWeatherCondition.clear,
      1 => OrthaWeatherCondition.mainlyClear,
      2 => OrthaWeatherCondition.partlyCloudy,
      3 => OrthaWeatherCondition.cloudy,
      45 || 48 => OrthaWeatherCondition.fog,
      51 || 53 || 55 => OrthaWeatherCondition.drizzle,
      56 || 57 => OrthaWeatherCondition.freezingDrizzle,
      61 || 63 || 65 => OrthaWeatherCondition.rain,
      66 || 67 => OrthaWeatherCondition.freezingRain,
      71 || 73 || 75 => OrthaWeatherCondition.snow,
      77 => OrthaWeatherCondition.snowGrains,
      80 || 81 || 82 => OrthaWeatherCondition.rainShower,
      85 || 86 => OrthaWeatherCondition.snowShower,
      95 => OrthaWeatherCondition.thunderstorm,
      96 || 99 => OrthaWeatherCondition.thunderstormWithHail,
      _ => OrthaWeatherCondition.unknown,
    };
  }
}

/// Abwärtskompatible Hilfsfunktion für bestehende Aufrufe und Tests.
OrthaWeatherCondition orthaConditionFromWmoCode(int? weatherCode) {
  return OrthaWeatherCodeMapper.fromWmoCode(weatherCode);
}

/// Klares und skalierbares ORTHA-Wettersymbol.
///
/// Die Komponente verwendet bewusst eindeutig erkennbare Material-Symbole,
/// statt mehrdeutiger, übereinandergelegter Symbolkonstruktionen.
class OrthaWeatherIcon extends StatelessWidget {
  const OrthaWeatherIcon({
    super.key,
    this.weatherCode,
    this.condition,
    this.isNight = false,
    this.size = 48,
    this.semanticLabel,
  }) : assert(
         weatherCode != null || condition != null,
         'Entweder weatherCode oder condition muss angegeben werden.',
       );

  factory OrthaWeatherIcon.fromWmoCode({
    Key? key,
    required int? weatherCode,
    bool isNight = false,
    double size = 48,
    String? semanticLabel,
  }) {
    return OrthaWeatherIcon(
      key: key,
      weatherCode: weatherCode,
      isNight: isNight,
      size: size,
      semanticLabel: semanticLabel,
    );
  }

  final int? weatherCode;
  final OrthaWeatherCondition? condition;
  final bool isNight;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final resolvedCondition =
        condition ?? OrthaWeatherCodeMapper.fromWmoCode(weatherCode);
    final style = _styleFor(resolvedCondition, isNight: isNight);

    final icon = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: style.backgroundColors,
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.32),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: style.shadowColor.withValues(
              alpha: OrthaLightEngine.normal.outerOpacity,
            ),
            blurRadius: OrthaLightEngine.normal.outerBlur,
            spreadRadius: -size * 0.10,
          ),
          BoxShadow(
            color: style.shadowColor.withValues(
              alpha: OrthaLightEngine.normal.middleOpacity * 0.55,
            ),
            blurRadius: OrthaLightEngine.normal.middleBlur,
            spreadRadius: -size * 0.14,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.32),
            blurRadius: size * 0.18,
            offset: Offset(0, size * 0.07),
          ),
        ],
      ),
      child: Icon(
        style.icon,
        size: size * 0.57,
        color: style.iconColor,
        shadows: [
          Shadow(
            color: style.shadowColor.withValues(
              alpha: OrthaLightEngine.normal.coreOpacity,
            ),
            blurRadius: OrthaLightEngine.normal.coreBlur,
          ),
          Shadow(
            color: Colors.white.withValues(alpha: 0.24),
            blurRadius: 2.2,
            offset: const Offset(0, -0.8),
          ),
        ],
      ),
    );

    if (semanticLabel == null || semanticLabel!.trim().isEmpty) {
      return ExcludeSemantics(child: icon);
    }

    return Semantics(
      label: semanticLabel,
      image: true,
      child: ExcludeSemantics(child: icon),
    );
  }

  static _OrthaWeatherIconStyle _styleFor(
    OrthaWeatherCondition condition, {
    required bool isNight,
  }) {
    if (isNight) {
      return _nightStyle(condition);
    }

    return switch (condition) {
      OrthaWeatherCondition.clear => const _OrthaWeatherIconStyle(
        icon: Icons.wb_sunny_rounded,
        iconColor: Color(0xFFFFD45A),
        backgroundColors: [Color(0xFF4E93C8), Color(0xFF17649E)],
        shadowColor: Color(0xFFFFD45A),
      ),
      OrthaWeatherCondition.mainlyClear => const _OrthaWeatherIconStyle(
        icon: Icons.wb_sunny_outlined,
        iconColor: Color(0xFFFFD45A),
        backgroundColors: [Color(0xFF69B7E5), Color(0xFF287AAE)],
        shadowColor: Color(0xFFFFD45A),
      ),
      OrthaWeatherCondition.partlyCloudy => const _OrthaWeatherIconStyle(
        icon: Icons.wb_cloudy_rounded,
        iconColor: Colors.white,
        backgroundColors: [Color(0xFF76B9DD), Color(0xFF397AAB)],
        shadowColor: Color(0xFF5A94BC),
      ),
      OrthaWeatherCondition.cloudy => const _OrthaWeatherIconStyle(
        icon: Icons.cloud_rounded,
        iconColor: Colors.white,
        backgroundColors: [Color(0xFF9EB3C4), Color(0xFF60788E)],
        shadowColor: Color(0xFF60788E),
      ),
      OrthaWeatherCondition.fog => const _OrthaWeatherIconStyle(
        icon: Icons.foggy,
        iconColor: Colors.white,
        backgroundColors: [Color(0xFFAEB9C2), Color(0xFF6E7C89)],
        shadowColor: Color(0xFF6E7C89),
      ),
      OrthaWeatherCondition.drizzle => const _OrthaWeatherIconStyle(
        icon: Icons.cloudy_snowing,
        iconColor: Colors.white,
        backgroundColors: [Color(0xFF61B6D8), Color(0xFF287DA8)],
        shadowColor: Color(0xFF287DA8),
      ),
      OrthaWeatherCondition.freezingDrizzle => const _OrthaWeatherIconStyle(
        icon: Icons.severe_cold_rounded,
        iconColor: Colors.white,
        backgroundColors: [Color(0xFF78C7DF), Color(0xFF327FA5)],
        shadowColor: Color(0xFF327FA5),
      ),
      OrthaWeatherCondition.rain => const _OrthaWeatherIconStyle(
        icon: Icons.water_drop_rounded,
        iconColor: Color(0xFFDDF5FF),
        backgroundColors: [Color(0xFF398BB8), Color(0xFF174E78)],
        shadowColor: Color(0xFF174E78),
      ),
      OrthaWeatherCondition.freezingRain => const _OrthaWeatherIconStyle(
        icon: Icons.ac_unit_rounded,
        iconColor: Colors.white,
        backgroundColors: [Color(0xFF549FBE), Color(0xFF244F73)],
        shadowColor: Color(0xFF244F73),
      ),
      OrthaWeatherCondition.snow ||
      OrthaWeatherCondition.snowGrains ||
      OrthaWeatherCondition.snowShower => const _OrthaWeatherIconStyle(
        icon: Icons.ac_unit_rounded,
        iconColor: Colors.white,
        backgroundColors: [Color(0xFF65B8DB), Color(0xFF367CA4)],
        shadowColor: Color(0xFF367CA4),
      ),
      OrthaWeatherCondition.rainShower => const _OrthaWeatherIconStyle(
        icon: Icons.umbrella_rounded,
        iconColor: Colors.white,
        backgroundColors: [Color(0xFF438EB7), Color(0xFF234E73)],
        shadowColor: Color(0xFF234E73),
      ),
      OrthaWeatherCondition.thunderstorm ||
      OrthaWeatherCondition.thunderstormWithHail =>
        const _OrthaWeatherIconStyle(
          icon: Icons.thunderstorm_rounded,
          iconColor: Color(0xFFFFD45A),
          backgroundColors: [Color(0xFF5D6678), Color(0xFF252D3B)],
          shadowColor: Color(0xFFFFD45A),
        ),
      OrthaWeatherCondition.unknown => const _OrthaWeatherIconStyle(
        icon: Icons.help_outline_rounded,
        iconColor: Colors.white,
        backgroundColors: [Color(0xFF8495A4), Color(0xFF526271)],
        shadowColor: Color(0xFF526271),
      ),
    };
  }

  static _OrthaWeatherIconStyle _nightStyle(OrthaWeatherCondition condition) {
    return switch (condition) {
      OrthaWeatherCondition.clear ||
      OrthaWeatherCondition.mainlyClear => const _OrthaWeatherIconStyle(
        icon: Icons.nightlight_round,
        iconColor: Color(0xFFFFE8A3),
        backgroundColors: [Color(0xFF344A70), Color(0xFF101B35)],
        shadowColor: Color(0xFFFFE8A3),
      ),
      OrthaWeatherCondition.partlyCloudy ||
      OrthaWeatherCondition.cloudy => const _OrthaWeatherIconStyle(
        icon: Icons.cloud_rounded,
        iconColor: Colors.white,
        backgroundColors: [Color(0xFF4D6584), Color(0xFF1D2E49)],
        shadowColor: Color(0xFF334C6D),
      ),
      OrthaWeatherCondition.fog => const _OrthaWeatherIconStyle(
        icon: Icons.foggy,
        iconColor: Colors.white,
        backgroundColors: [Color(0xFF59697A), Color(0xFF253448)],
        shadowColor: Color(0xFF253448),
      ),
      OrthaWeatherCondition.drizzle ||
      OrthaWeatherCondition.freezingDrizzle ||
      OrthaWeatherCondition.rain ||
      OrthaWeatherCondition.freezingRain ||
      OrthaWeatherCondition.rainShower => const _OrthaWeatherIconStyle(
        icon: Icons.water_drop_rounded,
        iconColor: Color(0xFFDDF5FF),
        backgroundColors: [Color(0xFF315B7D), Color(0xFF152A46)],
        shadowColor: Color(0xFF152A46),
      ),
      OrthaWeatherCondition.snow ||
      OrthaWeatherCondition.snowGrains ||
      OrthaWeatherCondition.snowShower => const _OrthaWeatherIconStyle(
        icon: Icons.ac_unit_rounded,
        iconColor: Colors.white,
        backgroundColors: [Color(0xFF456B8D), Color(0xFF1A304D)],
        shadowColor: Color(0xFF1A304D),
      ),
      OrthaWeatherCondition.thunderstorm ||
      OrthaWeatherCondition.thunderstormWithHail =>
        const _OrthaWeatherIconStyle(
          icon: Icons.thunderstorm_rounded,
          iconColor: Color(0xFFFFD45A),
          backgroundColors: [Color(0xFF43495C), Color(0xFF171C2A)],
          shadowColor: Color(0xFFFFD45A),
        ),
      OrthaWeatherCondition.unknown => const _OrthaWeatherIconStyle(
        icon: Icons.help_outline_rounded,
        iconColor: Colors.white,
        backgroundColors: [Color(0xFF4E6074), Color(0xFF233247)],
        shadowColor: Color(0xFF233247),
      ),
    };
  }
}

class _OrthaWeatherIconStyle {
  const _OrthaWeatherIconStyle({
    required this.icon,
    required this.iconColor,
    required this.backgroundColors,
    required this.shadowColor,
  });

  final IconData icon;
  final Color iconColor;
  final List<Color> backgroundColors;
  final Color shadowColor;
}
