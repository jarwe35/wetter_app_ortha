import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wetter_app_ortha/notifications/shared_preferences_alert_history_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('liefert ohne gespeicherten Fingerprint null', () async {
    final store = SharedPreferencesAlertHistoryStore();

    final fingerprint = await store.loadLastFingerprint();

    expect(fingerprint, isNull);
  });

  test('speichert und lädt einen Fingerprint', () async {
    final store = SharedPreferencesAlertHistoryStore();

    await store.saveLastFingerprint('warning|duisburg|sturm');

    final fingerprint = await store.loadLastFingerprint();

    expect(fingerprint, 'warning|duisburg|sturm');
  });

  test('überschreibt einen vorhandenen Fingerprint', () async {
    final store = SharedPreferencesAlertHistoryStore();

    await store.saveLastFingerprint('warning|duisburg|sturm');

    await store.saveLastFingerprint('emergency|duisburg|unwetter');

    final fingerprint = await store.loadLastFingerprint();

    expect(fingerprint, 'emergency|duisburg|unwetter');
  });

  test('entfernt den gespeicherten Fingerprint', () async {
    final store = SharedPreferencesAlertHistoryStore();

    await store.saveLastFingerprint('warning|duisburg|sturm');

    await store.clear();

    final fingerprint = await store.loadLastFingerprint();

    expect(fingerprint, isNull);
  });
}
