import 'package:flutter/material.dart';

import '../../age_routes/domain/age_program.dart';

/// Встроенные аватары: ребёнок не загружает фото.
enum ChildAvatar {
  bunny('bunny', 'Зайчик', Icons.cruelty_free_rounded, Color(0xFFE5793B)),
  bird('bird', 'Птичка', Icons.flutter_dash_rounded, Color(0xFF3A86C8)),
  bee('bee', 'Пчёлка', Icons.emoji_nature_rounded, Color(0xFFC79A00)),
  paw('paw', 'Котёнок', Icons.pets_rounded, Color(0xFF8E5BC9)),
  flower('flower', 'Цветок', Icons.local_florist_rounded, Color(0xFFD9488F)),
  star('star', 'Звёздочка', Icons.star_rounded, Color(0xFF2E9E5B));

  const ChildAvatar(this.code, this.title, this.icon, this.color);

  final String code;
  final String title;
  final IconData icon;
  final Color color;

  static ChildAvatar fromCode(String code) =>
      values.firstWhere((a) => a.code == code, orElse: () => bunny);
}

/// Профиль ребёнка. Храним только прозвище, год и месяц рождения и аватар:
/// без фамилии, фото, голоса и точной даты рождения.
class ChildProfile {
  const ChildProfile({
    required this.id,
    required this.name,
    required this.birthYear,
    required this.birthMonth,
    required this.avatar,
  });

  static const maxNameLength = 20;

  final String id;
  final String name;
  final int birthYear;

  /// 1–12.
  final int birthMonth;
  final ChildAvatar avatar;

  /// Полных месяцев на дату [now]; день рождения внутри месяца не учитываем.
  int ageInMonths(DateTime now) =>
      (now.year - birthYear) * 12 + now.month - birthMonth;

  AgeProgram programAt(DateTime now) => AgeProgram.forMonths(ageInMonths(now));

  ChildProfile copyWith({
    String? name,
    int? birthYear,
    int? birthMonth,
    ChildAvatar? avatar,
  }) => ChildProfile(
    id: id,
    name: name ?? this.name,
    birthYear: birthYear ?? this.birthYear,
    birthMonth: birthMonth ?? this.birthMonth,
    avatar: avatar ?? this.avatar,
  );
}

/// Текст ошибки для формы профиля или null, если всё верно.
String? validateProfile({
  required String name,
  required int? birthYear,
  required int? birthMonth,
  required DateTime now,
}) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return 'Введите имя или прозвище';
  if (trimmed.length > ChildProfile.maxNameLength) {
    return 'Имя слишком длинное, до ${ChildProfile.maxNameLength} букв';
  }
  if (birthYear == null || birthMonth == null) {
    return 'Выберите год и месяц рождения';
  }
  if (birthYear * 12 + birthMonth > now.year * 12 + now.month) {
    return 'Дата рождения не может быть в будущем';
  }
  return null;
}

abstract interface class ProfileRepository {
  /// Профили в порядке создания.
  Future<List<ChildProfile>> loadAll();

  /// Создаёт профиль или обновляет существующий с тем же id.
  Future<void> save(ChildProfile profile);

  /// Удаляет профиль и весь его прогресс.
  Future<void> delete(String childId);

  /// Удаляет все профили, прогресс и настройки на устройстве.
  Future<void> deleteEverything();

  Future<String?> activeChildId();

  Future<void> setActiveChild(String childId);
}
