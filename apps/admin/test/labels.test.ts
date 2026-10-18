import assert from 'node:assert/strict';
import { test } from 'node:test';

import { availableActions, isTaskStatus, orderTaskFields } from '../lib/labels.ts';

test('редактор видит только отправку черновика на проверку', () => {
  assert.deepEqual(availableActions({ role: 'editor', status: 'draft', isLastEditor: true }), ['submit']);
  assert.deepEqual(availableActions({ role: 'editor', status: 'in_review', isLastEditor: false }), []);
});

test('методист не видит «Одобрить» для своей правки', () => {
  assert.deepEqual(availableActions({ role: 'methodologist', status: 'in_review', isLastEditor: true }), [
    'reject',
    'withdraw',
  ]);
  assert.deepEqual(availableActions({ role: 'methodologist', status: 'in_review', isLastEditor: false }), [
    'approve',
    'reject',
    'withdraw',
  ]);
});

test('снятое задание нельзя снять ещё раз', () => {
  assert.deepEqual(availableActions({ role: 'admin', status: 'withdrawn', isLastEditor: false }), []);
});

test('проверка статуса из адресной строки', () => {
  assert.equal(isTaskStatus('draft'), true);
  assert.equal(isTaskStatus('toString'), false);
  assert.equal(isTaskStatus('<script>'), false);
});

test('поля задания идут в порядке схемы, неизвестные — в конце', () => {
  const ordered = orderTaskFields({ review: {}, extra: 1, area: 'math', id: 'a.b' });
  assert.deepEqual(Object.keys(ordered), ['id', 'area', 'review', 'extra']);
});
