import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wetter_app_ortha/services/location_startup_preference_service.dart';

void main() {
  const service = LocationStartupPreferenceService();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'liefert null, wenn noch keine Standortentscheidung gespeichert ist',
    () async {
      final result = await service.loadUseCurrentLocationAtStartup();

      expect(result, isNull);
    },
  );

  test('speichert Zustimmung zur Standortnutzung', () async {
    await service.saveUseCurrentLocationAtStartup(true);

    final result = await service.loadUseCurrentLocationAtStartup();

    expect(result, isTrue);
  });

  test('speichert Ablehnung der Standortnutzung', () async {
    await service.saveUseCurrentLocationAtStartup(false);

    final result = await service.loadUseCurrentLocationAtStartup();

    expect(result, isFalse);
  });

  test('kann die gespeicherte Standortentscheidung zurücksetzen', () async {
    await service.saveUseCurrentLocationAtStartup(true);
    await service.clearUseCurrentLocationAtStartup();

    final result = await service.loadUseCurrentLocationAtStartup();

    expect(result, isNull);
  });
}
