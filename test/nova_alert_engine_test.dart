import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/engine/recommendation_engine.dart';
import 'package:wetter_app_ortha/engine/risk_engine.dart';
import 'package:wetter_app_ortha/notifications/notification_level.dart';
import 'package:wetter_app_ortha/notifications/nova_alert_engine.dart';

void main() {
  const engine = NovaAlertEngine();

  RiskResult risk(RiskLevel level, {String message = 'Testmeldung'}) {
    return RiskResult(
      level: level,
      score: 50,
      title: 'Testlage',
      message: message,
      factors: const [],
      forecastWarnings: const [],
    );
  }

  test('erzeugt bei grüner Risikolage keine Warnung', () {
    final request = engine.evaluate(risk: risk(RiskLevel.green));

    expect(request, isNull);
  });

  test('erzeugt bei gelber Risikolage einen Wetterhinweis', () {
    final request = engine.evaluate(
      risk: risk(RiskLevel.yellow),
      locationName: 'Duisburg',
    );

    expect(request, isNotNull);
    expect(request!.level, NotificationLevel.information);
    expect(request.title, 'NOVA Wetterhinweis für Duisburg');
    expect(request.message, 'Testmeldung');
    expect(request.playSound, isFalse);
    expect(request.speakMessage, isFalse);
  });

  test('erzeugt bei oranger Risikolage eine akustische Warnung', () {
    final request = engine.evaluate(risk: risk(RiskLevel.orange));

    expect(request, isNotNull);
    expect(request!.level, NotificationLevel.warning);
    expect(request.title, 'NOVA Wetterwarnung');
    expect(request.playSound, isTrue);
    expect(request.speakMessage, isFalse);
  });

  test('erzeugt bei roter Risikolage eine gesprochene Akutwarnung', () {
    final request = engine.evaluate(risk: risk(RiskLevel.red));

    expect(request, isNotNull);
    expect(request!.level, NotificationLevel.emergency);
    expect(request.title, 'NOVA Akutwarnung');
    expect(request.playSound, isTrue);
    expect(request.speakMessage, isTrue);
  });

  test('verwendet vorhandene Handlungsempfehlung als Warntext', () {
    const recommendation = Recommendation(
      priority: RecommendationPriority.high,
      title: 'Schutzmaßnahmen',
      description: 'Außenbereiche meiden und Fenster schließen.',
    );

    final request = engine.evaluate(
      risk: risk(RiskLevel.orange, message: 'Allgemeine Risikomeldung'),
      recommendation: recommendation,
    );

    expect(request!.message, 'Außenbereiche meiden und Fenster schließen.');
  });

  test('ignoriert einen leeren Ortsnamen', () {
    final request = engine.evaluate(
      risk: risk(RiskLevel.yellow),
      locationName: '   ',
    );

    expect(request!.title, 'NOVA Wetterhinweis');
  });
}
