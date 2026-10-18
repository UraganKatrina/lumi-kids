# LUMI Kids — админка редакции

Next.js. Редакторы пишут задания, методисты проверяют и выпускают пакеты.
Все запросы к API идут с сервера админки; токен лежит в httpOnly-cookie
и недоступен скриптам страницы.

```bash
npm ci
API_URL=http://127.0.0.1:3000 npm run dev   # http://localhost:3001
npm run typecheck && npm test && npm run build
```

Сотрудников создаёт администратор сервера командой `npm run create-staff`
в `services/api` (см. README там).
