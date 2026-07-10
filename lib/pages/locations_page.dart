import 'package:flutter/material.dart';

class LocationsPage extends StatefulWidget {
  final List<String> places;
  final String selectedPlace;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onDelete;
  final ValueChanged<List<String>> onReorder;
  final void Function(String oldPlace, String newPlace) onRename;

  const LocationsPage({
    super.key,
    required this.places,
    required this.selectedPlace,
    required this.onSelect,
    required this.onDelete,
    required this.onReorder,
    required this.onRename,
  });

  @override
  State<LocationsPage> createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  late List<String> orderedPlaces;

  @override
  void initState() {
    super.initState();
    orderedPlaces = List<String>.from(widget.places);
  }

  void reorderPlaces(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      final place = orderedPlaces.removeAt(oldIndex);
      orderedPlaces.insert(newIndex, place);
    });

    widget.onReorder(List<String>.from(orderedPlaces));
  }

  void deletePlace(String place) {
    widget.onDelete(place);

    setState(() {
      orderedPlaces.remove(place);
    });
  }

  void showRenameDialog(String place) {
    final controller = TextEditingController(text: place);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Ort umbenennen'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Neuer Name'),
            onSubmitted: (_) {
              renamePlace(place, controller.text, dialogContext);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () {
                renamePlace(place, controller.text, dialogContext);
              },
              child: const Text('Speichern'),
            ),
          ],
        );
      },
    );
  }

  void renamePlace(
    String oldPlace,
    String newPlace,
    BuildContext dialogContext,
  ) {
    final cleanedName = newPlace.trim();

    if (cleanedName.isEmpty ||
        cleanedName == oldPlace ||
        orderedPlaces.contains(cleanedName)) {
      Navigator.pop(dialogContext);
      return;
    }

    final index = orderedPlaces.indexOf(oldPlace);

    if (index < 0) {
      Navigator.pop(dialogContext);
      return;
    }

    setState(() {
      orderedPlaces[index] = cleanedName;
    });

    widget.onRename(oldPlace, cleanedName);
    Navigator.pop(dialogContext);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAF4F8),
        title: const Text(
          'Meine Orte',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF143642),
          ),
        ),
      ),
      body: SafeArea(
        child: ReorderableListView.builder(
          padding: const EdgeInsets.all(22),
          itemCount: orderedPlaces.length,
          onReorderItem: reorderPlaces,
          itemBuilder: (context, index) {
            final place = orderedPlaces[index];
            final selected = place == widget.selectedPlace;

            return Padding(
              key: ValueKey(place),
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: ListTile(
                  leading: Icon(
                    selected ? Icons.location_on : Icons.location_on_outlined,
                  ),
                  title: Text(
                    place,
                    style: TextStyle(
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: selected
                      ? const Text('Aktuell ausgewählter Ort')
                      : null,
                  onTap: () {
                    widget.onSelect(place);
                    Navigator.pop(context);
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Ort umbenennen',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => showRenameDialog(place),
                      ),
                      if (orderedPlaces.length > 1)
                        IconButton(
                          tooltip: 'Ort löschen',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => deletePlace(place),
                        ),
                      const Icon(Icons.drag_handle),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
