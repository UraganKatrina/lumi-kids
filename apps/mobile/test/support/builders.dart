import 'package:lumi_kids/features/catalog/domain/development_area.dart';
import 'package:lumi_kids/features/content_library/domain/task.dart';

List<TaskItem> items(List<String> ids) => [
  for (final id in ids) TaskItem(id: id),
];

LearningTask buildTask({
  String id = 't',
  DevelopmentArea area = DevelopmentArea.math,
  int difficulty = 1,
  ExerciseType type = ExerciseType.choice,
  ExerciseContent? content,
  List<String> hints = const ['h1', 'h2'],
  int rewardStars = 3,
  AgeRange ageRange = const AgeRange(36, 59),
}) => LearningTask(
  id: id,
  version: 1,
  area: area,
  ageRange: ageRange,
  difficulty: difficulty,
  type: type,
  instruction: 'i',
  content:
      content ??
      ChoiceContent(options: items(['a', 'b', 'c']), correct: const {'b'}),
  hints: hints,
  rewardStars: rewardStars,
);
