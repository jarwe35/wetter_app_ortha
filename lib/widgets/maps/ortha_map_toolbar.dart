import 'package:flutter/material.dart';

/// Kompakte Werkzeugleiste für Kartenansichten von ORTHA METEO Ω.
///
/// Die Werkzeugleiste verwendet bewusst keine FloatingActionButtons.
/// Dadurch bleibt sie auch bei begrenzter Kartenhöhe kompakt und kann
/// innerhalb der zentralen [OrthaMapShell] ohne vertikalen Overflow
/// dargestellt werden.
class OrthaMapToolbar extends StatelessWidget {
  const OrthaMapToolbar({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onCenter,
    this.onLayers,
    this.compact = false,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onCenter;
  final VoidCallback? onLayers;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final buttonSize = compact ? 38.0 : 44.0;
    final iconSize = compact ? 20.0 : 22.0;

    return Material(
      key: const Key('ortha-map-toolbar'),
      color: Colors.black.withValues(alpha: 0.38),
      elevation: 4,
      borderRadius: BorderRadius.circular(compact ? 18 : 22),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 3 : 4,
          vertical: compact ? 4 : 6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onLayers != null) ...[
              _ToolbarButton(
                key: const Key('ortha-map-toolbar-layers'),
                tooltip: 'Ebenen auswählen',
                icon: Icons.layers_outlined,
                iconSize: iconSize,
                buttonSize: buttonSize,
                onPressed: onLayers!,
              ),
              const _ToolbarDivider(),
            ],
            _ToolbarButton(
              key: const Key('ortha-map-toolbar-zoom-in'),
              tooltip: 'Vergrößern',
              icon: Icons.add_rounded,
              iconSize: iconSize,
              buttonSize: buttonSize,
              onPressed: onZoomIn,
            ),
            const _ToolbarDivider(),
            _ToolbarButton(
              key: const Key('ortha-map-toolbar-zoom-out'),
              tooltip: 'Verkleinern',
              icon: Icons.remove_rounded,
              iconSize: iconSize,
              buttonSize: buttonSize,
              onPressed: onZoomOut,
            ),
            const _ToolbarDivider(),
            _ToolbarButton(
              key: const Key('ortha-map-toolbar-center'),
              tooltip: 'Standort zentrieren',
              icon: Icons.my_location_rounded,
              iconSize: iconSize,
              buttonSize: buttonSize,
              foregroundColor: colorScheme.primary,
              onPressed: onCenter,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.iconSize,
    required this.buttonSize,
    required this.onPressed,
    this.foregroundColor,
  });

  final String tooltip;
  final IconData icon;
  final double iconSize;
  final double buttonSize;
  final VoidCallback onPressed;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: IconButton(
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: iconSize,
          color: foregroundColor ?? Colors.white,
        ),
      ),
    );
  }
}

class _ToolbarDivider extends StatelessWidget {
  const _ToolbarDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 1,
      color: Colors.white.withValues(alpha: 0.12),
    );
  }
}
