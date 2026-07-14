import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:wetter_app_ortha/services/warning_providers/bbk/bbk_warning_client.dart';

void main() {
  group('HttpBbkWarningClient', () {
    test('alter Koordinatenabruf bleibt kompatibel', () async {
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

    test('ruft reale MapData-Pfadstruktur ab', () async {
      final client = MockClient((request) async {
        expect(request.url.scheme, 'https');
        expect(request.url.host, 'warnung.bund.de');
        expect(request.url.path, '/api31/mowas/mapData.json');

        return Response('[]', 200);
      });

      final warningClient = HttpBbkWarningClient(
        httpClient: client,
        endpoint: Uri.https('example.test', '/legacy'),
      );

      final result = await warningClient.fetchMapData();

      expect(result, isA<List<dynamic>>());
    });

    test('ruft Warndetail über Warn-ID ab', () async {
      const warningId = 'mow.DE-SL-SLS-W038-20260113-000';

      final client = MockClient((request) async {
        expect(request.url.path, '/api31/warnings/$warningId.json');

        return Response('{"identifier":"$warningId","info":[]}', 200);
      });

      final warningClient = HttpBbkWarningClient(
        httpClient: client,
        endpoint: Uri.https('example.test', '/legacy'),
      );

      final result = await warningClient.fetchWarningDetail(warningId);

      expect(result, isA<Map<String, dynamic>>());
      expect(result['identifier'], warningId);
    });

    test('ruft Warngeometrie über Warn-ID ab', () async {
      const warningId = 'mow.DE-SL-SLS-W038-20260113-000';

      final client = MockClient((request) async {
        expect(request.url.path, '/api31/warnings/$warningId.geojson');

        return Response('{"type":"FeatureCollection","features":[]}', 200);
      });

      final warningClient = HttpBbkWarningClient(
        httpClient: client,
        endpoint: Uri.https('example.test', '/legacy'),
      );

      final result = await warningClient.fetchWarningGeometry(warningId);

      expect(result, isA<Map<String, dynamic>>());
      expect(result['type'], 'FeatureCollection');
    });

    test('erlaubt überschreibbare Basis-URI', () async {
      final client = MockClient((request) async {
        expect(request.url.host, 'bbk.test');
        expect(request.url.path, '/custom/mowas/mapData.json');

        return Response('[]', 200);
      });

      final warningClient = HttpBbkWarningClient(
        httpClient: client,
        endpoint: Uri.https('example.test', '/legacy'),
        warningBaseUri: Uri.https('bbk.test', '/custom/'),
      );

      await warningClient.fetchMapData();
    });

    test('lehnt leere Warn-ID vor HTTP-Abruf ab', () async {
      var requestCount = 0;

      final warningClient = HttpBbkWarningClient(
        httpClient: MockClient((request) async {
          requestCount++;
          return Response('{}', 200);
        }),
        endpoint: Uri.https('example.test', '/legacy'),
      );

      expect(
        () => warningClient.fetchWarningDetail('   '),
        throwsA(isA<BbkWarningClientException>()),
      );

      expect(requestCount, 0);
    });

    test('meldet HTTP-Fehler kontrolliert', () async {
      final warningClient = HttpBbkWarningClient(
        httpClient: MockClient((request) async {
          return Response('Fehler', 503);
        }),
        endpoint: Uri.https('example.test', '/legacy'),
      );

      expect(
        () => warningClient.fetchMapData(),
        throwsA(isA<BbkWarningClientException>()),
      );
    });

    test('meldet ungültiges JSON kontrolliert', () async {
      final warningClient = HttpBbkWarningClient(
        httpClient: MockClient((request) async {
          return Response('kein JSON', 200);
        }),
        endpoint: Uri.https('example.test', '/legacy'),
      );

      expect(
        () => warningClient.fetchMapData(),
        throwsA(isA<BbkWarningClientException>()),
      );
    });

    test('dekodiert UTF-8-Warndaten korrekt', () async {
      final client = MockClient((request) async {
        return Response.bytes(
          utf8.encode('{"headline":"Starkes Gewitter über Düsseldorf"}'),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final warningClient = HttpBbkWarningClient(
        httpClient: client,
        endpoint: Uri.https('example.test', '/legacy'),
      );

      final result = await warningClient.fetchMapData();

      expect(result['headline'], 'Starkes Gewitter über Düsseldorf');
    });
  });
}
