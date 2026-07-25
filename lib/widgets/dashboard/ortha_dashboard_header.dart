import 'package:flutter/material.dart';

import '../ortha_ui/ortha_responsive.dart';

enum OrthaWarningBeaconState { loading, green, yellow, red }

class OrthaDashboardHeader extends StatelessWidget {
  final VoidCallback? onHome;
  final VoidCallback? onOpenWarnings;
  final VoidCallback onOpenLocations;
  final VoidCallback onOpenUnitSettings;
  final OrthaWarningBeaconState warningState;

  const OrthaDashboardHeader({
    super.key,
    this.onHome,
    this.onOpenWarnings,
    required this.onOpenLocations,
    required this.onOpenUnitSettings,
    this.warningState = OrthaWarningBeaconState.green,
  });

  static const Color _surface = Color(0xE6112230);
  static const Color _primaryText = Color(0xFFF4F7FA);
  static const Color _secondaryText = Color(0xFFADB9C7);
  static const Color _accent = Color(0xFFFFB536);
  static const Color _border = Color(0x668497A9);

  @override
  Widget build(BuildContext context) {
    final ui = OrthaResponsive.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ui.cardPadding),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(ui.cardRadius),
        border: Border.all(color: _border.withValues(alpha: 0.85)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.48),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 520;

          final identity = Row(
            children: [
              Container(
                width: ui.sectionIconSize,
                height: ui.sectionIconSize,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(ui.cardRadius * 0.6),
                  border: Border.all(color: _accent.withValues(alpha: 0.35)),
                ),
                child: Icon(
                  Icons.cloud_outlined,
                  color: _accent,
                  size: ui.iconSize,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORTHA METEO Ω',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: _primaryText,
                      ),
                    ),
                    Text(
                      'Wetter · Warnungen · Risiko',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: _secondaryText),
                    ),
                  ],
                ),
              ),
            ],
          );

          final controls = Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeaderActionButton(
                tooltip: 'Zur Übersicht',
                icon: Icons.home_outlined,
                onPressed: onHome ?? () {},
              ),
              OrthaWarningBeacon(
                state: warningState,
                onPressed: onOpenWarnings ?? () {},
              ),
              _HeaderActionButton(
                tooltip: 'Einheiten',
                icon: Icons.straighten_outlined,
                onPressed: onOpenUnitSettings,
              ),
              OutlinedButton.icon(
                onPressed: onOpenLocations,
                icon: const Icon(Icons.location_city_outlined),
                label: const Text('Meine Orte'),
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                identity,
                const SizedBox(height: 12),
                Align(alignment: Alignment.centerLeft, child: controls),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: identity),
              const SizedBox(width: 16),
              Flexible(child: controls),
            ],
          );
        },
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
