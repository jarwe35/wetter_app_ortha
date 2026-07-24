import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import 'ortha_background_refresh_service.dart';

const String orthaPeriodicRefreshUniqueName =
    'ortha_periodic_weather_warning_refresh_unique';

const String orthaPeriodicRefreshTaskName =
    'ortha_periodic_weather_warning_refresh_task';

const String orthaDiagnosticRefreshTaskName =
    'ortha_diagnostic_weather_warning_refresh_task';

@pragma('vm:entry-point')
void orthaBackgroundCallbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    debugPrint(
      'ORTHA Background Ω: Callback empfangen. '
      'taskName=$taskName, inputData=$inputData',
    );

    try {
      switch (taskName) {
        case orthaPeriodicRefreshTaskName:
        case orthaDiagnosticRefreshTaskName:
          debugPrint(
            'ORTHA Background Ω: Aktualisierungsdienst wird gestartet.',
          );

          final result = await OrthaBackgroundRefreshService().refresh();

          debugPrint(
            'ORTHA Background Ω: Aufgabe erfolgreich abgeschlossen. '
            'taskName=$taskName, '
            'Ort=${result.location.name}, '
            'Warnungen=${result.warningCount}, '
            'Warnabruf erfolgreich='
            '${result.warningsLoadedSuccessfully}.',
          );

          return true;

        default:
          debugPrint(
            'ORTHA Background Ω: Unbekannter Task empfangen: $taskName',
          );

          // Ein unbekannter Task soll keine dauerhafte Wiederholungsschleife
          // verursachen.
          return true;
      }
    } catch (error, stackTrace) {
      debugPrint(
        'ORTHA Background Ω: Aufgabe fehlgeschlagen. '
        'taskName=$taskName, Fehler=$error',
      );
      debugPrintStack(stackTrace: stackTrace);

      return false;
    }
  });
}

class OrthaBackgroundService {
  const OrthaBackgroundService._();

  static bool get _isSupportedPlatform {
    if (kIsWeb) {
      return false;
    }

    return Platform.isAndroid;
  }

  static Future<void> initialize() async {
    if (!_isSupportedPlatform) {
      debugPrint('ORTHA Background Ω: Auf dieser Plattform nicht aktiviert.');
      return;
    }

    await Workmanager().initialize(orthaBackgroundCallbackDispatcher);

    debugPrint(
      'ORTHA Background Ω: WorkManager initialisiert. '
      'debugMode=$kDebugMode',
    );

    await registerPeriodicTask();

    // Während eines Debug-Laufs wird zusätzlich ein einmaliger Auftrag
    // registriert. So kann die reale Hintergrundausführung auf dem Smartphone
    // zeitnah geprüft werden, ohne auf das periodische Android-Intervall
    // warten zu müssen.
    if (kDebugMode) {
      await registerDiagnosticTask();
    }
  }

  static Future<void> registerPeriodicTask() async {
    if (!_isSupportedPlatform) {
      return;
    }

    await Workmanager().registerPeriodicTask(
      orthaPeriodicRefreshUniqueName,
      orthaPeriodicRefreshTaskName,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      constraints: Constraints(networkType: NetworkType.connected),
      inputData: const <String, dynamic>{
        'source': 'periodic',
        'engine': 'ORTHA Background Ω',
      },
    );

    debugPrint(
      'ORTHA Background Ω: Periodischer Auftrag registriert. '
      'uniqueName=$orthaPeriodicRefreshUniqueName, '
      'taskName=$orthaPeriodicRefreshTaskName',
    );
  }

  static Future<void> registerDiagnosticTask() async {
    if (!_isSupportedPlatform) {
      return;
    }

    final uniqueName =
        'ortha_diagnostic_refresh_'
        '${DateTime.now().millisecondsSinceEpoch}';

    await Workmanager().registerOneOffTask(
      uniqueName,
      orthaDiagnosticRefreshTaskName,
      initialDelay: const Duration(seconds: 10),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      constraints: Constraints(networkType: NetworkType.connected),
      inputData: const <String, dynamic>{
        'source': 'diagnostic',
        'engine': 'ORTHA Background Ω',
      },
    );

    debugPrint(
      'ORTHA Background Ω: Diagnoseauftrag registriert. '
      'uniqueName=$uniqueName, '
      'taskName=$orthaDiagnosticRefreshTaskName, '
      'Start frühestens in 10 Sekunden.',
    );
  }

  static Future<void> cancelPeriodicTask() async {
    if (!_isSupportedPlatform) {
      return;
    }

    await Workmanager().cancelByUniqueName(orthaPeriodicRefreshUniqueName);

    debugPrint('ORTHA Background Ω: Periodischer Auftrag entfernt.');
  }

  static Future<void> cancelAllTasks() async {
    if (!_isSupportedPlatform) {
      return;
    }

    await Workmanager().cancelAll();

    debugPrint('ORTHA Background Ω: Sämtliche Aufträge entfernt.');
  }
}
