import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/services/weather_service.dart';
import 'package:wetter_app_ortha/widgets/maps/ortha_hourly_forecast_chart.dart';

void main() {
  const forecast = [
    HourlyForecast(
      time: '2026-07-23T11:00',
      temperature: 21,
      apparentTemperature: 21,
      humidity: 60,
      windGusts: 18,
      uvIndex: 4,
      weatherCode: 1,
      precipitationProbability: 10,
      visibility: 10000,
    ),
    HourlyForecast(
      time: '2026-07-23T12:00',
      temperature: 23,
      apparentTemperature: 24,
      humidity: 58,
      windGusts: 20,
      uvIndex: 5,
      weatherCode: 61,
      precipitationProbability: 55,
      visibility: 9000,
    ),
    HourlyForecast(
      time: '2026-07-23T13:00',
      temperature: 22,
      apparentTemperature: 23,
      humidity: 65,
      windGusts: 24,
      uvIndex: 3,
      weatherCode: 95,
      precipitationProbability: 80,
      visibility: 7000,
    ),
  ];

  testWidgets('zeigt Tagesverlaufsdiagramm mit Prognosedaten', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: OrthaHourlyForecastChart(forecast: forecast)),
      ),
    );

    expect(
      find.byKey(const Key('ortha-hourly-forecast-chart')),
      findsOneWidget,
    );
    expect(find.text('Wetterverlauf heute'), findsOneWidget);
    expect(find.text('24 Std.'), findsOneWidget);
  });

  testWidgets('bleibt bei leerer Prognose unsichtbar', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: OrthaHourlyForecastChart(forecast: [])),
      ),
    );

    expect(find.byKey(const Key('ortha-hourly-forecast-chart')), findsNothing);
  });
}
