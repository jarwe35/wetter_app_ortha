import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:wetter_app_ortha/services/warning_providers/bbk/bbk_warning_client.dart';

void main() {
  group('HttpBbkWarningClient', () {
    test('übermittelt Koordinaten und parst JSON', () async {
      final client = MockClient((request) async {
        expect(request.url.host, 'example.test');
        expect(request.url.queryParameters['latitude'], '51.4344');
        expect(request.url.queryParameters['longitude'], '6.7623');

        return Response('{"warnings":[{"identifier":"bbk-1"}]}', 200);
      });

      final warningClient = HttpBbkWarningClient(
        httpClient: client,
        endpoint: Uri.https('example.test', '/warnings'),
      );

      final result = await warningClient.fetchRawWarnings(
        latitude: 51.4344,
        longitude: 6.7623,
      );

      expect(result, isA<Map<String, dynamic>>());
    });

    test('meldet HTTP-Fehler kontrolliert', () async {
      final warningClient = HttpBbkWarningClient(
        httpClient: MockClient((request) async {
          return Response('Fehler', 503);
        }),
        endpoint: Uri.https('example.test', '/warnings'),
      );

      expect(
        () => warningClient.fetchRawWarnings(
          latitude: 51.4344,
          longitude: 6.7623,
        ),
        throwsA(isA<BbkWarningClientException>()),
      );
    });

    test('meldet ungültiges JSON kontrolliert', () async {
      final warningClient = HttpBbkWarningClient(
        httpClient: MockClient((request) async {
          return Response('kein JSON', 200);
        }),
        endpoint: Uri.https('example.test', '/warnings'),
      );

      expect(
        () => warningClient.fetchRawWarnings(
          latitude: 51.4344,
          longitude: 6.7623,
        ),
        throwsA(isA<BbkWarningClientException>()),
      );
    });
  });
}
