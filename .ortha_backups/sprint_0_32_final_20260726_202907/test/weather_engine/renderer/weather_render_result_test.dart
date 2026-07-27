import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/weather_engine/weather_engine.dart';

void main() {
  group('WeatherRenderResult', () {
    test('completed erzeugt erfolgreiches Ergebnis', () {
      final result = WeatherRenderResult<String>.completed(
        output: 'rendered-frame',
        renderDuration: const Duration(milliseconds: 18),
      );

      expect(result.isSuccessful, isTrue);
      expect(result.hasFailed, isFalse);
      expect(result.output, 'rendered-frame');
      expect(result.status, WeatherRenderStatus.completed);
    });

    test('failed erzeugt Fehlerergebnis', () {
      final result = WeatherRenderResult<String>.failed(
        error: StateError('render failed'),
      );

      expect(result.isSuccessful, isFalse);
      expect(result.hasFailed, isTrue);
      expect(result.output, isNull);
      expect(result.error, isA<StateError>());
      expect(result.status, WeatherRenderStatus.failed);
    });
  });
}
