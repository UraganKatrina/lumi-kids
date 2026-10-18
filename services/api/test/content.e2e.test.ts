import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { after, before, test } from 'node:test';

import { bearer, example, startApp, type TestContext } from './helpers';

let ctx: TestContext;
before(async () => {
  ctx = await startApp();
});
after(() => ctx.close());

const as = (who: keyof TestContext['tokens']) => bearer(ctx.tokens[who]);

async function review(who: keyof TestContext['tokens'], id: string, action: string, notes?: string) {
  const current = await ctx.http().get(`/v1/admin/tasks/${id}`).set(as('admin')).expect(200);
  return ctx
    .http()
    .post(`/v1/admin/tasks/${id}/review`)
    .set(as(who))
    .send({ action, notes, expectedVersion: current.body.version });
}

test('задание с ошибками не сохраняется, ошибки возвращаются списком', async () => {
  const broken = { ...example('choice_count_apples'), ageRange: { minMonths: 50, maxMonths: 40 } };
  const res = await ctx.http().post('/v1/admin/tasks').set(as('editor')).send({ task: broken }).expect(422);
  assert.ok(res.body.errors.some((e: string) => e.includes('minMonths')));

  const check = await ctx.http().post('/v1/admin/tasks/validate').set(as('editor')).send({ task: broken });
  assert.equal(check.status, 200);
  assert.ok(check.body.errors.length > 0);

  // Версию и статус ставит сервер, поэтому их отсутствие — не ошибка.
  const { version: _v, review: _r, ...draft } = example('choice_count_apples');
  const ok = await ctx.http().post('/v1/admin/tasks/validate').set(as('editor')).send({ task: draft });
  assert.deepEqual(ok.body.errors, []);
});

test('полный путь: черновик → проверка → одобрение → пакет для приложения', async () => {
  const task = { ...example('choice_count_apples'), review: { status: 'published' }, version: 99 };
  const created = await ctx.http().post('/v1/admin/tasks').set(as('editor')).send({ task }).expect(201);
  // Статус и версию ставит сервер, а не клиент.
  assert.equal(created.body.status, 'draft');
  assert.equal(created.body.version, 1);
  assert.deepEqual(created.body.body.review, { status: 'draft' });
  const id = created.body.id as string;

  await ctx.http().post('/v1/admin/packs').set(as('methodologist')).send({}).expect(409);

  assert.equal((await review('editor', id, 'approve')).status, 403);
  assert.equal((await review('editor', id, 'submit')).status, 200);
  assert.equal((await review('editor', id, 'approve')).status, 403);
  const approved = await review('methodologist', id, 'approve');
  assert.equal(approved.status, 200);
  assert.equal(approved.body.status, 'approved');
  assert.match(approved.body.body.review.reviewedBy, /^staff:/);

  await ctx.http().post('/v1/admin/packs').set(as('editor')).send({}).expect(403);
  const pack = await ctx.http().post('/v1/admin/packs').set(as('methodologist')).send({}).expect(201);
  assert.equal(pack.body.version, 1);
  assert.equal(pack.body.taskCount, 1);

  const latest = await ctx.http().get('/v1/content/packs/latest').expect(200);
  assert.equal(latest.body.packVersion, 1);
  assert.equal(latest.body.tasks[0].review.status, 'published');
  // В пакете нет почты и имени методиста.
  assert.ok(!JSON.stringify(latest.body).includes('@lumi.test'));
  // Хэш в заголовке совпадает с байтами ответа: приложение может его проверить.
  assert.equal(createHash('sha256').update(latest.text).digest('hex'), latest.headers['x-pack-sha256']);
  const etag = latest.headers.etag;
  await ctx.http().get('/v1/content/packs/latest').set('If-None-Match', etag).expect(304);
  await ctx.http().get('/v1/content/packs/1').expect(200);
  await ctx.http().get('/v1/content/packs/7').expect(404);

  const after = await ctx.http().get(`/v1/admin/tasks/${id}`).set(as('editor')).expect(200);
  assert.equal(after.body.status, 'published');
});

test('правка опубликованного задания — новая версия в черновиках, пакет не меняется', async () => {
  const id = 'math.count.apples.001';
  const current = await ctx.http().get(`/v1/admin/tasks/${id}`).set(as('editor2')).expect(200);
  const changed = { ...current.body.body, difficulty: 2 };

  await ctx
    .http()
    .put(`/v1/admin/tasks/${id}`)
    .set(as('editor2'))
    .send({ task: changed, expectedVersion: current.body.version - 1 })
    .expect(409);
  const updated = await ctx
    .http()
    .put(`/v1/admin/tasks/${id}`)
    .set(as('editor2'))
    .send({ task: changed, expectedVersion: current.body.version })
    .expect(200);
  assert.equal(updated.body.version, 2);
  assert.equal(updated.body.status, 'draft');
  assert.equal(updated.body.history.length, 2);

  const pack = await ctx.http().get('/v1/content/packs/latest').expect(200);
  assert.equal(pack.body.tasks[0].difficulty, 1);
});

test('на проверке задание не редактируется; возврат требует пояснения', async () => {
  const task = example('match_animal_sounds');
  const created = await ctx.http().post('/v1/admin/tasks').set(as('editor')).send({ task }).expect(201);
  const id = created.body.id as string;
  await review('editor', id, 'submit');

  await ctx
    .http()
    .put(`/v1/admin/tasks/${id}`)
    .set(as('editor'))
    .send({ task, expectedVersion: 1 })
    .expect(409);
  assert.equal((await review('methodologist', id, 'reject')).status, 403);
  const rejected = await review('methodologist', id, 'reject', 'Добавьте озвучку');
  assert.equal(rejected.status, 200);
  assert.equal(rejected.body.status, 'draft');
  assert.equal(rejected.body.reviewNotes, 'Добавьте озвучку');
});

test('пакет не выпускается, если нет текста на языке пакета', async () => {
  const task = example('sequence_brush_teeth');
  const instruction = { text: { ru: 'Расставь картинки по порядку.' } };
  const created = await ctx
    .http()
    .post('/v1/admin/tasks')
    .set(as('editor'))
    .send({ task: { ...task, instruction } })
    .expect(201);
  const id = created.body.id as string;
  await review('editor', id, 'submit');
  await review('admin', id, 'approve');

  const res = await ctx.http().post('/v1/admin/packs').set(as('admin')).send({ languages: ['ru', 'uz'] }).expect(422);
  assert.ok(res.body.errors.some((e: string) => e.includes(`${id}: нет текста инструкции на языке uz`)));
  await ctx.http().post('/v1/admin/packs').set(as('admin')).send({ languages: ['xx'] }).expect(422);
});

test('снятое задание не попадает в следующий пакет', async () => {
  const id = 'math.count.apples.001';
  await review('methodologist', id, 'withdraw');
  const pack = await ctx.http().post('/v1/admin/packs').set(as('methodologist')).send({}).expect(201);
  const body = (await ctx.http().get(`/v1/content/packs/${pack.body.version}`).expect(200)).body;
  assert.ok(!body.tasks.some((t: { id: string }) => t.id === id));
});

test('каждое действие редакции попадает в журнал', async () => {
  const actions = (await ctx.db.query<{ action: string }>('SELECT DISTINCT action FROM audit_log')).map(
    (r) => r.action,
  );
  for (const a of ['staff.login', 'task.create', 'task.update', 'task.submit', 'task.approve', 'task.reject', 'task.withdraw', 'pack.publish']) {
    assert.ok(actions.includes(a), a);
  }
});
