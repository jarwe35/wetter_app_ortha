import 'package:flutter/material.dart';

import '../ortha_ui/ortha_responsive.dart';

enum OrthaWarningBeaconState { loading, green, yellow, red }

class OrthaDashboardHeader extends StatelessWidget {
  const OrthaDashboardHeader({
    super.key,
    required this.place,
    this.onHome,
    this.onRefresh,
    this.onOpenWarnings,
    this.warningState = OrthaWarningBeaconState.green,
  });

  final String place;
  final VoidCallback? onHome;
  final VoidCallback? onRefresh;
  final VoidCallback? onOpenWarnings;
  final OrthaWarningBeaconState warningState;

  static const Color _surface = Color(0xE6112230);
  static const Color _primaryText = Color(0xFFF4F7FA);
  static const Color _secondaryText = Color(0xFFADB9C7);
  static const Color _border = Color(0x668497A9);

  String get _statusTitle {
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

  String get _statusDescription {
    switch (warningState) {
      case OrthaWarningBeaconState.loading:
        return 'Amtliche Warnquellen werden geprüft.';

      case OrthaWarningBeaconState.green:
        return 'Keine amtlichen Warnungen für $place.';

      case OrthaWarningBeaconState.yellow:
        return 'Amtliche Warnung für $place.';

      case OrthaWarningBeaconState.red:
        return 'Akute Warnlage für $place.';
    }
  }

  Color get _statusColor {
    switch (warningState) {
      case OrthaWarningBeaconState.loading:
        return const Color(0xFF78909C);

      case OrthaWarningBeaconState.green:
        return const Color(0xFF42B96B);

      case OrthaWarningBeaconState.yellow:
        return const Color(0xFFE0B04B);

      case OrthaWarningBeaconState.red:
        return const Color(0xFFE25555);
    }
  }

  IconData get _statusIcon {
    switch (warningState) {
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

  @override
  Widget build(BuildContext context) {
    final responsive = OrthaResponsive.of(context);
    final statusColor = _statusColor;

    return AnimatedContainer(
      key: const ValueKey('ortha-dashboard-header'),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: responsive.cardPadding,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(responsive.cardRadius),
        border: Border.all(color: statusColor.withValues(alpha: 0.34)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.42),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
          BoxShadow(color: statusColor.withValues(alpha: 0.07), blurRadius: 18),
        ],
      ),
      child: Row(
        children: [
          _LogoButton(onPressed: onHome),
          const SizedBox(width: 12),
          Expanded(
            child: Semantics(
              button: onOpenWarnings != null,
              label: '$_statusTitle. $_statusDescription',
              child: InkWell(
                key: const ValueKey('nova-status-area'),
                onTap: onOpenWarnings,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 3,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: _secondaryText,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              place,
                              key: const ValueKey('dashboard-header-place'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _primaryText,
                                fontSize: 15,
                                height: 1.1,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (warningState == OrthaWarningBeaconState.loading)
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.8,
                                color: statusColor,
                              ),
                            )
                          else
                            Icon(_statusIcon, size: 15, color: statusColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _statusTitle,
                              key: const ValueKey(
                                'dashboard-header-warning-status',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 13,
                                height: 1.1,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _HeaderActionButton(
            key: const ValueKey('dashboard-header-refresh'),
            tooltip: 'Wetterdaten aktualisieren',
            icon: Icons.refresh_rounded,
            onPressed: onRefresh,
          ),
          const SizedBox(width: 7),
          OrthaWarningBeacon(state: warningState, onPressed: onOpenWarnings),
        ],
      ),
    );
  }
}

class _LogoButton extends StatelessWidget {
  const _LogoButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onPressed != null,
      label: 'ORTHA METEO – Zur Übersicht',
      child: Material(
        color: const Color(0xB3142634),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          key: const ValueKey('dashboard-header-logo-button'),
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 52,
            height: 52,
            child: Padding(
              padding: const EdgeInsets.all(5),
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
        ),
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: const Color(0xD9142634),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: OrthaDashboardHeader._border.withValues(
              alpha: enabled ? 0.9 : 0.35,
            ),
          ),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              color: enabled
                  ? OrthaDashboardHeader._primaryText
                  : OrthaDashboardHeader._secondaryText.withValues(alpha: 0.45),
              size: 22,
            ),
          ),
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
        return const Color(0xFF78909C);

      case OrthaWarningBeaconState.green:
        return const Color(0xFF42B96B);

      case OrthaWarningBeaconState.yellow:
        return const Color(0xFFE0B04B);

      case OrthaWarningBeaconState.red:
        return const Color(0xFFE25555);
    }
  }

  String get _tooltip {
    switch (widget.state) {
      case OrthaWarningBeaconState.loading:
        return 'Warnlage wird geprüft';

      case OrthaWarningBeaconState.green:
        return 'Keine amtlichen Warnungen';

      case OrthaWarningBeaconState.yellow:
        return 'Amtliche Warnung vorhanden';

      case OrthaWarningBeaconState.red:
        return 'Akute Warnlage';
    }
  }

  bool get _shouldPulse =>
      widget.state == OrthaWarningBeaconState.loading ||
      widget.state == OrthaWarningBeaconState.yellow ||
      widget.state == OrthaWarningBeaconState.red;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
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
    return Tooltip(
      message: _tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const ValueKey('dashboard-warning-beacon'),
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 44,
            height: 44,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final pulse = _shouldPulse ? _controller.value : 0.0;

                return Center(
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _color.withValues(alpha: 0.12),
                      border: Border.all(color: _color.withValues(alpha: 0.55)),
                      boxShadow: [
                        BoxShadow(
                          color: _color.withValues(
                            alpha: 0.12 + (pulse * 0.22),
                          ),
                          blurRadius: 6 + (pulse * 7),
                          spreadRadius: pulse * 1.5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _color,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
