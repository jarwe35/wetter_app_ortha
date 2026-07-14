import 'package:flutter/material.dart';

import '../models/saved_location.dart';

class LocationSearchResultDialog extends StatelessWidget {
  final List<SavedLocation> results;

  const LocationSearchResultDialog({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.location_searching_outlined),
          SizedBox(width: 10),
          Expanded(child: Text('Ort auswählen')),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: results.length,
          separatorBuilder: (_, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final location = results[index];

            return ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: Text(location.displayLabel),
              subtitle: Text(
                '${location.latitude.toStringAsFixed(4)}, '
                '${location.longitude.toStringAsFixed(4)}',
              ),
              onTap: () {
                Navigator.pop(context, location);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Abbrechen'),
        ),
      ],
    );
  }
}
