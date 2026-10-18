import assert from 'node:assert/strict';
import { test } from 'node:test';

import { LoginThrottle } from '../src/staff/login-throttle';
import { hashPassword, verifyPassword } from '../src/staff/password';

test('пароль хранится только как хэш с солью', async () => {
  const a = await hashPassword('correct horse battery');
  const b = await hashPassword('correct horse battery');
  assert.notEqual(a, b);
  assert.ok(!a.includes('correct'));
  assert.equal(await verifyPassword('correct horse battery', a), true);
  assert.equal(await verifyPassword('wrong horse battery', a), false);
  assert.equal(await verifyPassword('x', 'garbage'), false);
});

test('после пяти ошибок вход блокируется на время', () => {
  let now = 0;
  const throttle = new LoginThrottle(5, 1000, () => now);
  for (let i = 0; i < 4; i++) throttle.fail('a');
  assert.equal(throttle.isLocked('a'), false);
  throttle.fail('a');
  assert.equal(throttle.isLocked('a'), true);
  assert.equal(throttle.isLocked('b'), false);
  now = 1001;
  assert.equal(throttle.isLocked('a'), false);
  throttle.fail('a');
  assert.equal(throttle.isLocked('a'), false);
});
