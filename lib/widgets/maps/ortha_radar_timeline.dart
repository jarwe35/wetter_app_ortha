import 'package:flutter/material.dart';

/// Wiederverwendbare Zeitsteuerung für Radar- und Kartenverläufe.
///
/// Die Timeline verarbeitet ausschließlich Darstellung und Bedienung.
/// Das Laden der Radardaten sowie die Animationslogik verbleiben im
/// jeweiligen Kartenmodul.
class OrthaRadarTimeline extends StatelessWidget {
  const OrthaRadarTimeline({
    super.key,
    required this.value,
    required this.frameCount,
    required this.currentTimeText,
    required this.relativeTimeText,
    required this.firstTimeText,
    required this.lastTimeText,
    required this.isAnimating,
    required this.onToggleAnimation,
    required this.onChanged,
    this.onChangeStart,
    this.periodText = '2 Std.',
  });

  final int value;
  final int frameCount;
  final String currentTimeText;
  final String relativeTimeText;
  final String firstTimeText;
  final String lastTimeText;
  final bool isAnimating;
  final VoidCallback onToggleAnimation;
  final ValueChanged<int> onChanged;
  final VoidCallback? onChangeStart;
  final String periodText;

  @override
  Widget build(BuildContext context) {
    final safeFrameCount = frameCount < 1 ? 1 : frameCount;
    final maximumIndex = safeFrameCount - 1;
    final safeValue = value.clamp(0, maximumIndex);

    return Material(
      key: const Key('ortha-radar-timeline'),
      color: Colors.black.withValues(alpha: 0.86),
      elevation: 10,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 7, 10, 7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 42,
                  height: 42,
                  child: IconButton(
                    key: const Key('ortha-radar-timeline-play'),
                    padding: EdgeInsets.zero,
                    tooltip: isAnimating
                        ? 'Radaranimation anhalten'
                        : 'Radarverlauf abspielen',
                    onPressed: safeFrameCount > 1 ? onToggleAnimation : null,
                    icon: Icon(
                      isAnimating
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentTimeText,
                        key: const Key('ortha-radar-timeline-current-time'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (relativeTimeText.isNotEmpty)
                        Text(
                          relativeTimeText,
                          key: const Key('ortha-radar-timeline-relative-time'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  periodText,
                  key: const Key('ortha-radar-timeline-period'),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (safeFrameCount > 1)
              SizedBox(
                height: 28,
                child: Slider(
                  key: const Key('ortha-radar-timeline-slider'),
                  value: safeValue.toDouble(),
                  min: 0,
                  max: maximumIndex.toDouble(),
                  divisions: maximumIndex,
                  label: currentTimeText,
                  onChangeStart: (_) {
                    onChangeStart?.call();
                  },
                  onChanged: (newValue) {
                    onChanged(newValue.round());
                  },
                ),
              )
            else
              const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Text(
                    firstTimeText,
                    key: const Key('ortha-radar-timeline-first-time'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.62),
                      fontSize: 9,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    lastTimeText,
                    key: const Key('ortha-radar-timeline-last-time'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.62),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
