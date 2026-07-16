# ORTHA METEO Ω – UI-Bestandsaufnahme Sprint 0.12

## Erstellungsstand

- Branch: `develop-v0.12.0`
- Commit vor Analyse: `76dc6d6`
- Flutter: `Flutter 3.44.5 • channel stable • https://github.com/flutter/flutter.git`

## Relevante Dateien

- `lib/main.dart`
- `lib/models/official_warning_geometry.dart`
- `lib/models/official_weather_warning.dart`
- `lib/models/saved_location.dart`
- `lib/models/warning_bridge/bbk_map_warning.dart`
- `lib/models/warning_bridge/bbk_warning_geometry.dart`
- `lib/models/warning_bridge/bbk_warning.dart`
- `lib/pages/locations_page.dart`
- `lib/services/location_migration_service.dart`
- `lib/services/location_service.dart`
- `lib/services/location_storage_service.dart`
- `lib/services/official_weather_warning_service.dart`
- `lib/services/provider_based_official_weather_warning_service.dart`
- `lib/services/warning_providers/bbk/bbk_geojson_parser.dart`
- `lib/services/warning_providers/bbk/bbk_map_data_parser.dart`
- `lib/services/warning_providers/bbk/bbk_warning_client.dart`
- `lib/services/warning_providers/bbk/bbk_warning_converter.dart`
- `lib/services/warning_providers/bbk/bbk_warning_lifecycle.dart`
- `lib/services/warning_providers/bbk/bbk_warning_parser.dart`
- `lib/services/warning_providers/bbk/bbk_warning_provider.dart`
- `lib/services/warning_providers/cap_polygon_matcher.dart`
- `lib/services/warning_providers/dwd_cap_download_client.dart`
- `lib/services/warning_providers/dwd_cap_parser.dart`
- `lib/services/warning_providers/dwd_cap_zip_decoder.dart`
- `lib/services/warning_providers/dwd_warning_location_filter.dart`
- `lib/services/warning_providers/dwd_warning_provider.dart`
- `lib/services/warning_providers/empty_warning_provider.dart`
- `lib/services/warning_providers/official_warning_provider.dart`
- `lib/services/weather_service.dart`
- `lib/utils/official_warning_text_formatter.dart`
- `lib/widgets/location_search_result_dialog.dart`
- `lib/widgets/warnings/official_warning_map.dart`

## Responsive Layoutstrukturen

```text
lib/settings/unit_settings_page.dart:25:    return Scaffold(
lib/settings/unit_settings_page.dart:27:      body: ListView(
lib/main.dart:425:      ScaffoldMessenger.of(
lib/main.dart:641:    return Scaffold(
lib/main.dart:656:        child: SafeArea(
lib/main.dart:695:      body: SafeArea(
lib/main.dart:738:                    const Expanded(
lib/main.dart:802:              Expanded(
lib/main.dart:804:                    ? ListView(
lib/main.dart:837:                                Expanded(
lib/main.dart:897:                    ? ListView(
lib/main.dart:930:                                Expanded(
lib/main.dart:981:                    ? ListView(
lib/main.dart:1014:                                Expanded(
lib/main.dart:1057:                                    Expanded(
lib/main.dart:1094:                                    Expanded(
lib/main.dart:1119:                    ? ListView(
lib/main.dart:1152:                                Expanded(
lib/main.dart:1197:                                    Expanded(
lib/main.dart:1324:                    : ListView(
lib/main.dart:1410:      child: ListView.separated(
lib/main.dart:1535:              Expanded(
lib/main.dart:1569:                  Expanded(
lib/main.dart:1654:                        Expanded(
lib/main.dart:1658:                              Wrap(
lib/main.dart:1661:                                crossAxisAlignment: WrapCrossAlignment.center,
lib/main.dart:1728:                          Expanded(
lib/main.dart:1746:                        Expanded(
lib/main.dart:1915:          Expanded(
lib/main.dart:1948:              Expanded(
lib/main.dart:1985:              Expanded(
lib/main.dart:2024:            child: Wrap(
lib/main.dart:2116:              Expanded(
lib/main.dart:2151:                Expanded(
lib/main.dart:2180:              Expanded(
lib/main.dart:2228:                    Expanded(
lib/main.dart:2355:            child: ListView.separated(
lib/main.dart:2434:              Expanded(
lib/main.dart:2457:              child: LayoutBuilder(
lib/main.dart:2480:                      Expanded(
lib/main.dart:2510:                      Expanded(
lib/main.dart:2523:                      Expanded(
lib/main.dart:2536:                      Expanded(
lib/main.dart:2559:                      Expanded(child: weatherInfo),
lib/main.dart:2627:          Expanded(child: Text(text)),
lib/main.dart:2731:          Expanded(
lib/main.dart:2842:              return Expanded(
lib/main.dart:2968:              Expanded(
lib/main.dart:3038:                      Expanded(
lib/main.dart:3044:                                Expanded(
lib/pages/locations_page.dart:181:    return Scaffold(
lib/pages/locations_page.dart:196:      body: SafeArea(
lib/pages/locations_page.dart:226:                    Expanded(
lib/pages/locations_page.dart:253:            Expanded(
lib/pages/locations_page.dart:254:              child: ReorderableListView.builder(
lib/widgets/location_search_result_dialog.dart:17:          Expanded(child: Text('Ort auswählen')),
lib/widgets/location_search_result_dialog.dart:22:        child: ListView.separated(
lib/widgets/location_search_result_dialog.dart:23:          shrinkWrap: true,
lib/widgets/radar/ortha_radar_map.dart:378:              const Expanded(
lib/widgets/radar/ortha_radar_map.dart:475:              Wrap(
lib/widgets/radar/ortha_radar_map.dart:517:                Expanded(
lib/widgets/radar/ortha_radar_map.dart:529:        Wrap(
lib/widgets/radar/ortha_radar_map.dart:532:          crossAxisAlignment: WrapCrossAlignment.center,
lib/widgets/warnings/official_warning_map.dart:138:                    Expanded(
lib/widgets/warnings/official_warning_map.dart:179:                    Expanded(
```

## Fundstellen zur 7- und 14-Tage-Vorschau

```text
lib/main.dart:1338:                              forecast: data.hourlyForecast,
lib/main.dart:1359:                              forecast: data.dailyForecast,
lib/main.dart:2333:  final List<HourlyForecast> forecast;
lib/main.dart:2338:    required this.forecast,
lib/main.dart:2357:              itemCount: forecast.length,
lib/main.dart:2360:                final item = forecast[index];
lib/main.dart:2415:  final List<DailyForecast> forecast;
lib/main.dart:2420:    required this.forecast,
lib/main.dart:2436:                  '7-Tage-Vorhersage',
lib/main.dart:2448:          ...forecast.map(
lib/main.dart:3003:                          'Prognose: ${category.forecastDisplayValue}\n\n'
lib/engine/risk_engine.dart:10:  final int forecastScore;
lib/engine/risk_engine.dart:13:  final String forecastDisplayValue;
lib/engine/risk_engine.dart:21:    required this.forecastScore,
lib/engine/risk_engine.dart:24:    required this.forecastDisplayValue,
lib/engine/risk_engine.dart:35:  final List<String> forecastWarnings;
lib/engine/risk_engine.dart:44:    required this.forecastWarnings,
lib/engine/risk_engine.dart:64:    String forecastDisplayValue = '',
lib/engine/risk_engine.dart:66:    int? forecastScore,
lib/engine/risk_engine.dart:76:      forecastScore: forecastScore ?? 0,
lib/engine/risk_engine.dart:79:      forecastDisplayValue: forecastDisplayValue,
lib/engine/risk_engine.dart:94:    var forecastScore = 0;
lib/engine/risk_engine.dart:101:      if (score > forecastScore) {
lib/engine/risk_engine.dart:102:        forecastScore = score;
lib/engine/risk_engine.dart:108:    final totalScore = currentScore > forecastScore
lib/engine/risk_engine.dart:110:        : forecastScore;
lib/engine/risk_engine.dart:112:    final message = forecastScore > currentScore && peakTime != null
lib/engine/risk_engine.dart:121:      forecastDisplayValue: peakTemperature == null
lib/engine/risk_engine.dart:125:      forecastScore: forecastScore,
lib/engine/risk_engine.dart:148:    var forecastScore = 0;
lib/engine/risk_engine.dart:155:      if (score > forecastScore) {
lib/engine/risk_engine.dart:156:        forecastScore = score;
lib/engine/risk_engine.dart:162:    final totalScore = currentScore > forecastScore
lib/engine/risk_engine.dart:164:        : forecastScore;
lib/engine/risk_engine.dart:166:    final message = forecastScore > currentScore && peakTime != null
lib/engine/risk_engine.dart:175:      forecastDisplayValue: peakUv == null
lib/engine/risk_engine.dart:179:      forecastScore: forecastScore,
lib/engine/risk_engine.dart:203:    var forecastScore = 0;
lib/engine/risk_engine.dart:210:      if (score > forecastScore) {
lib/engine/risk_engine.dart:211:        forecastScore = score;
lib/engine/risk_engine.dart:217:    final totalScore = currentScore > forecastScore
lib/engine/risk_engine.dart:219:        : forecastScore;
lib/engine/risk_engine.dart:221:    final message = forecastScore > currentScore && peakTime != null
lib/engine/risk_engine.dart:230:      forecastDisplayValue: peakGusts == null
lib/engine/risk_engine.dart:234:      forecastScore: forecastScore,
lib/engine/risk_engine.dart:276:    var forecastScore = 0;
lib/engine/risk_engine.dart:287:      if (score > forecastScore ||
lib/engine/risk_engine.dart:289:              score == forecastScore &&
lib/engine/risk_engine.dart:291:        forecastScore = score;
lib/engine/risk_engine.dart:297:    final totalScore = currentScore > forecastScore
lib/engine/risk_engine.dart:299:        : forecastScore;
lib/engine/risk_engine.dart:301:    final message = currentScore > 0 && currentScore >= forecastScore
lib/engine/risk_engine.dart:303:        : forecastScore > currentScore && peakTime != null
lib/engine/risk_engine.dart:314:      forecastDisplayValue: peakProbability == null || peakTime == null
lib/engine/risk_engine.dart:318:      forecastScore: forecastScore,
lib/engine/risk_engine.dart:342:    var forecastScore = 0;
lib/engine/risk_engine.dart:349:      if (score > forecastScore ||
lib/engine/risk_engine.dart:350:          (score == forecastScore &&
lib/engine/risk_engine.dart:352:        forecastScore = score;
lib/engine/risk_engine.dart:358:    final totalScore = currentScore > forecastScore
lib/engine/risk_engine.dart:360:        : forecastScore;
lib/engine/risk_engine.dart:362:    final message = forecastScore > currentScore && peakTime != null
lib/engine/risk_engine.dart:373:      forecastDisplayValue: lowestVisibility == null || peakTime == null
lib/engine/risk_engine.dart:379:      forecastScore: forecastScore,
lib/engine/risk_engine.dart:414:    var forecastScore = 0;
lib/engine/risk_engine.dart:425:      if (score > forecastScore ||
lib/engine/risk_engine.dart:426:          (score == forecastScore &&
lib/engine/risk_engine.dart:428:        forecastScore = score;
lib/engine/risk_engine.dart:435:    final totalScore = currentScore > forecastScore
lib/engine/risk_engine.dart:437:        : forecastScore;
lib/engine/risk_engine.dart:439:    final message = forecastScore > currentScore && peakTime != null
lib/engine/risk_engine.dart:450:      forecastDisplayValue:
lib/engine/risk_engine.dart:455:      forecastScore: forecastScore,
lib/engine/risk_engine.dart:508:    final forecastWarnings = categories
lib/engine/risk_engine.dart:511:              category.forecastScore > category.currentScore &&
lib/engine/risk_engine.dart:514:        .map((category) => '${category.name}: ${category.forecastDisplayValue}')
lib/engine/risk_engine.dart:545:          forecastWarnings: forecastWarnings,
lib/engine/risk_engine.dart:557:          forecastWarnings: forecastWarnings,
lib/engine/risk_engine.dart:569:          forecastWarnings: forecastWarnings,
lib/engine/risk_engine.dart:581:          forecastWarnings: forecastWarnings,
lib/services/weather_service.dart:66:  final List<DailyForecast> dailyForecast;
lib/services/weather_service.dart:85:    required this.dailyForecast,
lib/services/weather_service.dart:152:    final weatherUrl = Uri.https('api.open-meteo.com', '/v1/forecast', {
lib/services/weather_service.dart:166:      'forecast_days': '7',
lib/services/weather_service.dart:252:    final dailyForecast = List<DailyForecast>.generate(dailyTimes.length, (
lib/services/weather_service.dart:286:      dailyForecast: dailyForecast,
test/risk_engine_test.dart:34:      dailyForecast: const [],
test/risk_engine_test.dart:84:    expect(wind.forecastScore, greaterThanOrEqualTo(60));
test/risk_engine_test.dart:86:    expect(wind.forecastDisplayValue, contains('70 km/h'));
test/risk_engine_test.dart:104:    expect(thunderstorm.forecastScore, greaterThanOrEqualTo(70));
test/risk_engine_test.dart:106:    expect(thunderstorm.forecastDisplayValue, contains('Gewitter'));
test/risk_engine_test.dart:120:    expect(heat.forecastScore, greaterThanOrEqualTo(60));
test/risk_engine_test.dart:122:    expect(heat.forecastDisplayValue, contains('34.0 °C'));
test/risk_engine_test.dart:134:    expect(uv.forecastScore, greaterThanOrEqualTo(60));
test/risk_engine_test.dart:136:    expect(uv.forecastDisplayValue, contains('UV 8.0'));
test/risk_engine_test.dart:154:    expect(visibility.forecastScore, greaterThanOrEqualTo(60));
test/risk_engine_test.dart:156:    expect(visibility.forecastDisplayValue, contains('800 m'));
test/risk_engine_test.dart:358:      expect(rain.forecastScore, 0);
test/risk_engine_test.dart:360:        rain.forecastDisplayValue,
test/risk_engine_test.dart:383:      expect(rain.forecastScore, 20);
test/risk_engine_test.dart:385:      expect(rain.forecastDisplayValue, contains('40 %'));
test/weather_service_location_test.dart:18:          expect(request.url.path, '/v1/forecast');
test/weather_service_location_test.dart:43:        expect(data.dailyForecast, hasLength(1));
```

## Größte Dart-Dateien

```text
    8320 total
    3140 lib/main.dart
     592 lib/engine/risk_engine.dart
     561 lib/widgets/radar/ortha_radar_map.dart
     383 lib/pages/locations_page.dart
     340 lib/services/warning_providers/bbk/bbk_warning_parser.dart
     289 lib/services/weather_service.dart
     263 lib/services/radar/rainviewer_radar_service.dart
     194 lib/widgets/warnings/official_warning_map.dart
     150 lib/services/location_service.dart
     147 lib/services/warning_providers/bbk/bbk_geojson_parser.dart
     144 lib/services/warning_providers/bbk/bbk_warning_client.dart
     141 lib/settings/unit_settings_page.dart
     127 lib/services/location_storage_service.dart
     126 lib/models/saved_location.dart
     125 lib/models/warning_bridge/bbk_warning.dart
     123 lib/services/warning_providers/bbk/bbk_warning_provider.dart
     116 lib/services/warning_providers/dwd_cap_parser.dart
     114 lib/services/location_migration_service.dart
     113 lib/services/warning_providers/cap_polygon_matcher.dart
     109 lib/models/warning_bridge/bbk_warning_geometry.dart
     106 lib/models/official_warning_geometry.dart
      98 lib/services/warning_providers/bbk/bbk_map_data_parser.dart
      96 lib/utils/official_warning_text_formatter.dart
      87 lib/services/warning_providers/bbk/bbk_warning_converter.dart
```
