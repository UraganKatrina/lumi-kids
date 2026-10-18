import 'package:flutter/widgets.dart';

import '../features/age_routes/domain/age_program.dart';
import '../features/catalog/domain/development_area.dart';
import '../features/content_library/data/content_repository.dart';
import '../features/parent_area/domain/parental_gate.dart';
import '../features/parent_area/domain/progress_summary.dart';
import '../features/profiles/domain/child_profile.dart';
import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart';

/// Языки интерфейса. Русский — основной: если строки нет, берётся он.
const supportedLanguages = ['ru', 'uz', 'en'];

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Подписи для доменных значений: сам домен не знает про языки.
extension DomainLabels on AppLocalizations {
  String area(DevelopmentArea area) => switch (area) {
    DevelopmentArea.speech => areaSpeech,
    DevelopmentArea.logic => areaLogic,
    DevelopmentArea.math => areaMath,
    DevelopmentArea.literacy => areaLiteracy,
    DevelopmentArea.memoryAttention => areaMemory,
    DevelopmentArea.emotionalSocial => areaEmotions,
    DevelopmentArea.selfCare => areaSelfCare,
    DevelopmentArea.creativity => areaCreativity,
    DevelopmentArea.world => areaWorld,
    DevelopmentArea.music => areaMusic,
    DevelopmentArea.movement => areaMovement,
    DevelopmentArea.languages => areaLanguages,
  };

  String program(AgeProgram program) => switch (program) {
    AgeProgram.infant => programInfant,
    AgeProgram.toddler => programToddler,
    AgeProgram.early => programEarly,
    AgeProgram.preschool => programPreschool,
    AgeProgram.schoolPrep => programSchoolPrep,
  };

  String programHint(AgeProgram program) => switch (program) {
    AgeProgram.infant => programInfantHint,
    AgeProgram.toddler => programToddlerHint,
    AgeProgram.early => programEarlyHint,
    AgeProgram.preschool => programPreschoolHint,
    AgeProgram.schoolPrep => programSchoolPrepHint,
  };

  String avatar(ChildAvatar avatar) => switch (avatar) {
    ChildAvatar.bunny => avatarBunny,
    ChildAvatar.bird => avatarBird,
    ChildAvatar.bee => avatarBee,
    ChildAvatar.paw => avatarPaw,
    ChildAvatar.flower => avatarFlower,
    ChildAvatar.star => avatarStar,
  };

  String areaStatus(AreaStatus status) => switch (status) {
    AreaStatus.notTried => statusNotTried,
    AreaStatus.trying => statusTrying,
    AreaStatus.confident => statusConfident,
  };

  String profileError(ProfileError error) => switch (error) {
    ProfileError.nameMissing => profileErrorName,
    ProfileError.nameTooLong => profileErrorNameTooLong(
      ChildProfile.maxNameLength,
    ),
    ProfileError.birthMissing => profileErrorBirth,
    ProfileError.birthInFuture => profileErrorFuture,
  };

  String contentSource(ContentSource source) => source.downloaded
      ? contentDownloaded(source.version)
      : contentBundled(source.version);

  /// Числа словами: цифры дошкольник может узнать, слова — нет.
  String number(int n) => switch (n) {
    3 => number3,
    4 => number4,
    5 => number5,
    6 => number6,
    7 => number7,
    8 => number8,
    9 => number9,
    _ => throw ArgumentError.value(n, 'n', 'ожидается число от 3 до 9'),
  };

  String gate(GateQuestion q) => gateQuestion(number(q.a), number(q.b));

  String month(int m) => [
    month1,
    month2,
    month3,
    month4,
    month5,
    month6,
    month7,
    month8,
    month9,
    month10,
    month11,
    month12,
  ][m - 1];
}
