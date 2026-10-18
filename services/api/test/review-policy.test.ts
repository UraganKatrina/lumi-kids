import assert from 'node:assert/strict';
import { test } from 'node:test';

import { canEdit, decideReview, type ReviewContext } from '../src/content/review-policy';

const base: ReviewContext = { status: 'in_review', role: 'methodologist', actorId: 'm', lastEditorId: 'e' };

test('методист одобряет чужую правку', () => {
  assert.deepEqual(decideReview('approve', base), { ok: true, status: 'approved' });
});

test('нельзя одобрить свою правку, даже админу', () => {
  const own = { ...base, role: 'admin' as const, actorId: 'e' };
  assert.equal(decideReview('approve', own).ok, false);
});

test('редактор не одобряет, не возвращает и не снимает', () => {
  const editor = { ...base, role: 'editor' as const };
  for (const action of ['approve', 'reject', 'withdraw'] as const) {
    assert.equal(decideReview(action, editor).ok, false, action);
  }
});

test('одобрить можно только задание на проверке', () => {
  for (const status of ['draft', 'approved', 'published', 'withdrawn'] as const) {
    assert.equal(decideReview('approve', { ...base, status }).ok, false, status);
  }
});

test('на проверку уходит только черновик', () => {
  assert.deepEqual(decideReview('submit', { ...base, status: 'draft', role: 'editor' }), {
    ok: true,
    status: 'in_review',
  });
  assert.equal(decideReview('submit', base).ok, false);
});

test('возврат автору требует пояснения', () => {
  assert.equal(decideReview('reject', base).ok, false);
  assert.deepEqual(decideReview('reject', { ...base, notes: 'Добавьте подсказку' }), {
    ok: true,
    status: 'draft',
  });
});

test('снять можно любое задание, кроме уже снятого', () => {
  assert.equal(decideReview('withdraw', { ...base, status: 'published' }).ok, true);
  assert.equal(decideReview('withdraw', { ...base, status: 'withdrawn' }).ok, false);
});

test('задание на проверке не редактируется', () => {
  assert.equal(canEdit('in_review'), false);
  assert.equal(canEdit('published'), true);
});
