# LUMI Kids

Образовательное приложение для детей 0–7 лет (Flutter, Android и iOS).

## Состояние

Этап 3: первый рабочий прототип. Карта из 12 островов-направлений,
персонаж Люми, задания с выбором ответа из встроенного стартового пакета,
подсказки после ошибки, экран результата и сохранение прогресса на устройстве.

## Структура

- `apps/mobile/` — Flutter-приложение
- `content/` — схема заданий и проверка контента
- `docs/` — [архитектура](docs/architecture.md), [модели данных](docs/data-model.md),
  [план тестирования](docs/testing-plan.md)

## Проверка приложения

```bash
cd apps/mobile
flutter pub get
flutter analyze
flutter test
flutter run            # на подключённом телефоне или эмуляторе
```

После изменения таблиц в `lib/features/progress/data/progress_database.dart`
перегенерируйте код: `dart run build_runner build`.

## Автосборка

При каждом изменении GitHub Actions проверяет форматирование, запускает
`flutter analyze` и `flutter test` и собирает отладочный APK для Android.
Скачать APK: вкладка **Actions** → последний зелёный запуск → раздел
**Artifacts** → `lumi-kids-debug-apk`.
