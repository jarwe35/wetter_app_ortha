import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../../services/weather_service.dart';
import '../../settings/ortha_widget_settings_store.dart';
import 'ortha_widget_data.dart';

class OrthaWidgetService {
  const OrthaWidgetService._();

  static const String androidProviderName = 'OrthaMeteoWidgetProvider';

  /// Versionsnummer des aktuell vollständig geschriebenen Widget-Datensatzes.
  ///
  /// Android verwendet Widget-Daten erst dann, wenn diese Version erfolgreich
  /// als letzter Schreibschritt gespeichert wurde. Alte oder unvollständige
  /// Datensätze werden dadurch nicht mehr angezeigt.
  static const int widgetDataVersion = 2;

  static Future<void> update({
    required WeatherData weather,
    required String placeOverride,
    bool hasOfficialWarning = false,
    String? warningLevel,
  }) async {
    final data = OrthaWidgetData.fromWeather(
      weather: weather,
      placeOverride: placeOverride,
      hasOfficialWarning: hasOfficialWarning,

      warningLevel: warningLevel,
    );

    try {
      // Datensatz zunächst sperren. Sollte das Schreiben später abbrechen,
      // behandelt Android die Widget-Daten als unvollständig und zeigt einen
      // sicheren grünen Grundzustand.
      await HomeWidget.saveWidgetData<int>('widget_data_version', 0);

      await HomeWidget.saveWidgetData<String>('place', data.place);

      await HomeWidget.saveWidgetData<String>('temperature', data.temperature);

      await HomeWidget.saveWidgetData<String>(
        'apparent_temperature',
        data.apparentTemperature,
      );

      await HomeWidget.saveWidgetData<String>(
        'weather_symbol',
        data.weatherSymbol,
      );

      await HomeWidget.saveWidgetData<String>(
        'warning_label',
        data.warningLabel,
      );

      await HomeWidget.saveWidgetData<String>(
        'warning_level',
        data.warningLevel,
      );

      await HomeWidget.saveWidgetData<String>(
        'observation_time',
        data.observationTime,
      );

      for (var index = 0; index < 3; index++) {
        final day = data.days[index];
        final number = index + 1;

        await HomeWidget.saveWidgetData<String>(
          'day_${number}_label',
          day.label,
        );

        await HomeWidget.saveWidgetData<String>(
          'day_${number}_symbol',
          day.symbol,
        );

        await HomeWidget.saveWidgetData<String>(
          'day_${number}_temperature',
          day.temperature,
        );
      }

      // Erst nach dem vollständigen Schreiben aller Werte wird der Datensatz
      // für den Android-Provider freigegeben.
      await HomeWidget.saveWidgetData<int>(
        'widget_data_version',
        widgetDataVersion,
      );

      const settingsStore = OrthaWidgetSettingsStore();
      await settingsStore.syncCurrentSettingsToHomeWidget();

      await HomeWidget.updateWidget(androidName: androidProviderName);
    } catch (error, stackTrace) {
      debugPrint('ORTHA Widget Ω konnte nicht aktualisiert werden: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
