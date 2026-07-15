import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/utils/official_warning_text_formatter.dart';

void main() {
  group('OfficialWarningTextFormatter', () {
    test('wandelt HTML-Zeilenumbrüche in echte Zeilenumbrüche um', () {
      final result = OfficialWarningTextFormatter.sanitize(
        'Erste Zeile<br/>Zweite Zeile<br />Dritte Zeile',
      );

      expect(result, 'Erste Zeile\nZweite Zeile\nDritte Zeile');
    });

    test('entfernt übrige HTML-Tags', () {
      final result = OfficialWarningTextFormatter.sanitize(
        '<p><strong>Warnung</strong></p><div>Hinweis</div>',
      );

      expect(result, 'Warnung\nHinweis');
    });

    test('dekodiert gebräuchliche HTML-Zeichen', () {
      final result = OfficialWarningTextFormatter.sanitize(
        'Wasser &amp; Umwelt &quot;sicher&quot;',
      );

      expect(result, 'Wasser & Umwelt "sicher"');
    });

    test('entfernt lange Stern-Trennlinien', () {
      final result = OfficialWarningTextFormatter.sanitize(
        'Aktuelle Meldung<br/>***************<br/>Ältere Meldung',
      );

      expect(result, 'Aktuelle Meldung\n\nÄltere Meldung');
    });

    test('übernimmt kurzen Text vollständig', () {
      const text = 'Das Trinkwasser ist weiterhin nutzbar.';

      expect(OfficialWarningTextFormatter.summary(text), text);
    });

    test('kürzt langen Text lesbar', () {
      final text = List.generate(
        30,
        (index) => 'Dies ist Satz Nummer $index.',
      ).join(' ');

      final result = OfficialWarningTextFormatter.summary(
        text,
        maximumLength: 140,
      );

      expect(result.length, lessThanOrEqualTo(145));
      expect(result, endsWith('…'));
    });
  });
}
