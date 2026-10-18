import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_kids/features/catalog/domain/development_area.dart';
import 'package:lumi_kids/features/recommendations/domain/recommender.dart';

import '../../support/builders.dart';

void main() {
  final easyMath = buildTask(id: 'math1', difficulty: 1);
  final easyWorld = buildTask(
    id: 'world1',
    difficulty: 1,
    area: DevelopmentArea.world,
  );
  final hardMath = buildTask(id: 'math3', difficulty: 3);
  final mediumMath = buildTask(id: 'math2', difficulty: 2);

  test('без заданий рекомендации нет', () {
    expect(recommendNext([], {}), isNull);
  });

  test('новичку — самое лёгкое задание', () {
    expect(recommendNext([hardMath, easyMath], {})!.id, 'math1');
  });

  test('направления чередуются', () {
    final next = recommendNext([easyMath, easyWorld, mediumMath], {'math1': 3});
    expect(next!.id, 'world1');
  });

  test('сложность растёт только после освоения предыдущего уровня', () {
    // math1 пройдено на 1 звезду — уровень не растёт, сложное не предлагаем.
    final notMastered = recommendNext(
      [easyMath, hardMath, mediumMath],
      {'math1': 1},
    );
    expect(notMastered!.id, 'math2');

    final mastered = recommendNext(
      [easyMath, mediumMath, hardMath],
      {'math1': 3, 'math2': 3},
    );
    expect(mastered!.id, 'math3');
  });

  test('когда всё испробовано, предлагает добрать звёзды', () {
    final next = recommendNext(
      [easyMath, easyWorld],
      {'math1': 3, 'world1': 1},
    );
    expect(next!.id, 'world1');
  });

  test('когда всё пройдено на все звёзды — null', () {
    expect(recommendNext([easyMath], {'math1': 3}), isNull);
  });
}
