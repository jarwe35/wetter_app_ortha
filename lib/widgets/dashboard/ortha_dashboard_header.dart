import 'package:flutter/material.dart';

import '../ortha_ui/ortha_responsive.dart';

enum OrthaWarningBeaconState { loading, green, yellow, red }

class OrthaDashboardHeader extends StatelessWidget {
  const OrthaDashboardHeader({
    super.key,
    this.onHome,
    this.onOpenWarnings,
    this.warningState = OrthaWarningBeaconState.green,
  });

  final VoidCallback? onHome;
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
        return 'Die amtlichen Warnquellen werden aktuell abgefragt.';

      case OrthaWarningBeaconState.green:
        return 'Für Ihren Standort liegen aktuell keine amtlichen '
            'Warnungen vor.';

      case OrthaWarningBeaconState.yellow:
        return 'Für Ihren Standort liegt mindestens eine amtliche '
            'Warnung vor. Bitte beachten Sie die Warnzentrale.';

      case OrthaWarningBeaconState.red:
        return 'Für Ihren Standort besteht eine erhebliche oder akute '
            'Warnlage. Bitte beachten Sie umgehend die amtlichen Hinweise.';
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

  @override
  Widget build(BuildContext context) {
    final responsive = OrthaResponsive.of(context);
    final statusColor = _statusColor;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: responsive.cardPadding,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(responsive.cardRadius),
        border: Border.all(color: statusColor.withValues(alpha: 0.34)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.46),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
          BoxShadow(color: statusColor.withValues(alpha: 0.08), blurRadius: 20),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _HeaderActionButton(
                tooltip: 'Zur Übersicht',
                icon: Icons.home_outlined,
                onPressed: onHome ?? () {},
              ),
              const Spacer(),
              OrthaWarningBeacon(
                state: warningState,
                onPressed: onOpenWarnings ?? () {},
              ),
            ],
          ),
          const SizedBox(height: 10),
          Semantics(
            button: onOpenWarnings != null,
            label: '$_statusTitle. $_statusDescription',
            child: InkWell(
              key: const ValueKey('nova-status-area'),
              onTap: onOpenWarnings,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 2, 8, 4),
                child: Column(
                  children: [
                    Semantics(
                      label: 'ORTHA METEO',
                      image: true,
                      child: Image.asset(
                        'assets/branding/ortha_meteo_master.png',
                        key: const ValueKey('dashboard-warning-master-logo'),
                        height: 87,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        errorBuilder:
                            (
                              BuildContext context,
                              Object error,
                              StackTrace? stackTrace,
                            ) {
                              return const SizedBox.shrink();
                            },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _statusDescription,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _secondaryText,
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  const _HeaderActionButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: const Color(0xD9142634),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: OrthaDashboardHeader._border.withValues(alpha: 0.9),
          ),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(
              icon,
              color: OrthaDashboardHeader._primaryText,
              size: 23,
            ),
          ),
        ),
      ),
    );
  }
}

class OrthaWarningBeacon extends StatefulWidget {
  final OrthaWarningBeaconState state;
  final VoidCallback onPressed;

  const OrthaWarningBeacon({
    super.key,
    required this.state,
    required this.onPressed,
  });

  @override
  State<OrthaWarningBeacon> createState() => _OrthaWarningBeaconState();
}

class _OrthaWarningBeaconState extends State<OrthaWarningBeacon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    );

    _pulse = Tween<double>(
      begin: 0.25,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _synchronizeAnimation();
  }

  @override
  void didUpdateWidget(covariant OrthaWarningBeacon oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.state != widget.state) {
      _synchronizeAnimation();
    }
  }

  void _synchronizeAnimation() {
    if (widget.state == OrthaWarningBeaconState.red) {
      _controller.repeat(reverse: true);
    } else {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  Color get _color {
    switch (widget.state) {
      case OrthaWarningBeaconState.loading:
        return const Color(0xFF78909C);
      case OrthaWarningBeaconState.green:
        return const Color(0xFF2E8B57);
      case OrthaWarningBeaconState.yellow:
        return const Color(0xFFD5A84A);
      case OrthaWarningBeaconState.red:
        return const Color(0xFFC33B3B);
    }
  }

  String get _tooltip {
    switch (widget.state) {
      case OrthaWarningBeaconState.loading:
        return 'Warnlage wird geladen';
      case OrthaWarningBeaconState.green:
        return 'Warnlage grün – keine erhöhte Gefahr';
      case OrthaWarningBeaconState.yellow:
        return 'Warnlage gelb – erhöhte Aufmerksamkeit';
      case OrthaWarningBeaconState.red:
        return 'Warnlage rot – Warnungen anzeigen';
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
      child: Semantics(
        button: true,
        label: _tooltip,
        child: Material(
          color: const Color(0xD9142634),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: _color.withValues(alpha: 0.55)),
          ),
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 46,
              height: 46,
              child: Center(
                child: AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, child) {
                    final pulseOpacity =
                        widget.state == OrthaWarningBeaconState.red
                        ? _pulse.value
                        : 0.32;

                    return Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _color.withValues(alpha: 0.12),
                        boxShadow: [
                          BoxShadow(
                            color: _color.withValues(alpha: pulseOpacity),
                            blurRadius:
                                widget.state == OrthaWarningBeaconState.red
                                ? 14
                                : 7,
                            spreadRadius:
                                widget.state == OrthaWarningBeaconState.red
                                ? 2
                                : 0,
                          ),
                        ],
                        border: Border.all(
                          color: _color.withValues(alpha: 0.55),
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 11,
                          height: 11,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _color,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
