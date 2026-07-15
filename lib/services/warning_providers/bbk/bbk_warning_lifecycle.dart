import '../../../models/warning_bridge/bbk_map_warning.dart';
import '../../../models/warning_bridge/bbk_warning.dart';

class BbkWarningLifecycle {
  const BbkWarningLifecycle();

  List<BbkMapWarning> selectCurrentMapWarnings(
    Iterable<BbkMapWarning> warnings,
  ) {
    final latestById = <String, BbkMapWarning>{};

    for (final warning in warnings) {
      final normalizedId = warning.id.trim();

      if (normalizedId.isEmpty) {
        continue;
      }

      final existing = latestById[normalizedId];

      if (existing == null || warning.version > existing.version) {
        latestById[normalizedId] = warning;
      }
    }

    final current = latestById.values
        .where((warning) => warning.isAlertOrUpdate && !warning.isCancellation)
        .toList(growable: false);

    current.sort(
      (first, second) => second.startDate.compareTo(first.startDate),
    );

    return List<BbkMapWarning>.unmodifiable(current);
  }

  bool isDetailActive(BbkWarning warning, {required DateTime moment}) {
    return warning.isActiveAt(moment);
  }
}
