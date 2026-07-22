import 'package:flutter/material.dart';

/// Schwebender Kopfbereich für die Kartenmodule von ORTHA METEO Ω.
///
/// Der Header ersetzt klassische AppBars innerhalb der Kartenansichten.
/// Er bündelt Ortsinformation, Kartenmodus, Quellenstatus, NOVA-Status
/// sowie unmittelbar benötigte Kartenaktionen.
class OrthaMapHeader extends StatelessWidget {
  const OrthaMapHeader({
    super.key,
    required this.place,
    required this.mode,
    required this.statusText,
    this.novaStatus = 'Normal',
    this.onBack,
    this.onLayers,
    this.onRefresh,
    this.isRefreshing = false,
    this.coordinatesAvailable = true,
  });

  final String place;
  final String mode;
  final String statusText;
  final String novaStatus;
  final VoidCallback? onBack;
  final VoidCallback? onLayers;
  final VoidCallback? onRefresh;
  final bool isRefreshing;
  final bool coordinatesAvailable;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 430;

        return Material(
          key: const Key('ortha-map-header'),
          color: Colors.black.withValues(alpha: 0.86),
          elevation: 10,
          borderRadius: BorderRadius.circular(compact ? 20 : 24),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              compact ? 10 : 14,
              compact ? 10 : 12,
              compact ? 8 : 12,
              compact ? 10 : 12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (onBack != null) ...[
                  _HeaderAction(
                    key: const Key('ortha-map-header-back'),
                    tooltip: 'Zurück',
                    icon: Icons.arrow_back_rounded,
                    onPressed: onBack!,
                  ),
                  SizedBox(width: compact ? 4 : 8),
                ] else ...[
                  Container(
                    width: compact ? 38 : 42,
                    height: compact ? 38 : 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.public_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  SizedBox(width: compact ? 8 : 12),
                ],
                Expanded(
                  child: _HeaderInformation(
                    place: place,
                    mode: mode,
                    statusText: statusText,
                    novaStatus: novaStatus,
                    coordinatesAvailable: coordinatesAvailable,
                    compact: compact,
                  ),
                ),
                SizedBox(width: compact ? 4 : 8),
                if (onLayers != null)
                  _HeaderAction(
                    key: const Key('ortha-map-header-layers'),
                    tooltip: 'Ebenen auswählen',
                    icon: Icons.layers_outlined,
                    onPressed: onLayers!,
                  ),
                if (onRefresh != null)
                  isRefreshing
                      ? SizedBox(
                          key: const Key('ortha-map-header-refreshing'),
                          width: compact ? 40 : 44,
                          height: compact ? 40 : 44,
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : _HeaderAction(
                          key: const Key('ortha-map-header-refresh'),
                          tooltip: 'Kartendaten aktualisieren',
                          icon: Icons.refresh_rounded,
                          onPressed: onRefresh!,
                        ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeaderInformation extends StatelessWidget {
  const _HeaderInformation({
    required this.place,
    required this.mode,
    required this.statusText,
    required this.novaStatus,
    required this.coordinatesAvailable,
    required this.compact,
  });

  final String place;
  final String mode;
  final String statusText;
  final String novaStatus;
  final bool coordinatesAvailable;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                place,
                key: const Key('ortha-map-header-place'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 15 : 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(width: compact ? 6 : 10),
            _NovaStatusBadge(status: novaStatus, compact: compact),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          mode,
          key: const Key('ortha-map-header-mode'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.88),
            fontSize: compact ? 12 : 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          coordinatesAvailable
              ? statusText
              : '$statusText · Keine Standortkoordinaten',
          key: const Key('ortha-map-header-status'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: coordinatesAvailable
                ? Colors.white.withValues(alpha: 0.64)
                : Colors.amber.shade200,
            fontSize: compact ? 10 : 11,
          ),
        ),
      ],
    );
  }
}

class _NovaStatusBadge extends StatelessWidget {
  const _NovaStatusBadge({required this.status, required this.compact});

  final String status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('ortha-map-header-nova-status'),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 6 : 7,
            height: compact ? 6 : 7,
            decoration: const BoxDecoration(
              color: Colors.greenAccent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'NOVA $status',
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 9 : 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: IconButton(
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
