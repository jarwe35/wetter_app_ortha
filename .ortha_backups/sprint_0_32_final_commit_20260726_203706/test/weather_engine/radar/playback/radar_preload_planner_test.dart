import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/weather_engine/weather_engine.dart';

void main() {
  group('RadarPreloadPlanner', () {
    test('plant folgende und vorherige Frames', () {
      const planner = RadarPreloadPlanner<String>(
        lookAhead: 2,
        lookBehind: 1,
        wrapAround: false,
      );

      final plan = planner.createPlan(
        frames: const <String>[
          'frame-0',
          'frame-1',
          'frame-2',
          'frame-3',
          'frame-4',
        ],
        currentIndex: 2,
      );

      expect(plan, const <String>['frame-3', 'frame-4', 'frame-1']);
    });

    test('wrapAround plant Frames am Listenanfang', () {
      const planner = RadarPreloadPlanner<String>(
        lookAhead: 3,
        lookBehind: 0,
        wrapAround: true,
      );

      final plan = planner.createPlan(
        frames: const <String>['frame-0', 'frame-1', 'frame-2', 'frame-3'],
        currentIndex: 3,
      );

      expect(plan, const <String>['frame-0', 'frame-1', 'frame-2']);
    });

    test('dupliziert keine Frames', () {
      const planner = RadarPreloadPlanner<String>(
        lookAhead: 8,
        lookBehind: 8,
        wrapAround: true,
      );

      final plan = planner.createPlan(
        frames: const <String>['frame-0', 'frame-1', 'frame-2'],
        currentIndex: 0,
      );

      expect(plan, hasLength(2));
      expect(plan.toSet(), hasLength(2));
      expect(plan, isNot(contains('frame-0')));
    });

    test('liefert bei leerer Timeline leeren Plan', () {
      const planner = RadarPreloadPlanner<String>();

      final plan = planner.createPlan(
        frames: const <String>[],
        currentIndex: 0,
      );

      expect(plan, isEmpty);
    });

    test('weist ungültigen Index zurück', () {
      const planner = RadarPreloadPlanner<String>();

      expect(
        () => planner.createPlan(
          frames: const <String>['frame-0', 'frame-1'],
          currentIndex: 4,
        ),
        throwsRangeError,
      );
    });

    test('ohne wrapAround ignoriert Listenränder', () {
      const planner = RadarPreloadPlanner<String>(
        lookAhead: 3,
        lookBehind: 3,
        wrapAround: false,
      );

      final plan = planner.createPlan(
        frames: const <String>['frame-0', 'frame-1', 'frame-2'],
        currentIndex: 0,
      );

      expect(plan, const <String>['frame-1', 'frame-2']);
    });
  });
}
