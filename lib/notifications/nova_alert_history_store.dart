abstract class NovaAlertHistoryStore {
  Future<String?> loadLastFingerprint();

  Future<void> saveLastFingerprint(String fingerprint);

  Future<void> clear();
}
