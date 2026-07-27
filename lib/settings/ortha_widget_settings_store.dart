import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ortha_widget_settings.dart';

class OrthaWidgetSettingsStore {
  const OrthaWidgetSettingsStore();

  static const String androidProviderName = 'OrthaMeteoWidgetProvider';

  static const _backgroundStyleKey = 'ortha_widget_setting_background_style';
  static const _themeStyleKey = 'ortha_widget_setting_theme_style';
  static const _transparencyKey = 'ortha_widget_setting_transparency_percent';
  static const _showPlaceKey = 'ortha_widget_setting_show_place';
  static const _showTemperatureKey = 'ortha_widget_setting_show_temperature';
  static const _showWeatherIconKey = 'ortha_widget_setting_show_weather_icon';
  static const _showWarningLightKey = 'ortha_widget_setting_show_warning_light';

  static const _homeWidgetBackgroundStyleKey = 'widget_background_style';
  static const _homeWidgetThemeStyleKey = 'widget_theme_style';
  static const _homeWidgetTransparencyKey = 'widget_transparency';

  static const _homeWidgetShowPlaceKey = 'widget_show_place';
  static const _homeWidgetShowTemperatureKey = 'widget_show_temperature';
  static const _homeWidgetShowWeatherIconKey = 'widget_show_weather_icon';
  static const _homeWidgetShowWarningLightKey = 'widget_show_warning_light';

  Future<OrthaWidgetSettings> load() async {
    final preferences = await SharedPreferences.getInstance();
    const defaults = OrthaWidgetSettings.defaults;

    return OrthaWidgetSettings(
      backgroundStyle: _backgroundStyleFromName(
        preferences.getString(_backgroundStyleKey),
      ),
      themeStyle: _themeStyleFromName(preferences.getString(_themeStyleKey)),
      transparencyPercent:
          (preferences.getInt(_transparencyKey) ?? defaults.transparencyPercent)
              .clamp(0, 40),
      showPlace: preferences.getBool(_showPlaceKey) ?? defaults.showPlace,
      showTemperature:
          preferences.getBool(_showTemperatureKey) ?? defaults.showTemperature,
      showWeatherIcon:
          preferences.getBool(_showWeatherIconKey) ?? defaults.showWeatherIcon,
      showWarningLight:
          preferences.getBool(_showWarningLightKey) ??
          defaults.showWarningLight,
    );
  }

  Future<void> save(OrthaWidgetSettings settings) async {
    final preferences = await SharedPreferences.getInstance();

    // Bewusst sequenziell speichern. Parallele Schreibvorgänge in denselben
    // SharedPreferences- beziehungsweise HomeWidget-Speicher können sich
    // gegenseitig überholen.
    await preferences.setString(
      _backgroundStyleKey,
      settings.backgroundStyle.name,
    );

    await preferences.setString(_themeStyleKey, settings.themeStyle.name);

    await preferences.setInt(
      _transparencyKey,
      settings.transparencyPercent.clamp(0, 40),
    );

    await preferences.setBool(_showPlaceKey, settings.showPlace);

    await preferences.setBool(_showTemperatureKey, settings.showTemperature);

    await preferences.setBool(_showWeatherIconKey, settings.showWeatherIcon);

    await preferences.setBool(_showWarningLightKey, settings.showWarningLight);

    await syncToHomeWidget(settings);
  }

  Future<void> syncCurrentSettingsToHomeWidget() async {
    final settings = await load();
    await syncToHomeWidget(settings);
  }

  Future<void> syncToHomeWidget(
    OrthaWidgetSettings settings, {
    bool updateWidget = true,
  }) async {
    // Auch HomeWidget-Werte bewusst nacheinander schreiben.
    await HomeWidget.saveWidgetData<String>(
      _homeWidgetBackgroundStyleKey,
      settings.backgroundStyle.name,
    );

    await HomeWidget.saveWidgetData<String>(
      _homeWidgetThemeStyleKey,
      settings.themeStyle.name,
    );

    await HomeWidget.saveWidgetData<int>(
      _homeWidgetTransparencyKey,
      settings.transparencyPercent.clamp(0, 40),
    );

    // Sichtbarkeitswerte als 0/1 speichern. Das ist für die native
    // Android-Seite stabil und eindeutig.
    await HomeWidget.saveWidgetData<int>(
      _homeWidgetShowPlaceKey,
      settings.showPlace ? 1 : 0,
    );

    await HomeWidget.saveWidgetData<int>(
      _homeWidgetShowTemperatureKey,
      settings.showTemperature ? 1 : 0,
    );

    await HomeWidget.saveWidgetData<int>(
      _homeWidgetShowWeatherIconKey,
      settings.showWeatherIcon ? 1 : 0,
    );

    await HomeWidget.saveWidgetData<int>(
      _homeWidgetShowWarningLightKey,
      settings.showWarningLight ? 1 : 0,
    );

    if (updateWidget) {
      await HomeWidget.updateWidget(androidName: androidProviderName);
    }
  }

  Future<void> reset() async {
    await save(OrthaWidgetSettings.defaults);
  }

  OrthaWidgetBackgroundStyle _backgroundStyleFromName(String? name) {
    return OrthaWidgetBackgroundStyle.values.firstWhere(
      (value) => value.name == name,
      orElse: () => OrthaWidgetSettings.defaults.backgroundStyle,
    );
  }

  OrthaWidgetThemeStyle _themeStyleFromName(String? name) {
    return OrthaWidgetThemeStyle.values.firstWhere(
      (value) => value.name == name,
      orElse: () => OrthaWidgetSettings.defaults.themeStyle,
    );
  }
}
