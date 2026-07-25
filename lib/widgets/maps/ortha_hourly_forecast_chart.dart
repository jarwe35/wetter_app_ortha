import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../services/weather_service.dart';
import '../common/ortha_premium_card.dart';

/// Helle ORTHA-Stundenprognose im Stil der Tageskarte „Heute“.
///
/// Das Widget nutzt ausschließlich die bereits vorhandenen Wetterdaten.
/// Es führt keine eigene Netzwerkanfrage aus.
class OrthaHourlyForecastChart extends StatelessWidget {
  const OrthaHourlyForecastChart({super.key, required this.forecast});

  final List<HourlyForecast> forecast;

  static const double _hourWidth = 58;
  static const double _chartHeight = 234;

  @override
  Widget build(BuildContext context) {
    final hours = forecast.take(24).toList(growable: false);

    if (hours.isEmpty) {
      return const SizedBox.shrink();
    }

    return Semantics(
      container: true,
      label: _semanticDescription(hours),
      child: OrthaPremiumCard(
        key: const Key('ortha-hourly-forecast-chart'),
        padding: const EdgeInsets.fromLTRB(18, 17, 12, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ChartHeader(),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = math.max(
                  constraints.maxWidth,
                  hours.length * _hourWidth,
                );

                return ClipRRect(
                  borderRadius: BorderRadius.circular(17),
                  child: Container(
                    color: Color(0xCC10212E),
                    child: SingleChildScrollView(
                      key: const Key('ortha-hourly-forecast-chart-scroll'),
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: SizedBox(
                        width: width,
                        height: _chartHeight,
                        child: CustomPaint(
                          painter: _ForecastPainter(
                            forecast: hours,
                            hourWidth: width / hours.length,
                            textDirection: Directionality.of(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            const _ChartLegend(),
          ],
        ),
      ),
    );
  }

  static String _semanticDescription(List<HourlyForecast> hours) {
    final temperatures = hours.map((hour) => hour.temperature);
    final minimum = temperatures.reduce(math.min);
    final maximum = temperatures.reduce(math.max);

    final maximumRain = hours
        .map((hour) => hour.precipitationProbability)
        .reduce(math.max);

    return 'Stündlicher Wetterverlauf. Temperaturen zwischen '
        '${minimum.round()} und ${maximum.round()} Grad. '
        'Höchste Niederschlagswahrscheinlichkeit '
        '$maximumRain Prozent.';
  }
}

class _ChartHeader extends StatelessWidget {
  const _ChartHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.insights_rounded, size: 23, color: OrthaDesignColors.gold),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wetterverlauf heute',
                style: TextStyle(
                  color: Color(0xFFF4F7FA),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Temperatur und Niederschlagswahrscheinlichkeit',
                style: TextStyle(
                  color: Color(0xFFADB9C7),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Text(
          '24 Std.',
          style: TextStyle(
            color: Color(0xFF9BA9B7),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _ChartLegendItem(
          icon: Icons.show_chart_rounded,
          label: 'Temperatur',
          color: OrthaDesignColors.gold,
        ),
        SizedBox(width: 18),
        Expanded(
          child: _ChartLegendItem(
            icon: Icons.water_drop_outlined,
            label: 'Niederschlag',
            color: OrthaDesignColors.blueDark,
          ),
        ),
      ],
    );
  }
}

class _ChartLegendItem extends StatelessWidget {
  const _ChartLegendItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF9BA9B7),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _ForecastPainter extends CustomPainter {
  const _ForecastPainter({
    required this.forecast,
    required this.hourWidth,
    required this.textDirection,
  });

  final List<HourlyForecast> forecast;
  final double hourWidth;
  final TextDirection textDirection;

  static const double _timeY = 10;
  static const double _iconY = 34;

  static const double _temperatureTop = 75;
  static const double _temperatureBottom = 151;

  static const double _rainTop = 169;
  static const double _rainBottom = 213;

  @override
  void paint(Canvas canvas, Size size) {
    if (forecast.isEmpty) {
      return;
    }

    final temperatures = forecast.map((hour) => hour.temperature).toList();

    var minimumTemperature = temperatures.reduce(math.min);
    var maximumTemperature = temperatures.reduce(math.max);

    if ((maximumTemperature - minimumTemperature).abs() < 1) {
      minimumTemperature -= 1;
      maximumTemperature += 1;
    } else {
      minimumTemperature -= 1.5;
      maximumTemperature += 1.5;
    }

    _drawCurrentHour(canvas, size);
    _drawGuides(canvas);
    _drawRainBars(canvas);
    _drawTemperatureArea(canvas, minimumTemperature, maximumTemperature);
    _drawTemperatureCurve(canvas, minimumTemperature, maximumTemperature);
    _drawLabels(canvas, minimumTemperature, maximumTemperature);
  }

  void _drawCurrentHour(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(3, 3, math.max(hourWidth - 6, 12), size.height - 6),
      const Radius.circular(14),
    );

    canvas.drawRRect(
      rect,
      Paint()..color = OrthaDesignColors.goldSoft.withValues(alpha: 0.20),
    );
  }

  void _drawGuides(Canvas canvas) {
    final verticalPaint = Paint()
      ..color = const Color(0xFF748493).withValues(alpha: 0.20)
      ..strokeWidth = 1;

    for (var index = 0; index < forecast.length; index++) {
      final x = _centerX(index);

      canvas.drawLine(
        Offset(x, _temperatureTop),
        Offset(x, _rainBottom),
        verticalPaint,
      );
    }

    canvas.drawLine(
      const Offset(0, _rainTop - 9),
      Offset(forecast.length * hourWidth, _rainTop - 9),
      Paint()
        ..color = const Color(0xFF748493).withValues(alpha: 0.30)
        ..strokeWidth = 1,
    );
  }

  void _drawRainBars(Canvas canvas) {
    for (var index = 0; index < forecast.length; index++) {
      final probability = forecast[index].precipitationProbability
          .clamp(0, 100)
          .toDouble();

      final color = probability >= 80
          ? OrthaDesignColors.red
          : probability >= 50
          ? OrthaDesignColors.blueDark
          : OrthaDesignColors.blue;

      final centerX = _centerX(index);
      final width = math.min(hourWidth * 0.36, 16.0);

      final track = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          centerX - width / 2,
          _rainTop,
          width,
          _rainBottom - _rainTop,
        ),
        const Radius.circular(6),
      );

      canvas.drawRRect(
        track,
        Paint()..color = const Color(0xFF8293A6).withValues(alpha: 0.36),
      );

      final height = (_rainBottom - _rainTop) * probability / 100;

      if (height <= 0) {
        continue;
      }

      final bar = RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - width / 2, _rainBottom - height, width, height),
        const Radius.circular(6),
      );

      canvas.drawRRect(bar, Paint()..color = color.withValues(alpha: 0.86));
    }
  }

  void _drawTemperatureArea(Canvas canvas, double minimum, double maximum) {
    final path = Path();

    for (var index = 0; index < forecast.length; index++) {
      final point = Offset(
        _centerX(index),
        _temperatureY(forecast[index].temperature, minimum, maximum),
      );

      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    path
      ..lineTo(_centerX(forecast.length - 1), _temperatureBottom)
      ..lineTo(_centerX(0), _temperatureBottom)
      ..close();

    final rect = Rect.fromLTRB(
      0,
      _temperatureTop,
      forecast.length * hourWidth,
      _temperatureBottom,
    );

    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x66D7A330), Color(0x0FD7A330)],
        ).createShader(rect),
    );
  }

  void _drawTemperatureCurve(Canvas canvas, double minimum, double maximum) {
    final path = Path();

    for (var index = 0; index < forecast.length; index++) {
      final point = Offset(
        _centerX(index),
        _temperatureY(forecast[index].temperature, minimum, maximum),
      );

      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.10)
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = OrthaDesignColors.gold
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );

    for (var index = 0; index < forecast.length; index++) {
      final point = Offset(
        _centerX(index),
        _temperatureY(forecast[index].temperature, minimum, maximum),
      );

      canvas.drawCircle(
        point,
        index == 0 ? 4.5 : 3.2,
        Paint()..color = OrthaDesignColors.gold,
      );

      canvas.drawCircle(
        point,
        index == 0 ? 2.1 : 1.5,
        Paint()..color = OrthaDesignColors.cream,
      );
    }
  }

  void _drawLabels(Canvas canvas, double minimum, double maximum) {
    for (var index = 0; index < forecast.length; index++) {
      final hour = forecast[index];
      final x = _centerX(index);

      final temperatureY = _temperatureY(hour.temperature, minimum, maximum);

      _drawText(
        canvas,
        text: _formatHour(hour.time),
        centerX: x,
        top: _timeY,
        color: index == 0 ? const Color(0xFFF4F7FA) : const Color(0xFF9BA9B7),
        size: 9,
        weight: index == 0 ? FontWeight.w800 : FontWeight.w600,
      );

      _drawIcon(
        canvas,
        icon: _weatherIcon(hour.weatherCode, isNight: !hour.isDay),
        centerX: x,
        top: _iconY,
      );

      _drawText(
        canvas,
        text: '${hour.temperature.round()}°',
        centerX: x,
        top: math.max(_temperatureTop - 1, temperatureY - 21),
        color: Color(0xFFF4F7FA),
        size: 10,
        weight: FontWeight.w800,
      );

      final probabilityColor = hour.precipitationProbability >= 80
          ? OrthaDesignColors.red
          : hour.precipitationProbability >= 50
          ? OrthaDesignColors.blueDark
          : const Color(0xFF9BA9B7);

      _drawText(
        canvas,
        text: '${hour.precipitationProbability}%',
        centerX: x,
        top: _rainBottom + 5,
        color: probabilityColor,
        size: 8,
        weight: FontWeight.w700,
      );
    }
  }

  void _drawIcon(
    Canvas canvas, {
    required IconData icon,
    required double centerX,
    required double top,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          color: Color(0xFF748493),
          fontSize: 21,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
        ),
      ),
      textDirection: textDirection,
    )..layout();

    painter.paint(canvas, Offset(centerX - painter.width / 2, top));
  }

  void _drawText(
    Canvas canvas, {
    required String text,
    required double centerX,
    required double top,
    required Color color,
    required double size,
    required FontWeight weight,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: size, fontWeight: weight),
      ),
      textDirection: textDirection,
      textAlign: TextAlign.center,
      maxLines: 1,
    )..layout();

    painter.paint(canvas, Offset(centerX - painter.width / 2, top));
  }

  double _centerX(int index) => index * hourWidth + hourWidth / 2;

  double _temperatureY(double temperature, double minimum, double maximum) {
    final normalized = (temperature - minimum) / (maximum - minimum);

    return _temperatureBottom -
        normalized * (_temperatureBottom - _temperatureTop);
  }

  static String _formatHour(String value) {
    final dateTime = DateTime.tryParse(value);

    if (dateTime == null) {
      return value.length >= 5 ? value.substring(value.length - 5) : value;
    }

    return '${dateTime.hour.toString().padLeft(2, '0')}:00';
  }

  static IconData _weatherIcon(int weatherCode, {required bool isNight}) {
    if (weatherCode == 0) {
      return isNight ? Icons.nightlight_round : Icons.wb_sunny_rounded;
    }

    if (weatherCode == 1 || weatherCode == 2) {
      return isNight ? Icons.nights_stay_rounded : Icons.wb_cloudy_rounded;
    }

    if (weatherCode == 3 || weatherCode == 45 || weatherCode == 48) {
      return Icons.cloud_outlined;
    }

    if ({51, 53, 55, 56, 57}.contains(weatherCode)) {
      return Icons.cloudy_snowing;
    }

    if ({61, 63, 65, 66, 67, 80, 81, 82}.contains(weatherCode)) {
      return Icons.water_drop_outlined;
    }

    if ({71, 73, 75, 77, 85, 86}.contains(weatherCode)) {
      return Icons.ac_unit_outlined;
    }

    if ({95, 96, 99}.contains(weatherCode)) {
      return Icons.thunderstorm_outlined;
    }

    return Icons.cloud_queue_outlined;
  }

  @override
  bool shouldRepaint(covariant _ForecastPainter oldDelegate) {
    return oldDelegate.forecast != forecast ||
        oldDelegate.hourWidth != hourWidth ||
        oldDelegate.textDirection != textDirection;
  }
}
