import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wetter_app_ortha/pollen/dwd/dwd_pollen_download_client.dart';

void main() {
  group('DwdPollenDownloadClient', () {
    final sourceUri = Uri.parse('https://example.test/s31fg.json');

    test('liefert den Antwortinhalt bei HTTP 200', () async {
      final client = DwdPollenDownloadClient(
        sourceUri: sourceUri,
        httpClient: MockClient((request) async {
          expect(request.url, sourceUri);

          return http.Response('{"content":[]}', 200);
        }),
      );

      final result = await client.download();

      expect(result, '{"content":[]}');
    });

    test('meldet einen Fehler bei einem HTTP-Fehlerstatus', () async {
      final client = DwdPollenDownloadClient(
        sourceUri: sourceUri,
        httpClient: MockClient((_) async => http.Response('Fehler', 503)),
      );

      expect(
        client.download,
        throwsA(
          isA<DwdPollenDownloadException>().having(
            (error) => error.message,
            'message',
            contains('HTTP 503'),
          ),
        ),
      );
    });

    test('meldet einen Fehler bei leerer Antwort', () async {
      final client = DwdPollenDownloadClient(
        sourceUri: sourceUri,
        httpClient: MockClient((_) async => http.Response('   ', 200)),
      );

      expect(client.download, throwsA(isA<DwdPollenDownloadException>()));
    });

    test('kapselt Netzwerkfehler', () async {
      final client = DwdPollenDownloadClient(
        sourceUri: sourceUri,
        httpClient: MockClient((_) async {
          throw Exception('Netzwerk nicht erreichbar');
        }),
      );

      expect(
        client.download,
        throwsA(
          isA<DwdPollenDownloadException>().having(
            (error) => error.cause,
            'cause',
            isNotNull,
          ),
        ),
      );
    });
  });
}
