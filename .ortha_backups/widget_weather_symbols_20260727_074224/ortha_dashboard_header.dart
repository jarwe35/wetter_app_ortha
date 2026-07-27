import 'package:flutter/material.dart';

enum OrthaWarningBeaconState { loading, green, yellow, red }

class OrthaDashboardHeader extends StatelessWidget {
  const OrthaDashboardHeader({
    super.key,
    required this.place,
    this.temperatureText = '—',
    this.conditionText = '',
    this.weatherCode,
    this.isDay = true,
    this.lastUpdatedText,
    this.onHome,
    this.onRefresh,
    this.onOpenWarnings,
    this.warningState = OrthaWarningBeaconState.green,
  });

  final String place;
  final String temperatureText;
  final String conditionText;
  final int? weatherCode;
  final bool isDay;
  final String? lastUpdatedText;

  final VoidCallback? onHome;
  final VoidCallback? onRefresh;
  final VoidCallback? onOpenWarnings;

  final OrthaWarningBeaconState warningState;

  static const Color _background = Color(0xF508141D);
  static const Color _panel = Color(0xD90D1D28);
  static const Color _panelSoft = Color(0xB8122531);

  static const Color _primaryText = Color(0xFFF6F8FA);
  static const Color _secondaryText = Color(0xFFB6C2CC);
  static const Color _mutedText = Color(0xFF82909C);

  static const Color _green = Color(0xFF4DE47B);
  static const Color _yellow = Color(0xFFFFD54F);
  static const Color _red = Color(0xFFFF5F67);
  static const Color _loading = Color(0xFF8FA4B4);

  Color get _warningColor {
    switch (warningState) {
      case OrthaWarningBeaconState.loading:
        return _loading;
      case OrthaWarningBeaconState.green:
        return _green;
      case OrthaWarningBeaconState.yellow:
        return _yellow;
      case OrthaWarningBeaconState.red:
        return _red;
    }
  }

  String get _warningTitle {
    switch (warningState) {
      case OrthaWarningBeaconState.loading:
        return 'Warnlage wird geprüft';
      case OrthaWarningBeaconState.green:
        return 'Keine Warnungen';
      case OrthaWarningBeaconState.yellow:
        return 'Amtliche Warnung';
      case OrthaWarningBeaconState.red:
        return 'Akute Warnlage';
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final veryCompact = width < 360;
    final compact = width < 430;

    return RepaintBoundary(
      child: Container(
        key: const ValueKey('ortha-dashboard-header'),
        width: double.infinity,
        height: compact ? 78 : 84,
        padding: EdgeInsets.fromLTRB(compact ? 7 : 10, 7, compact ? 7 : 10, 7),
        decoration: BoxDecoration(
          color: _background,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _warningColor.withValues(alpha: 0.68),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.48),
              blurRadius: 22,
              offset: const Offset(0, 9),
            ),
            BoxShadow(
              color: _warningColor.withValues(alpha: 0.17),
              blurRadius: 18,
              spreadRadius: 0.3,
            ),
          ],
        ),
        child: Row(
          children: [
            _BrandSection(compact: compact, onPressed: onHome),
            const _HeaderDivider(),
            Expanded(
              flex: veryCompact ? 5 : 6,
              child: _LocationSection(
                place: place,
                lastUpdatedText: lastUpdatedText,
                compact: compact,
                onRefresh: onRefresh,
              ),
            ),
            const _HeaderDivider(),
            Expanded(
              flex: veryCompact ? 3 : 4,
              child: _WeatherSection(
                temperatureText: temperatureText,
                conditionText: conditionText,
                weatherCode: weatherCode,
                isDay: isDay,
                compact: compact,
              ),
            ),
            if (!compact) ...[
              const _HeaderDivider(),
              _RefreshSection(onPressed: onRefresh),
            ],
            const _HeaderDivider(),
            _WarningSection(
              state: warningState,
              color: _warningColor,
              title: _warningTitle,
              compact: compact,
              onPressed: onOpenWarnings,
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandSection extends StatelessWidget {
  const _BrandSection({required this.compact, required this.onPressed});

  final bool compact;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onPressed != null,
      label: 'ORTHA METEO – Zur Übersicht',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const ValueKey('dashboard-header-logo-button'),
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: compact ? 54 : 69,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: compact ? 45 : 48,
                    height: compact ? 45 : 48,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: OrthaDashboardHeader._panel,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF87D8FF).withValues(alpha: 0.28),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF5EC9FF,
                          ).withValues(alpha: 0.12),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.asset(
                        'assets/branding/ortha_meteo_master.png',
                        key: const ValueKey('dashboard-warning-master-logo'),
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        errorBuilder:
                            (
                              BuildContext context,
                              Object error,
                              StackTrace? stackTrace,
                            ) {
                              return const Icon(
                                Icons.cloud_outlined,
                                color: OrthaDashboardHeader._primaryText,
                                size: 26,
                              );
                            },
                      ),
                    ),
                  ),
                  if (!compact) ...[
                    const SizedBox(height: 3),
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'ORTHA METEO Ω',
                        maxLines: 1,
                        style: TextStyle(
                          color: OrthaDashboardHeader._secondaryText,
                          fontSize: 8.5,
                          height: 1,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.15,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationSection extends StatelessWidget {
  const _LocationSection({
    required this.place,
    required this.lastUpdatedText,
    required this.compact,
    required this.onRefresh,
  });

  final String place;
  final String? lastUpdatedText;
  final bool compact;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final String updateText;

    if (lastUpdatedText == null || lastUpdatedText!.trim().isEmpty) {
      updateText = 'Aktualisiert';
    } else {
      updateText = 'Stand ${lastUpdatedText!}';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onRefresh,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 6 : 10,
            vertical: 4,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: compact ? 17 : 19,
                    color: OrthaDashboardHeader._green,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        place,
                        key: const ValueKey('dashboard-header-place'),
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          color: OrthaDashboardHeader._primaryText,
                          fontSize: compact ? 14 : 16,
                          height: 1,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.05,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  SizedBox(width: compact ? 22 : 24),
                  Expanded(
                    child: Text(
                      updateText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: OrthaDashboardHeader._mutedText,
                        fontSize: compact ? 9 : 10,
                        height: 1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (compact)
                    Icon(
                      Icons.refresh_rounded,
                      key: const ValueKey('dashboard-header-refresh'),
                      size: 16,
                      color: onRefresh == null
                          ? OrthaDashboardHeader._mutedText
                          : OrthaDashboardHeader._green,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeatherSection extends StatelessWidget {
  const _WeatherSection({
    required this.temperatureText,
    required this.conditionText,
    required this.weatherCode,
    required this.isDay,
    required this.compact,
  });

  final String temperatureText;
  final String conditionText;
  final int? weatherCode;
  final bool isDay;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final condition = conditionText.trim().isEmpty
        ? 'Wetterlage'
        : conditionText.trim();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: compact ? 3 : 5, vertical: 1),
      padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 8, vertical: 5),
      decoration: BoxDecoration(
        color: OrthaDashboardHeader._panelSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.045)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ClassicWeatherIcon(
                  weatherCode: weatherCode,
                  isDay: isDay,
                  size: compact ? 24 : 28,
                  semanticLabel: condition,
                ),
                const SizedBox(width: 5),
                Text(
                  temperatureText,
                  maxLines: 1,
                  style: TextStyle(
                    color: OrthaDashboardHeader._primaryText,
                    fontSize: compact ? 16 : 19,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 7),
          Text(
            condition,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: OrthaDashboardHeader._secondaryText,
              fontSize: compact ? 8.8 : 10,
              height: 1,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassicWeatherIcon extends StatelessWidget {
  const _ClassicWeatherIcon({
    required this.weatherCode,
    required this.isDay,
    required this.size,
    required this.semanticLabel,
  });

  final int? weatherCode;
  final bool isDay;
  final double size;
  final String semanticLabel;

  IconData get _icon {
    final code = weatherCode;

    if (code == null) {
      return Icons.cloud_rounded;
    }

    switch (code) {
      // Klarer Himmel
      case 0:
        return isDay ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded;

      // Überwiegend klar / teilweise bewölkt
      case 1:
      case 2:
        return isDay ? Icons.wb_cloudy_rounded : Icons.nights_stay_rounded;

      // Bedeckt
      case 3:
        return Icons.cloud_rounded;

      // Nebel
      case 45:
      case 48:
        return Icons.blur_on_rounded;

      // Nieselregen
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        return Icons.grain_rounded;

      // Regen
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
      case 80:
      case 81:
      case 82:
        return Icons.water_drop_rounded;

      // Schnee
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return Icons.ac_unit_rounded;

      // Gewitter
      case 95:
      case 96:
      case 99:
        return Icons.flash_on_rounded;

      default:
        return Icons.cloud_rounded;
    }
  }

  Color get _color {
    final code = weatherCode;

    if (code == null) {
      return OrthaDashboardHeader._primaryText;
    }

    switch (code) {
      case 0:
        return isDay ? const Color(0xFFFFD54F) : const Color(0xFFDCE7F4);

      case 1:
      case 2:
        return isDay ? const Color(0xFFE7EEF5) : const Color(0xFFD4DFEA);

      case 3:
      case 45:
      case 48:
        return const Color(0xFFD8E1E8);

      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
      case 80:
      case 81:
      case 82:
        return const Color(0xFF72C7F4);

      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return const Color(0xFFF1F7FB);

      case 95:
      case 96:
      case 99:
        return const Color(0xFFFFD54F);

      default:
        return OrthaDashboardHeader._primaryText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      image: true,
      child: Icon(
        _icon,
        key: ValueKey<String>(
          'dashboard-classic-weather-icon-${weatherCode ?? -1}',
        ),
        size: size,
        color: _color,
        shadows: [Shadow(color: _color.withValues(alpha: 0.24), blurRadius: 5)],
      ),
    );
  }
}

class _RefreshSection extends StatelessWidget {
  const _RefreshSection({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return Tooltip(
      message: 'Wetterdaten aktualisieren',
      child: Material(
        key: const ValueKey('dashboard-header-refresh'),
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: SizedBox(
            width: 65,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.refresh_rounded,
                  size: 26,
                  color: enabled
                      ? OrthaDashboardHeader._primaryText
                      : OrthaDashboardHeader._mutedText,
                ),
                const SizedBox(height: 4),
                Text(
                  'Aktualisieren',
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
                    color: enabled
                        ? OrthaDashboardHeader._secondaryText
                        : OrthaDashboardHeader._mutedText,
                    fontSize: 8.5,
                    height: 1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WarningSection extends StatelessWidget {
  const _WarningSection({
    required this.state,
    required this.color,
    required this.title,
    required this.compact,
    required this.onPressed,
  });

  final OrthaWarningBeaconState state;
  final Color color;
  final String title;
  final bool compact;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: const ValueKey('nova-status-area'),
      button: onPressed != null,
      label: title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const ValueKey('dashboard-warning-beacon'),
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: SizedBox(
            width: compact ? 55 : 78,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OrthaWarningBeacon(state: state, onPressed: onPressed),
                  const SizedBox(height: 5),
                  Text(
                    title,
                    key: const ValueKey('dashboard-header-warning-status'),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: state == OrthaWarningBeaconState.green
                          ? OrthaDashboardHeader._secondaryText
                          : color,
                      fontSize: compact ? 7.5 : 8.5,
                      height: 1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderDivider extends StatelessWidget {
  const _HeaderDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 46,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFF7892A4).withValues(alpha: 0.36),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class OrthaWarningBeacon extends StatefulWidget {
  const OrthaWarningBeacon({super.key, required this.state, this.onPressed});

  final OrthaWarningBeaconState state;
  final VoidCallback? onPressed;

  @override
  State<OrthaWarningBeacon> createState() => _OrthaWarningBeaconState();
}

class _OrthaWarningBeaconState extends State<OrthaWarningBeacon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  Color get _color {
    switch (widget.state) {
      case OrthaWarningBeaconState.loading:
        return OrthaDashboardHeader._loading;
      case OrthaWarningBeaconState.green:
        return OrthaDashboardHeader._green;
      case OrthaWarningBeaconState.yellow:
        return OrthaDashboardHeader._yellow;
      case OrthaWarningBeaconState.red:
        return OrthaDashboardHeader._red;
    }
  }

  IconData get _icon {
    switch (widget.state) {
      case OrthaWarningBeaconState.loading:
        return Icons.sync_rounded;
      case OrthaWarningBeaconState.green:
        return Icons.check_circle_outline_rounded;
      case OrthaWarningBeaconState.yellow:
        return Icons.warning_amber_rounded;
      case OrthaWarningBeaconState.red:
        return Icons.crisis_alert_rounded;
    }
  }

  bool get _shouldPulse {
    return widget.state == OrthaWarningBeaconState.loading ||
        widget.state == OrthaWarningBeaconState.yellow ||
        widget.state == OrthaWarningBeaconState.red;
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    );

    _updateAnimation();
  }

  @override
  void didUpdateWidget(covariant OrthaWarningBeacon oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.state != widget.state) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    if (_shouldPulse) {
      _controller.repeat(reverse: true);
    } else {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulse = _shouldPulse ? _controller.value : 0.0;

        return Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF08151E),
            border: Border.all(
              color: _color.withValues(alpha: 0.95),
              width: 1.7,
            ),
            boxShadow: [
              BoxShadow(
                color: _color.withValues(alpha: 0.18 + (pulse * 0.25)),
                blurRadius: 8 + (pulse * 10),
                spreadRadius: pulse * 1.5,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.38),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: widget.state == OrthaWarningBeaconState.loading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _color,
                    ),
                  )
                : Icon(
                    _icon,
                    size: 22,
                    color: _color,
                    shadows: [
                      Shadow(
                        color: _color.withValues(alpha: 0.58),
                        blurRadius: 8,
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
