/// Настройки приложения для взрослого.
abstract interface class AppSettingsRepository {
  /// Выбранный язык (ru, uz, en); null — как в телефоне.
  Future<String?> language();

  Future<void> setLanguage(String language);
}

/// Язык, на котором показываем приложение: выбранный, иначе язык телефона,
/// если мы его поддерживаем, иначе русский.
String effectiveLanguage({
  required String? chosen,
  required String deviceLanguage,
  required List<String> supported,
}) {
  if (chosen != null && supported.contains(chosen)) return chosen;
  if (supported.contains(deviceLanguage)) return deviceLanguage;
  return 'ru';
}
