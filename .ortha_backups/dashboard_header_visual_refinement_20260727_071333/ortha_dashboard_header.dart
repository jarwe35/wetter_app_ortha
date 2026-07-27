import 'package:flutter/material.dart';

enum OrthaWarningBeaconState { loading, green, yellow, red }

class OrthaDashboardHeader extends StatelessWidget {
  const OrthaDashboardHeader({
    super.key,
    required this.place,
    this.temperatureText = '—',
    this.conditionText = '',
    this.lastUpdatedText,
    this.onHome,
    this.onRefresh,
    this.onOpenWarnings,
    this.warningState = OrthaWarningBeaconState.green,
  });

  final String place;

  /// Bereits formatierter Wert, beispielsweise „17.2 °C“.
  final String temperatureText;

  /// Beispielsweise „bedeckt“ oder „leichter Regen“.
  final String conditionText;

  /// Bereits formatierte Uhrzeit, beispielsweise „05:45“.
  final String? lastUpdatedText;

  final VoidCallback? onHome;
  final VoidCallback? onRefresh;
  final VoidCallback? onOpenWarnings;

  final OrthaWarningBeaconState warningState;

  static const Color _background = Color(0xF20A1721);

  static const Color _primaryText = Color(0xFFF5F7FA);
  static const Color _secondaryText = Color(0xFFB6C0CB);
  static const Color _mutedText = Color(0xFF8E9AA7);

  static const Color _green = Color(0xFF52DB78);
  static const Color _yellow = Color(0xFFFFC857);
  static const Color _red = Color(0xFFFF5E62);
  static const Color _loading = Color(0xFF90A4AE);

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
    final compact = width < 390;

    return RepaintBoundary(
      child: Container(
        key: const ValueKey('ortha-dashboard-header'),
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 82),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: _background,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _warningColor.withValues(alpha: 0.72),
            width: 1.15,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.48),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: _warningColor.withValues(alpha: 0.14),
              blurRadius: 18,
              spreadRadius: 0.5,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BrandSection(compact: compact, onPressed: onHome),
            _HeaderDivider(compact: compact),
            Expanded(
              flex: compact ? 5 : 4,
              child: _LocationSection(
                place: place,
                lastUpdatedText: lastUpdatedText,
                compact: compact,
                onRefresh: onRefresh,
              ),
            ),
            _HeaderDivider(compact: compact),
            Expanded(
              flex: compact ? 3 : 3,
              child: _WeatherSection(
                temperatureText: temperatureText,
                conditionText: conditionText,
                compact: compact,
              ),
            ),
            if (!compact) ...[
              const _HeaderDivider(),
              _RefreshSection(onPressed: onRefresh),
            ],
            _HeaderDivider(compact: compact),
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
          borderRadius: BorderRadius.circular(17),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 1 : 3,
              vertical: 1,
            ),
            child: SizedBox(
              width: compact ? 58 : 78,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: compact ? 48 : 55,
                    height: compact ? 48 : 55,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF132533),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xFF6D8295).withValues(alpha: 0.38),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF5EC9FF,
                          ).withValues(alpha: 0.11),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
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
                                size: 28,
                              );
                            },
                      ),
                    ),
                  ),
                  if (!compact) ...[
                    const SizedBox(height: 4),
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'ORTHA METEO Ω',
                        maxLines: 1,
                        style: TextStyle(
                          color: OrthaDashboardHeader._primaryText,
                          fontSize: 10.5,
                          height: 1,
                          fontWeight: FontWeight.w800,
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
    final updateText =
        lastUpdatedText == null || lastUpdatedText!.trim().isEmpty
        ? 'Aktualisiert'
        : 'Aktualisiert: ${lastUpdatedText!}';

    return InkWell(
      onTap: onRefresh,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 12,
          vertical: 5,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 22,
                  color: OrthaDashboardHeader._secondaryText,
                ),
                SizedBox(width: compact ? 4 : 7),
                Expanded(
                  child: Text(
                    place,
                    key: const ValueKey('dashboard-header-place'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: OrthaDashboardHeader._primaryText,
                      fontSize: compact ? 15 : 17,
                      height: 1.05,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.05,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                SizedBox(width: compact ? 22 : 29),
                Expanded(
                  child: Text(
                    updateText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: OrthaDashboardHeader._secondaryText,
                      fontSize: compact ? 9.5 : 10.5,
                      height: 1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (compact)
                  Icon(
                    Icons.refresh_rounded,
                    size: 15,
                    color: onRefresh == null
                        ? OrthaDashboardHeader._mutedText
                        : OrthaDashboardHeader._green,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherSection extends StatelessWidget {
  const _WeatherSection({
    required this.temperatureText,
    required this.conditionText,
    required this.compact,
  });

  final String temperatureText;
  final String conditionText;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 5 : 10, vertical: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_rounded,
                size: compact ? 18 : 21,
                color: OrthaDashboardHeader._primaryText,
              ),
              SizedBox(width: compact ? 4 : 7),
              Flexible(
                child: Text(
                  temperatureText,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
                    color: OrthaDashboardHeader._primaryText,
                    fontSize: compact ? 14 : 17,
                    height: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            conditionText.trim().isEmpty ? 'Wetterlage' : conditionText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: OrthaDashboardHeader._secondaryText,
              fontSize: compact ? 9.5 : 11,
              height: 1,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
          borderRadius: BorderRadius.circular(17),
          child: SizedBox(
            width: 78,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    size: 30,
                    color: enabled
                        ? OrthaDashboardHeader._primaryText
                        : OrthaDashboardHeader._mutedText,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Aktualisieren',
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(
                      color: enabled
                          ? OrthaDashboardHeader._secondaryText
                          : OrthaDashboardHeader._mutedText,
                      fontSize: 9.5,
                      height: 1,
                      fontWeight: FontWeight.w500,
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
          borderRadius: BorderRadius.circular(17),
          child: SizedBox(
            width: compact ? 54 : 76,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 4 : 7,
                vertical: 4,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OrthaWarningBeacon(state: state, onPressed: onPressed),
                  if (!compact) ...[
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
                        fontSize: 9,
                        height: 1,
                        fontWeight: FontWeight.w600,
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

class _HeaderDivider extends StatelessWidget {
  const _HeaderDivider({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: EdgeInsets.symmetric(
        vertical: compact ? 8 : 5,
        horizontal: compact ? 1 : 3,
      ),
      color: const Color(0xFF738697).withValues(alpha: 0.34),
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
      duration: const Duration(milliseconds: 1100),
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
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0B1923),
            border: Border.all(color: _color.withValues(alpha: 0.95), width: 2),
            boxShadow: [
              BoxShadow(
                color: _color.withValues(alpha: 0.16 + (pulse * 0.24)),
                blurRadius: 8 + (pulse * 9),
                spreadRadius: pulse * 1.8,
              ),
            ],
          ),
          child: Center(
            child: widget.state == OrthaWarningBeaconState.loading
                ? SizedBox(
                    width: 19,
                    height: 19,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _color,
                    ),
                  )
                : Icon(
                    _icon,
                    size: 24,
                    color: _color,
                    shadows: [
                      Shadow(
                        color: _color.withValues(alpha: 0.55),
                        blurRadius: 9,
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
