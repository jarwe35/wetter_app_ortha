import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import 'ortha_background_refresh_service.dart';

const String orthaPeriodicRefreshUniqueName =
    'ortha_periodic_weather_warning_refresh';

const String orthaPeriodicRefreshTaskName = 'ortha_weather_warning_refresh';

const String orthaOneOffRefreshUniqueName =
    'ortha_one_off_weather_warning_refresh';

@pragma('vm:entry-point')
void orthaBackgroundCallbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    debugPrint('ORTHA Background Ω: Aufgabe gestartet: $taskName');

    try {
      switch (taskName) {
        case orthaPeriodicRefreshTaskName:
        case orthaOneOffRefreshUniqueName:
          final result = await OrthaBackgroundRefreshService().refresh();

          debugPrint(
            'ORTHA Background Ω: Aufgabe erfolgreich. '
            'Ort=${result.location.name}, '
            'Warnungen=${result.warningCount}, '
            'Warnabruf erfolgreich='
            '${result.warningsLoadedSuccessfully}.',
          );

          return true;

        default:
          debugPrint('ORTHA Background Ω: Unbekannte Aufgabe: $taskName');

          return true;
      }
    } catch (error, stackTrace) {
      debugPrint('ORTHA Background Ω: Aufgabe fehlgeschlagen: $error');
      debugPrintStack(stackTrace: stackTrace);

      // false signalisiert WorkManager, dass die Aufgabe nicht erfolgreich
      // abgeschlossen wurde.
      return false;
    }
  });
}

class OrthaBackgroundService {
  const OrthaBackgroundService._();

  static Future<void> initialize() async {
    if (kIsWeb) {
      return;
    }

    await Workmanager().initialize(orthaBackgroundCallbackDispatcher);

    await registerPeriodicTask();
  }

  static Future<void> registerPeriodicTask() async {
    if (kIsWeb) {
      return;
    }

    await Workmanager().registerPeriodicTask(
      orthaPeriodicRefreshUniqueName,
      orthaPeriodicRefreshTaskName,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      constraints: Constraints(networkType: NetworkType.connected),
    );

    debugPrint('ORTHA Background Ω: Periodische Aktualisierung registriert.');
  }

  /// Startet eine zusätzliche einmalige Hintergrundaktualisierung.
  ///
  /// Diese Methode ist für Diagnosezwecke und spätere manuelle
  /// Aktualisierungsschaltflächen vorgesehen.
  static Future<void> registerOneOffTask() async {
    if (kIsWeb) {
      return;
    }

    await Workmanager().registerOneOffTask(
      orthaOneOffRefreshUniqueName,
      orthaOneOffRefreshUniqueName,
      existingWorkPolicy: ExistingWorkPolicy.replace,
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static Future<void> cancelPeriodicTask() async {
    if (kIsWeb) {
      return;
    }

    await Workmanager().cancelByUniqueName(orthaPeriodicRefreshUniqueName);
  }
}
