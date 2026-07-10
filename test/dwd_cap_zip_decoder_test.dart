import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/services/warning_providers/dwd_cap_zip_decoder.dart';

void main() {
  group('DwdCapZipDecoder', () {
    const decoder = DwdCapZipDecoder();

    Uint8List createZip({required Map<String, String> files}) {
      final archive = Archive();

      for (final entry in files.entries) {
        final bytes = utf8.encode(entry.value);

        archive.addFile(ArchiveFile(entry.key, bytes.length, bytes));
      }

      final encoded = ZipEncoder().encode(archive);

      return Uint8List.fromList(encoded);
    }

    test('liest einzelne CAP-XML-Datei aus ZIP-Archiv', () {
      final bytes = createZip(
        files: {
          'warning.xml': '<alert><identifier>dwd-test</identifier></alert>',
        },
      );

      final documents = decoder.decode(bytes);

      expect(documents, hasLength(1));
      expect(documents.single, contains('dwd-test'));
    });

    test('liest mehrere CAP-XML-Dateien aus ZIP-Archiv', () {
      final bytes = createZip(
        files: {
          'warning-1.xml': '<alert><identifier>warning-1</identifier></alert>',
          'warning-2.xml': '<alert><identifier>warning-2</identifier></alert>',
        },
      );

      final documents = decoder.decode(bytes);

      expect(documents, hasLength(2));
      expect(documents.join(), contains('warning-1'));
      expect(documents.join(), contains('warning-2'));
    });

    test('ignoriert Dateien die keine XML-Dateien sind', () {
      final bytes = createZip(
        files: {
          'warning.xml': '<alert><identifier>dwd-test</identifier></alert>',
          'readme.txt': 'Hinweis',
        },
      );

      final documents = decoder.decode(bytes);

      expect(documents, hasLength(1));
    });

    test('liefert leere Liste wenn ZIP keine XML-Dateien enthält', () {
      final bytes = createZip(files: {'readme.txt': 'Keine CAP-Daten'});

      final documents = decoder.decode(bytes);

      expect(documents, isEmpty);
    });

    test('wirft Exception bei ungültigen ZIP-Daten', () {
      final bytes = Uint8List.fromList(utf8.encode('kein ZIP-Archiv'));

      expect(() => decoder.decode(bytes), throwsA(isA<DwdCapZipException>()));
    });
  });
}
