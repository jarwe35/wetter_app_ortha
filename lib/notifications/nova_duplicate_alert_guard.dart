import 'nova_alert_fingerprint.dart';
import 'nova_alert_history_store.dart';
import 'notification_request.dart';

class NovaDuplicateAlertGuard {
  final NovaAlertHistoryStore historyStore;
  final NovaAlertFingerprint fingerprintGenerator;

  const NovaDuplicateAlertGuard({
    required this.historyStore,
    this.fingerprintGenerator = const NovaAlertFingerprint(),
  });

  Future<bool> shouldDispatch({
    required NotificationRequest request,
    String? locationName,
  }) async {
    final fingerprint = fingerprintGenerator.create(
      request: request,
      locationName: locationName,
    );

    final previousFingerprint = await historyStore.loadLastFingerprint();

    if (previousFingerprint == fingerprint) {
      return false;
    }

    await historyStore.saveLastFingerprint(fingerprint);

    return true;
  }

  Future<void> reset() {
    return historyStore.clear();
  }
}
