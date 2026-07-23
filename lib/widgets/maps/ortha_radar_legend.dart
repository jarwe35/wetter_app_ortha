import 'package:flutter/material.dart';

import '../common/ortha_premium_card.dart';

/// Radarlegende im hellen ORTHA-Premiumdesign.
class OrthaRadarLegend extends StatelessWidget {
  const OrthaRadarLegend({super.key});

  static const List<_LegendItemData> _items = [
    _LegendItemData(label: 'Sehr schwach', color: OrthaDesignColors.greyLight),
    _LegendItemData(label: 'Schwach', color: OrthaDesignColors.grey),
    _LegendItemData(label: 'Mäßig', color: OrthaDesignColors.blue),
    _LegendItemData(label: 'Stark', color: OrthaDesignColors.blueDark),
    _LegendItemData(label: 'Sehr stark', color: OrthaDesignColors.gold),
    _LegendItemData(label: 'Extrem', color: OrthaDesignColors.red),
  ];

  @override
  Widget build(BuildContext context) {
    return OrthaPremiumCard(
      key: const Key('ortha-radar-legend'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.palette_outlined,
                size: 23,
                color: OrthaDesignColors.gold,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Niederschlagsintensität',
                  style: TextStyle(
                    color: OrthaDesignColors.navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 14) / 2;

              return Wrap(
                spacing: 14,
                runSpacing: 15,
                children: [
                  for (final item in _items)
                    SizedBox(
                      width: itemWidth,
                      child: _LegendItem(data: item),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 17),
          const Text(
            'Die Farben kennzeichnen die relative Intensität der '
            'Radarechos und keine exakte Niederschlagsmenge.',
            style: TextStyle(
              color: OrthaDesignColors.greyDark,
              fontSize: 11,
              height: 1.4,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItemData {
  const _LegendItemData({required this.label, required this.color});

  final String label;
  final Color color;
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.data});

  final _LegendItemData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 17,
          decoration: BoxDecoration(
            color: data.color,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: OrthaDesignColors.black,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
