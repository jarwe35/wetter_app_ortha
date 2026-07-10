import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

class DwdCapZipException implements Exception {
  final String message;

  const DwdCapZipException(this.message);

  @override
  String toString() => 'DwdCapZipException: $message';
}

class DwdCapZipDecoder {
  const DwdCapZipDecoder();

  List<String> decode(Uint8List zipBytes) {
    if (!_hasZipSignature(zipBytes)) {
      throw const DwdCapZipException(
        'Die gelieferten Daten sind kein gültiges ZIP-Archiv.',
      );
    }

    Archive archive;

    try {
      archive = ZipDecoder().decodeBytes(zipBytes);
    } catch (error) {
      throw DwdCapZipException(
        'DWD-ZIP-Archiv konnte nicht gelesen werden: $error',
      );
    }

    final xmlDocuments = <String>[];

    for (final file in archive.files) {
      if (!file.isFile || !file.name.toLowerCase().endsWith('.xml')) {
        continue;
      }

      try {
        final bytes = file.content as List<int>;
        xmlDocuments.add(utf8.decode(bytes));
      } catch (error) {
        throw DwdCapZipException(
          'CAP-Datei ${file.name} konnte nicht gelesen werden: $error',
        );
      }
    }

    return xmlDocuments;
  }

  bool _hasZipSignature(Uint8List bytes) {
    if (bytes.length < 4) {
      return false;
    }

    return bytes[0] == 0x50 &&
        bytes[1] == 0x4B &&
        ((bytes[2] == 0x03 && bytes[3] == 0x04) ||
            (bytes[2] == 0x05 && bytes[3] == 0x06) ||
            (bytes[2] == 0x07 && bytes[3] == 0x08));
  }
}
