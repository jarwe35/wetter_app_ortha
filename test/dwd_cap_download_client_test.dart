import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:wetter_app_ortha/services/warning_providers/dwd_cap_download_client.dart';

void main() {
  group('DwdCapDownloadClient', () {
    final sourceUri = Uri.parse('https://example.test/dwd-cap.zip');

    test('liefert Binärdaten bei erfolgreichem HTTP-Abruf', () async {
      final expectedBytes = Uint8List.fromList([80, 75, 3, 4]);

      final mockClient = MockClient((request) async {
        expect(request.url, sourceUri);

        return Response.bytes(expectedBytes, 200);
      });

      final client = DwdCapDownloadClient(
        httpClient: mockClient,
        sourceUri: sourceUri,
      );

      final result = await client.download();

      expect(result, expectedBytes);
    });

    test('wirft Exception bei HTTP-Fehler', () async {
      final mockClient = MockClient((request) async {
        return Response('Serverfehler', 503);
      });

      final client = DwdCapDownloadClient(
        httpClient: mockClient,
        sourceUri: sourceUri,
      );

      expect(
        client.download,
        throwsA(
          isA<DwdCapDownloadException>().having(
            (error) => error.message,
            'message',
            contains('HTTP 503'),
          ),
        ),
      );
    });

    test('wirft Exception bei leerer Antwort', () async {
      final mockClient = MockClient((request) async {
        return Response.bytes(Uint8List(0), 200);
      });

      final client = DwdCapDownloadClient(
        httpClient: mockClient,
        sourceUri: sourceUri,
      );

      expect(
        client.download,
        throwsA(
          isA<DwdCapDownloadException>().having(
            (error) => error.message,
            'message',
            contains('keine Warndaten'),
          ),
        ),
      );
    });

    test('wandelt Netzwerkfehler in definierte Exception um', () async {
      final mockClient = MockClient((request) async {
        throw const SocketException('Keine Netzwerkverbindung');
      });

      final client = DwdCapDownloadClient(
        httpClient: mockClient,
        sourceUri: sourceUri,
      );

      expect(
        client.download,
        throwsA(
          isA<DwdCapDownloadException>().having(
            (error) => error.message,
            'message',
            contains('Netzwerkfehler'),
          ),
        ),
      );
    });
  });
}
