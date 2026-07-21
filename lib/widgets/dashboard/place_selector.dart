import 'package:flutter/material.dart';

import '../../models/saved_location.dart';
import '../ortha_ui/ortha_responsive.dart';

class PlaceSelector extends StatelessWidget {
  final List<SavedLocation> locations;
  final SavedLocation? selectedLocation;
  final ValueChanged<SavedLocation> onSelect;
  final ValueChanged<SavedLocation> onDelete;

  const PlaceSelector({
    super.key,
    required this.locations,
    required this.selectedLocation,
    required this.onSelect,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final ui = OrthaResponsive.of(context);
    final chipHeight = ui.isPhone ? 46.0 : 50.0;
    final chipFontSize = ui.isPhone ? 14.0 : 15.0;

    return SizedBox(
      height: chipHeight,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: ui.horizontalPadding * 0.25),
        scrollDirection: Axis.horizontal,
        itemCount: locations.length,
        separatorBuilder: (_, index) => SizedBox(width: ui.cardSpacing * 0.7),
        itemBuilder: (context, index) {
          final location = locations[index];
          final selected =
              selectedLocation?.name.trim().toLowerCase() ==
              location.name.trim().toLowerCase();

          return InputChip(
            label: Text(
              location.name,
              style: TextStyle(fontSize: chipFontSize),
            ),
            selected: selected,
            onPressed: () {
              onSelect(location);
            },
            onDeleted: locations.length > 1
                ? () {
                    onDelete(location);
                  }
                : null,
          );
        },
      ),
    );
  }
}
