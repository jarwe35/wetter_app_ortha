import 'package:flutter/material.dart';

/// Zentrale Designsprache von ORTHA METEO Ω.
///
/// Keine Seite sollte künftig eigene, voneinander abweichende Grundfarben
/// definieren. Farben, Konturen, Schatten und Typografie werden hier
/// zusammengeführt.
abstract final class OrthaColors {
  static const Color background = Color(0xFF020A12);
  static const Color backgroundSoft = Color(0xFF061421);
  static const Color backgroundRaised = Color(0xFF0A1B2A);

  static const Color glass = Color(0xB3142432);
  static const Color glassStrong = Color(0xE6162736);
  static const Color glassSoft = Color(0x8F10202D);

  static const Color gold = Color(0xFFFFB536);
  static const Color goldSoft = Color(0xFFE9C56A);
  static const Color goldMuted = Color(0xFF9B8350);

  static const Color textPrimary = Color(0xFFF5F7FA);
  static const Color textSecondary = Color(0xFFADB8C7);
  static const Color textMuted = Color(0xFF778493);

  static const Color border = Color(0x4D8293A6);
  static const Color borderSoft = Color(0x268293A6);
  static const Color borderGold = Color(0x80FFB536);

  static const Color danger = Color(0xFFE85B62);
  static const Color warning = Color(0xFFFFB536);
  static const Color success = Color(0xFF4FC28B);

  static const Color transparent = Colors.transparent;
}

abstract final class OrthaRadii {
  static const double small = 14;
  static const double medium = 20;
  static const double large = 28;
  static const double extraLarge = 36;
}

abstract final class OrthaSpacing {
  static const double xSmall = 6;
  static const double small = 10;
  static const double medium = 16;
  static const double large = 24;
  static const double xLarge = 32;
}

abstract final class OrthaDesignSystem {
  static ThemeData get theme {
    final ColorScheme scheme =
        ColorScheme.fromSeed(
          seedColor: OrthaColors.gold,
          brightness: Brightness.dark,
          surface: OrthaColors.backgroundRaised,
        ).copyWith(
          primary: OrthaColors.gold,
          secondary: OrthaColors.goldSoft,
          surface: OrthaColors.backgroundRaised,
          error: OrthaColors.danger,
          onPrimary: OrthaColors.background,
          onSecondary: OrthaColors.background,
          onSurface: OrthaColors.textPrimary,
          onError: OrthaColors.textPrimary,
        );

    final TextTheme textTheme = const TextTheme(
      displayLarge: TextStyle(
        color: OrthaColors.textPrimary,
        fontSize: 52,
        fontWeight: FontWeight.w700,
        height: 1.02,
        letterSpacing: -1.6,
      ),
      displayMedium: TextStyle(
        color: OrthaColors.textPrimary,
        fontSize: 42,
        fontWeight: FontWeight.w700,
        height: 1.05,
        letterSpacing: -1.2,
      ),
      headlineLarge: TextStyle(
        color: OrthaColors.textPrimary,
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.12,
      ),
      headlineMedium: TextStyle(
        color: OrthaColors.textPrimary,
        fontSize: 25,
        fontWeight: FontWeight.w700,
        height: 1.15,
      ),
      titleLarge: TextStyle(
        color: OrthaColors.textPrimary,
        fontSize: 21,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      titleMedium: TextStyle(
        color: OrthaColors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.25,
      ),
      bodyLarge: TextStyle(
        color: OrthaColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.42,
      ),
      bodyMedium: TextStyle(
        color: OrthaColors.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        color: OrthaColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      textTheme: textTheme,

      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: Colors.transparent,
      splashColor: OrthaColors.gold.withAlpha(24),
      highlightColor: OrthaColors.gold.withAlpha(12),
      dividerColor: OrthaColors.borderSoft,

      cardColor: OrthaColors.glass,
      cardTheme: const CardThemeData(
        color: OrthaColors.glass,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black54,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(OrthaRadii.large)),
          side: BorderSide(color: OrthaColors.border, width: 0.8),
        ),
      ),

      dialogTheme: const DialogThemeData(
        backgroundColor: OrthaColors.glassStrong,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: OrthaColors.textPrimary,
          fontSize: 21,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: TextStyle(
          color: OrthaColors.textSecondary,
          fontSize: 15,
          height: 1.4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(OrthaRadii.large)),
          side: BorderSide(color: OrthaColors.borderGold, width: 0.8),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xF5051019),
        selectedItemColor: OrthaColors.gold,
        unselectedItemColor: OrthaColors.textSecondary,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xF5051019),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: OrthaColors.gold.withAlpha(24),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((
          Set<WidgetState> states,
        ) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? OrthaColors.gold
                : OrthaColors.textSecondary,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
          Set<WidgetState> states,
        ) {
          return TextStyle(
            color: states.contains(WidgetState.selected)
                ? OrthaColors.gold
                : OrthaColors.textSecondary,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
          );
        }),
      ),

      iconTheme: const IconThemeData(color: OrthaColors.textPrimary),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: OrthaColors.glassSoft,
        hintStyle: const TextStyle(color: OrthaColors.textMuted),
        labelStyle: const TextStyle(color: OrthaColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OrthaRadii.medium),
          borderSide: const BorderSide(color: OrthaColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OrthaRadii.medium),
          borderSide: const BorderSide(color: OrthaColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OrthaRadii.medium),
          borderSide: const BorderSide(color: OrthaColors.gold, width: 1.2),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll<double>(0),
          backgroundColor: WidgetStateProperty.resolveWith<Color>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.disabled)) {
              return OrthaColors.glassSoft;
            }
            return OrthaColors.glassStrong;
          }),
          foregroundColor: const WidgetStatePropertyAll<Color>(
            OrthaColors.gold,
          ),
          side: const WidgetStatePropertyAll<BorderSide>(
            BorderSide(color: OrthaColors.borderGold, width: 0.9),
          ),
          shape: const WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(OrthaRadii.medium),
              ),
            ),
          ),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: const WidgetStatePropertyAll<Color>(
            OrthaColors.gold,
          ),
          side: const WidgetStatePropertyAll<BorderSide>(
            BorderSide(color: OrthaColors.borderGold, width: 0.9),
          ),
          shape: const WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(OrthaRadii.medium),
              ),
            ),
          ),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ),

      chipTheme: const ChipThemeData(
        backgroundColor: OrthaColors.glassSoft,
        selectedColor: Color(0x2EFFB536),
        disabledColor: Color(0x5510202D),
        labelStyle: TextStyle(
          color: OrthaColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: TextStyle(
          color: OrthaColors.gold,
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide(color: OrthaColors.border, width: 0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(OrthaRadii.medium)),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: OrthaColors.glassStrong,
        foregroundColor: OrthaColors.gold,
        elevation: 0,
        shape: CircleBorder(
          side: BorderSide(color: OrthaColors.borderGold, width: 0.9),
        ),
      ),
    );
  }
}
