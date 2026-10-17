# LUMI Kids

Образовательное приложение для детей 0–7 лет (Flutter, Android и iOS).

## Состояние

Этап 1: пустой каркас с одним экраном и тестами.

## Проверка

```bash
flutter pub get
flutter analyze
flutter test
```

## Структура

- `lib/app/`: корневой виджет и тема
- `lib/features/<функция>/`: экраны и логика по функциям
- `test/`: тесты, повторяющие структуру `lib/`

## Автосборка

При каждом изменении GitHub Actions проверяет форматирование, запускает
`flutter analyze` и `flutter test` и собирает отладочный APK для Android.
Скачать APK: вкладка **Actions** → последний зелёный запуск → раздел
**Artifacts** → `lumi-kids-debug-apk`.
