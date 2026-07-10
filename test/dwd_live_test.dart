// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:wetter_app_ortha/services/warning_providers/dwd_cap_download_client.dart';
import 'package:wetter_app_ortha/services/warning_providers/dwd_warning_provider.dart';

void main() {
  test(
    'lädt echte DWD-Warnungen für Duisburg',
    () async {
      final httpClient = http.Client();

      try {
        final provider = DwdWarningProvider(
          downloadClient: DwdCapDownloadClient(
            httpClient: httpClient,
            sourceUri: Uri.parse(
              'https://opendata.dwd.de/weather/alerts/cap/'
              'COMMUNEUNION_DWD_STAT/'
              'Z_CAP_C_EDZW_LATEST_PVW_STATUS_PREMIUMDWD_'
              'COMMUNEUNION_DE.zip',
            ),
          ),
        );

        final warnings = await provider.fetchWarnings(
          latitude: 51.4344,
          longitude: 6.7623,
        );

        print('DWD-Live-Test erfolgreich.');
        print('Warnungen für Duisburg: ${warnings.length}');

        for (final warning in warnings) {
          print('---');
          print('ID: ${warning.id}');
          print('Titel: ${warning.title}');
          print('Stufe: ${warning.severity}');
          print('Gebiete: ${warning.areaDescriptions.join(', ')}');
          print('Gültig von: ${warning.validFrom}');
          print('Gültig bis: ${warning.validUntil}');
        }

        expect(warnings, isA<List>());
      } finally {
        httpClient.close();
      }
    },
    skip: 'Nur für kontrollierte DWD-Live-Tests ausführen.',
  );
}
