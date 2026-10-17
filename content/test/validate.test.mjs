import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, readdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { validateTask } from '../src/validate.mjs';

function load(dir) {
  const root = fileURLToPath(new URL(`../${dir}/`, import.meta.url));
  return readdirSync(root)
    .filter((f) => f.endsWith('.json'))
    .map((f) => [f, JSON.parse(readFileSync(root + f, 'utf8'))]);
}

for (const [name, task] of load('examples')) {
  test(`эталонное задание проходит проверку: ${name}`, () => {
    assert.deepEqual(validateTask(task), []);
  });
}

for (const [name, task] of load('invalid')) {
  test(`ошибочное задание отклоняется: ${name}`, () => {
    assert.notDeepEqual(validateTask(task), []);
  });
}
