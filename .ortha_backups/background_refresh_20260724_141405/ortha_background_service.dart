import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';

/// ORTHA Background Engine Ω
///
/// Führt die periodische Hintergrundaktualisierung des Android-Widgets aus.
///
/// Hinweis:
/// Android WorkManager garantiert kein sekundengenaues Intervall. Die Aufgabe
/// wird frühestens ungefähr alle 15 Minuten ausgeführt und kann durch
/// Energiesparmechanismen verzögert werden.
class OrthaBackgroundService {
  const OrthaBackgroundService._();

  static const String periodicTaskUniqueName =
      'ortha-periodic-warning-widget-refresh';

  static const String periodicTaskName = 'orthaPeriodicWarningWidgetRefresh';

  static const String androidWidgetProviderName = 'OrthaMeteoWidgetProvider';

  static Future<void> initialize() async {
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }

    await Workmanager().initialize(orthaBackgroundCallbackDispatcher);

    await Workmanager().registerPeriodicTask(
      periodicTaskUniqueName,
      periodicTaskName,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      constraints: Constraints(networkType: NetworkType.connected),
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 15),
    );

    debugPrint(
      'ORTHA Background Engine Ω: '
      '15-Minuten-Aktualisierung registriert.',
    );
  }

  /// Kann während der Entwicklung verwendet werden, um die Hintergrundaufgabe
  /// einmalig zeitnah auszuführen.
  static Future<void> registerTestRefresh() async {
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }

    await Workmanager().registerOneOffTask(
      'ortha-widget-test-${DateTime.now().millisecondsSinceEpoch}',
      periodicTaskName,
      constraints: Constraints(networkType: NetworkType.connected),
      initialDelay: const Duration(seconds: 10),
    );
  }

  static Future<void> cancel() async {
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }

    await Workmanager().cancelByUniqueName(periodicTaskUniqueName);
  }
}

@pragma('vm:entry-point')
void orthaBackgroundCallbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      switch (taskName) {
        case OrthaBackgroundService.periodicTaskName:
          await HomeWidget.updateWidget(
            androidName: OrthaBackgroundService.androidWidgetProviderName,
          );

          debugPrint(
            'ORTHA Background Engine Ω: '
            'Widget-Aktualisierung erfolgreich.',
          );

          return true;

        default:
          debugPrint(
            'ORTHA Background Engine Ω: '
            'Unbekannte Aufgabe: $taskName',
          );

          return true;
      }
    } catch (error, stackTrace) {
      debugPrint('ORTHA Background Engine Ω fehlgeschlagen: $error');
      debugPrintStack(stackTrace: stackTrace);

      return false;
    }
  });
}
