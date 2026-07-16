import 'package:shared_preferences/shared_preferences.dart';

import 'nova_alert_history_store.dart';

class SharedPreferencesAlertHistoryStore implements NovaAlertHistoryStore {
  static const String fingerprintKey = 'nova_alert_last_fingerprint';

  const SharedPreferencesAlertHistoryStore();

  @override
  Future<String?> loadLastFingerprint() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.reload();

    return preferences.getString(fingerprintKey);
  }

  @override
  Future<void> saveLastFingerprint(String fingerprint) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(fingerprintKey, fingerprint);
  }

  @override
  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(fingerprintKey);
  }
}
