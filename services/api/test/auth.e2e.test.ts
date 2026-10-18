import assert from 'node:assert/strict';
import { after, before, test } from 'node:test';

import { bearer, PASSWORD, startApp, type TestContext } from './helpers';

let ctx: TestContext;
before(async () => {
  ctx = await startApp();
});
after(() => ctx.close());

test('сервер отвечает на проверку здоровья', async () => {
  const res = await ctx.http().get('/v1/health').expect(200);
  assert.deepEqual(res.body, { status: 'ok' });
  assert.equal(res.headers['x-powered-by'], undefined);
});

test('вход: верный пароль даёт токен, неверный — одинаковую ошибку', async () => {
  const wrong = await ctx.http().post('/v1/admin/login').send({ email: 'editor@lumi.test', password: 'nope' });
  const unknown = await ctx.http().post('/v1/admin/login').send({ email: 'ghost@lumi.test', password: 'nope' });
  assert.equal(wrong.status, 401);
  assert.equal(unknown.status, 401);
  assert.equal(wrong.body.message, unknown.body.message);

  const me = await ctx.http().get('/v1/admin/me').set(bearer(ctx.tokens.editor)).expect(200);
  assert.equal(me.body.role, 'editor');
  assert.equal(me.body.password_hash, undefined);
});

test('в базе хранится хэш токена, а не сам токен', async () => {
  const rows = await ctx.db.query<{ token_hash: string }>('SELECT token_hash FROM staff_sessions');
  assert.ok(rows.length > 0);
  for (const row of rows) assert.ok(!Object.values(ctx.tokens).includes(row.token_hash));
});

test('без токена и с чужим токеном — нет доступа', async () => {
  await ctx.http().get('/v1/admin/tasks').expect(401);
  await ctx.http().get('/v1/admin/tasks').set(bearer('made-up')).expect(401);
});

test('после выхода токен не работает', async () => {
  const login = await ctx.http().post('/v1/admin/login').send({ email: 'admin@lumi.test', password: PASSWORD });
  const token = login.body.token;
  await ctx.http().post('/v1/admin/logout').set(bearer(token)).expect(204);
  await ctx.http().get('/v1/admin/me').set(bearer(token)).expect(401);
});

test('подбор пароля блокируется', async () => {
  for (let i = 0; i < 5; i++) {
    await ctx.http().post('/v1/admin/login').send({ email: 'editor2@lumi.test', password: 'guess' }).expect(401);
  }
  await ctx.http().post('/v1/admin/login').send({ email: 'editor2@lumi.test', password: PASSWORD }).expect(429);
});
