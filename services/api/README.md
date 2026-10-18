# LUMI Kids API

Сервер редакции и выдачи контента: NestJS + PostgreSQL, один процесс
(модульный монолит). Данных о детях здесь нет: профили и прогресс пока
хранятся только на телефоне.

## Что умеет

| Адрес | Кто | Что делает |
|---|---|---|
| `GET /v1/health` | все | проверка, что сервер и база живы |
| `POST /v1/admin/login`, `POST /v1/admin/logout`, `GET /v1/admin/me` | сотрудники | вход по почте и паролю, токен сессии |
| `GET /v1/admin/tasks`, `GET /v1/admin/tasks/:id` | сотрудники | список заданий и задание с историей версий |
| `POST /v1/admin/tasks`, `PUT /v1/admin/tasks/:id` | сотрудники | черновик и новая версия (с защитой от одновременной правки) |
| `POST /v1/admin/tasks/validate` | сотрудники | проверка задания без сохранения |
| `POST /v1/admin/tasks/:id/review` | см. ниже | `submit`, `approve`, `reject`, `withdraw` |
| `GET /v1/admin/packs`, `POST /v1/admin/packs` | методист, админ | список и выпуск пакета |
| `GET /v1/content/packs/latest`, `GET /v1/content/packs/:version` | приложение | пакет заданий, `ETag` и `X-Pack-Sha256` |
| `POST /v1/purchases/verify` | приложение | проверка подписки в Google Play или App Store |

## Проверка подписок

Приложение присылает `{ "platform": "android" | "ios", "productId": "...", "token": "..." }`:
для Android `token` — purchaseToken из Google Play, для iOS — transactionId из StoreKit
(исходный или текущий). Сервер спрашивает магазин сам и отвечает

```json
{ "active": true, "productId": "lumi_premium_monthly", "expiresAt": "2026-11-18T10:00:00.000Z",
  "platform": "android", "environment": "production", "acknowledged": true }
```

- Android: Google Play Developer API `purchases.subscriptionsv2.get`, вход по JWT
  сервисного аккаунта (токен доступа живёт в памяти до минуты перед истечением).
  Активна при `SUBSCRIPTION_STATE_ACTIVE` или `SUBSCRIPTION_STATE_IN_GRACE_PERIOD`
  и сроке строки с этим `productId` в будущем. `acknowledged` только сообщает
  состояние: подтверждает покупку приложение через SDK магазина, не сервер.
  `environment: "sandbox"` — тестовая покупка из лицензионного списка.
- iOS: App Store Server API `Get All Subscription Statuses`, вход по JWT ES256.
  Активна при статусе 1 (активна) или 4 (льготный период), совпадении `productId`
  и `bundleId` и сроке в будущем. Песочница (`APPLE_ALLOW_SANDBOX=1`) проверяется,
  только если боевой App Store не знает транзакцию.
- Токен, который магазин не знает, — ответ 200 с `active: false`.
  Неверный запрос или продукт не из `PURCHASE_PRODUCT_IDS` — 400, магазин не
  настроен — 503, магазин не ответил или ответил ошибкой — 502 (без подробностей).
- Ничего не хранится: ни токены, ни покупки, ни адреса. Токены не пишутся в журнал.
- Не больше 30 запросов с одного адреса за 10 минут (в памяти процесса), токен —
  не длиннее 4096 символов. За прокси задайте `TRUST_PROXY`.

## Правила проверки контента

- Любая правка сохраняет новую версию и возвращает задание в черновики.
- Одобряют и возвращают задания только методист или администратор,
  и только не свою правку: нужен второй человек.
- Возврат автору требует комментария.
- Пакет собирается только из одобренных и опубликованных заданий,
  каждое проверяется той же схемой, что в `content/`, и должно иметь
  текст инструкции на каждом языке пакета.
- Выпущенный пакет не меняется. Его sha256 считается по точным байтам ответа.
- Все действия записываются в `audit_log`.

## Безопасность

- Пароли хранятся как scrypt-хэш с солью, токены сессий — как sha256.
- 5 неудачных входов подряд блокируют почту на 15 минут.
- Секретов в репозитории нет: всё берётся из переменных окружения
  (см. `.env.example`). Ключи магазинов (JSON сервисного аккаунта Google и `.p8`
  от Apple) лежат файлами вне репозитория и читаются один раз при запуске.

## Как запустить

Нужны Node 22 и PostgreSQL 16.

```bash
cd content && npm ci && cd ..          # общая проверка заданий
cd services/api
npm ci
npm run build
export DATABASE_URL=postgres://...
npm run migrate
STAFF_PASSWORD='длинный-пароль' npm run create-staff -- --email you@example.com --name Имя --role admin
npm start                               # http://localhost:3000/v1/health
```

Загрузить стартовые задания приложения в черновики (повторный запуск
ничего не дублирует):

```bash
npm run import-tasks -- --file ../../apps/mobile/assets/content/starter_pack.json --as you@example.com
```

Тесты используют отдельную базу и каждый раз пересоздают её схему:

```bash
export TEST_DATABASE_URL=postgres://postgres@127.0.0.1:5432/lumi_test
npm test
```
