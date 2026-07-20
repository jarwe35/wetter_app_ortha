import 'package:flutter/material.dart';

import '../models/saved_location.dart';

const Color _orthaBackground = Color(0xFF07131B);
const Color _orthaSurface = Color(0xFF0D202B);
const Color _orthaSurfaceElevated = Color(0xFF132B37);
const Color _orthaBorder = Color(0xFF29424D);
const Color _orthaAccent = Color(0xFFD5AF55);
const Color _orthaPrimaryText = Color(0xFFF2F6F7);
const Color _orthaSecondaryText = Color(0xFF9EB1BA);
const Color _orthaDanger = Color(0xFFB94A48);

class LocationsPage extends StatefulWidget {
  final List<SavedLocation> locations;
  final SavedLocation? selectedLocation;
  final ValueChanged<SavedLocation> onSelect;
  final ValueChanged<SavedLocation> onDelete;
  final ValueChanged<List<SavedLocation>> onReorder;
  final void Function(SavedLocation location, String newName) onRename;
  final bool isUsingCurrentLocation;
  final bool isCurrentLocationLoading;
  final Future<void> Function() onUseCurrentLocation;

  const LocationsPage({
    super.key,
    required this.locations,
    required this.selectedLocation,
    required this.onSelect,
    required this.onDelete,
    required this.onReorder,
    required this.onRename,
    required this.isUsingCurrentLocation,
    required this.isCurrentLocationLoading,
    required this.onUseCurrentLocation,
  });

  @override
  State<LocationsPage> createState() => _LocationsPageState();
}

class _LocationsPageState extends State<LocationsPage> {
  late List<SavedLocation> orderedLocations;

  @override
  void initState() {
    super.initState();
    orderedLocations = List<SavedLocation>.from(widget.locations);
  }

  void reorderPlaces(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      final location = orderedLocations.removeAt(oldIndex);
      orderedLocations.insert(newIndex, location);
    });

    widget.onReorder(List<SavedLocation>.from(orderedLocations));
  }

  void deletePlace(SavedLocation location) {
    widget.onDelete(location);

    setState(() {
      orderedLocations.removeWhere(
        (storedLocation) =>
            storedLocation.name.trim().toLowerCase() ==
            location.name.trim().toLowerCase(),
      );
    });
  }

  void showRenameDialog(SavedLocation location) {
    final controller = TextEditingController(text: location.name);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _orthaSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: _orthaBorder.withValues(alpha: 0.85)),
          ),
          title: const Row(
            children: [
              Icon(Icons.edit_location_alt_outlined, color: _orthaAccent),
              SizedBox(width: 10),
              Text(
                'Ort umbenennen',
                style: TextStyle(
                  color: _orthaPrimaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: _orthaPrimaryText),
            decoration: InputDecoration(
              labelText: 'Neuer Name',
              labelStyle: const TextStyle(color: _orthaSecondaryText),
              filled: true,
              fillColor: _orthaSurfaceElevated,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: _orthaBorder.withValues(alpha: 0.85),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _orthaAccent, width: 1.5),
              ),
            ),
            onSubmitted: (_) {
              renamePlace(location, controller.text, dialogContext);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Abbrechen'),
            ),
            FilledButton.icon(
              onPressed: () {
                renamePlace(location, controller.text, dialogContext);
              },
              icon: const Icon(Icons.save_outlined),
              label: const Text('Speichern'),
            ),
          ],
        );
      },
    );
  }

  void renamePlace(
    SavedLocation location,
    String newName,
    BuildContext dialogContext,
  ) {
    final cleanedName = newName.trim();
    final normalizedCurrentName = location.name.trim().toLowerCase();
    final normalizedNewName = cleanedName.toLowerCase();

    final nameAlreadyExists = orderedLocations.any(
      (storedLocation) =>
          storedLocation.name.trim().toLowerCase() == normalizedNewName &&
          storedLocation.name.trim().toLowerCase() != normalizedCurrentName,
    );

    if (cleanedName.isEmpty ||
        normalizedNewName == normalizedCurrentName ||
        nameAlreadyExists) {
      Navigator.pop(dialogContext);
      return;
    }

    final index = orderedLocations.indexWhere(
      (storedLocation) =>
          storedLocation.name.trim().toLowerCase() == normalizedCurrentName,
    );

    if (index < 0) {
      Navigator.pop(dialogContext);
      return;
    }

    setState(() {
      orderedLocations[index] = orderedLocations[index].copyWith(
        name: cleanedName,
      );
    });

    widget.onRename(location, cleanedName);
    Navigator.pop(dialogContext);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _orthaBackground,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _orthaBackground,
        foregroundColor: _orthaPrimaryText,
        title: const Text(
          'Meine Orte',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _orthaPrimaryText,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 18),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _orthaSurface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: _orthaBorder.withValues(alpha: 0.85),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.swap_vert_circle_outlined,
                      color: _orthaAccent,
                      size: 28,
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Orte verwalten',
                            style: TextStyle(
                              color: _orthaPrimaryText,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Auswählen, umbenennen, löschen oder sortieren',
                            style: TextStyle(
                              color: _orthaSecondaryText,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: widget.isUsingCurrentLocation
                      ? _orthaAccent.withValues(alpha: 0.10)
                      : _orthaSurface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: widget.isUsingCurrentLocation
                        ? _orthaAccent.withValues(alpha: 0.58)
                        : _orthaBorder.withValues(alpha: 0.82),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    leading: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: widget.isUsingCurrentLocation
                            ? _orthaAccent.withValues(alpha: 0.16)
                            : _orthaSurfaceElevated,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: widget.isUsingCurrentLocation
                              ? _orthaAccent.withValues(alpha: 0.55)
                              : _orthaBorder.withValues(alpha: 0.72),
                        ),
                      ),
                      child: widget.isCurrentLocationLoading
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: _orthaAccent,
                              ),
                            )
                          : Icon(
                              widget.isUsingCurrentLocation
                                  ? Icons.my_location
                                  : Icons.my_location_outlined,
                              color: widget.isUsingCurrentLocation
                                  ? _orthaAccent
                                  : _orthaSecondaryText,
                            ),
                    ),
                    title: const Text(
                      'Mein Standort',
                      style: TextStyle(
                        color: _orthaPrimaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        widget.isCurrentLocationLoading
                            ? 'Standort wird bestimmt …'
                            : widget.isUsingCurrentLocation
                            ? 'Aktueller GPS-Standort'
                            : 'Wetter und Warnungen am Aufenthaltsort',
                        style: const TextStyle(color: _orthaSecondaryText),
                      ),
                    ),
                    trailing: widget.isCurrentLocationLoading
                        ? null
                        : Icon(
                            widget.isUsingCurrentLocation
                                ? Icons.check_circle
                                : Icons.chevron_right,
                            color: widget.isUsingCurrentLocation
                                ? _orthaAccent
                                : _orthaSecondaryText,
                          ),
                    onTap: widget.isCurrentLocationLoading
                        ? null
                        : () async {
                            await widget.onUseCurrentLocation();

                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(22, 0, 22, 10),
              child: Row(
                children: [
                  Icon(Icons.star_outline, color: _orthaAccent, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Gespeicherte Orte',
                    style: TextStyle(
                      color: _orthaPrimaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                itemCount: orderedLocations.length,
                onReorderItem: reorderPlaces,
                itemBuilder: (context, index) {
                  final location = orderedLocations[index];
                  final selected =
                      widget.selectedLocation != null &&
                      location.name.trim().toLowerCase() ==
                          widget.selectedLocation!.name.trim().toLowerCase();

                  return Container(
                    key: ValueKey(location.name.trim().toLowerCase()),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? _orthaAccent.withValues(alpha: 0.10)
                          : _orthaSurface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: selected
                            ? _orthaAccent.withValues(alpha: 0.58)
                            : _orthaBorder.withValues(alpha: 0.82),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 14,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: selected
                                ? _orthaAccent.withValues(alpha: 0.16)
                                : _orthaSurfaceElevated,
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: selected
                                  ? _orthaAccent.withValues(alpha: 0.55)
                                  : _orthaBorder.withValues(alpha: 0.72),
                            ),
                          ),
                          child: Icon(
                            selected
                                ? Icons.location_on
                                : Icons.location_on_outlined,
                            color: selected
                                ? _orthaAccent
                                : _orthaSecondaryText,
                          ),
                        ),
                        title: Text(
                          location.name,
                          style: TextStyle(
                            color: _orthaPrimaryText,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.w600,
                          ),
                        ),
                        subtitle: selected
                            ? const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text(
                                  'Aktuell ausgewählter Ort',
                                  style: TextStyle(color: _orthaSecondaryText),
                                ),
                              )
                            : null,
                        onTap: () {
                          widget.onSelect(location);
                          Navigator.pop(context);
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Ort umbenennen',
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: _orthaSecondaryText,
                              ),
                              onPressed: () => showRenameDialog(location),
                            ),
                            if (orderedLocations.length > 1)
                              IconButton(
                                tooltip: 'Ort löschen',
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: _orthaDanger,
                                ),
                                onPressed: () => deletePlace(location),
                              ),
                            ReorderableDragStartListener(
                              index: index,
                              child: const Padding(
                                padding: EdgeInsets.all(10),
                                child: Icon(
                                  Icons.drag_handle,
                                  color: _orthaSecondaryText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
