import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_kids/app/providers.dart';
import 'package:lumi_kids/features/catalog/domain/development_area.dart';
import 'package:lumi_kids/features/content_library/domain/task.dart';
import 'package:lumi_kids/features/content_library/domain/task_parser.dart';

import '../../support/fakes.dart';

Map<String, Object?> validTask() => {
  'id': 'math.test.001',
  'schemaVersion': 1,
  'version': 2,
  'minAppVersion': '0.1.0',
  'area': 'math',
  'ageRange': {'minMonths': 36, 'maxMonths': 59},
  'difficulty': 1,
  'exerciseType': 'choice',
  'instruction': {
    'text': {'ru': 'Сколько?'},
  },
  'content': {
    'options': [
      {
        'id': 'a',
        'label': {'ru': '1'},
      },
      {
        'id': 'b',
        'label': {'ru': '2'},
      },
    ],
    'correct': ['b'],
  },
  'reward': {'stars': 3},
};

void main() {
  late TaskParser parser;
  setUp(() => parser = TaskParser(appVersion: '0.1.0'));

  test('стартовый пакет читается целиком, все типы на месте', () {
    final raw = loadStarterPackJson()['tasks']! as List<Object?>;
    final tasks = TaskParser(appVersion: appVersion)
        .parsePack(loadStarterPackJson());
    expect(tasks, hasLength(raw.length));
    expect(tasks.map((t) => t.type).toSet(), ExerciseType.values.toSet());
  });

  test('каждый тип упражнения читается в свою модель', () {
    final byType = {for (final t in loadStarterTasks()) t.type: t.content};
    expect(byType[ExerciseType.choice], isA<ChoiceContent>());
    expect(byType[ExerciseType.sequence], isA<SequenceContent>());
    expect(byType[ExerciseType.matchPairs], isA<MatchPairsContent>());
    expect(byType[ExerciseType.sort], isA<GroupContent>());
    expect(byType[ExerciseType.classify], isA<GroupContent>());
    expect(byType[ExerciseType.together], isA<TogetherContent>());
  });

  test('корректное задание превращается в модель', () {
    final task = parser.parseTask(validTask())!;
    expect(task.area, DevelopmentArea.math);
    expect(task.version, 2);
    expect(task.ageRange.minMonths, 36);
    expect(task.instruction, 'Сколько?');
    expect((task.content as ChoiceContent).correct, {'b'});
    expect(task.hints, isEmpty);
    expect(task.withParent, isFalse);
  });

  test('повторяющийся id задания пропускается', () {
    final tasks = parser.parsePack({
      'tasks': [validTask(), validTask()],
    });
    expect(tasks, hasLength(1));
    expect(parser.skipped.single, contains('повторяющийся'));
  });

  group('несовместимые задания пропускаются, а не ломают пакет', () {
    final cases = <String, void Function(Map<String, Object?>)>{
      'новая версия схемы': (t) => t['schemaVersion'] = 2,
      'нужна новая версия приложения': (t) => t['minAppVersion'] = '9.0.0',
      'неизвестный тип упражнения': (t) => t['exerciseType'] = 'hologram',
      'неизвестное направление': (t) => t['area'] = 'astrology',
      'правильный ответ не среди вариантов': (t) =>
          (t['content']! as Map<String, Object?>)['correct'] = ['z'],
      'поле неверного типа': (t) => t['difficulty'] = 'лёгкий',
      'возраст наоборот': (t) =>
          t['ageRange'] = {'minMonths': 50, 'maxMonths': 40},
      'последовательность из одного шага': (t) => t
        ..['exerciseType'] = 'sequence'
        ..['content'] = {
          'steps': [
            {'id': 'a'},
          ],
        },
      'предмет в несуществующей группе': (t) => t
        ..['exerciseType'] = 'sort'
        ..['content'] = {
          'groups': [
            {'id': 'g1'},
            {'id': 'g2'},
          ],
          'items': [
            {
              'item': {'id': 'x'},
              'groupId': 'g3',
            },
          ],
        },
      'занятие со взрослым без шагов': (t) => t
        ..['exerciseType'] = 'audio_instruction'
        ..['content'] = {'steps': <Object?>[]},
    };
    cases.forEach((name, mutate) {
      test(name, () {
        final broken = validTask();
        mutate(broken);
        final tasks = parser.parsePack({
          'tasks': [broken, validTask()..['id'] = 'math.test.002'],
        });
        expect(tasks.map((t) => t.id), ['math.test.002']);
        expect(parser.skipped.single, startsWith('math.test.001'));
      });
    });
  });

  test('сравнение версий', () {
    expect(compareVersions('0.1.0', '0.1.0'), 0);
    expect(compareVersions('0.2.0', '0.10.0'), lessThan(0));
    expect(compareVersions('1.0.0', '0.9.9'), greaterThan(0));
  });

  test('версия в коде совпадает с pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(
      r'^version: (\d+\.\d+\.\d+)',
      multiLine: true,
    ).firstMatch(pubspec)!.group(1);
    expect(appVersion, version);
  });
}
