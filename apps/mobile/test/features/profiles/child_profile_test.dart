import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_kids/features/age_routes/domain/age_program.dart';
import 'package:lumi_kids/features/profiles/domain/child_profile.dart';

ChildProfile born(int year, int month) => ChildProfile(
  id: 'k',
  name: 'Маша',
  birthYear: year,
  birthMonth: month,
  avatar: ChildAvatar.bunny,
);

final now = DateTime(2026, 10, 18);

void main() {
  test('возраст считается в полных месяцах', () {
    expect(born(2026, 10).ageInMonths(now), 0);
    expect(born(2025, 11).ageInMonths(now), 11);
    expect(born(2025, 10).ageInMonths(now), 12);
    expect(born(2022, 4).ageInMonths(now), 54);
  });

  test('программа выбирается по возрасту, границы включительно', () {
    expect(born(2025, 11).programAt(now), AgeProgram.infant);
    expect(born(2025, 10).programAt(now), AgeProgram.toddler);
    expect(born(2024, 10).programAt(now), AgeProgram.early);
    expect(born(2023, 10).programAt(now), AgeProgram.preschool);
    expect(born(2021, 11).programAt(now), AgeProgram.preschool);
    expect(born(2021, 10).programAt(now), AgeProgram.schoolPrep);
    // Старше 7 лет остаёмся на подготовке к школе.
    expect(born(2018, 1).programAt(now), AgeProgram.schoolPrep);
  });

  test('проверка формы', () {
    String? check(String name, int? y, int? m) =>
        validateProfile(name: name, birthYear: y, birthMonth: m, now: now);

    expect(check('Маша', 2022, 5), isNull);
    expect(check('  ', 2022, 5), isNotNull);
    expect(check('А' * 21, 2022, 5), isNotNull);
    expect(check('Маша', null, 5), isNotNull);
    expect(check('Маша', 2026, 10), isNull);
    expect(check('Маша', 2026, 11), contains('будущем'));
  });

  test('неизвестный аватар не ломает профиль', () {
    expect(ChildAvatar.fromCode('dragon'), ChildAvatar.bunny);
    expect(ChildAvatar.fromCode('star'), ChildAvatar.star);
  });
}
