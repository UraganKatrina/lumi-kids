import { readFileSync, readdirSync } from 'node:fs';
import { join } from 'node:path';
import { validateTask } from './validate.mjs';

// Проверяет все *.json в указанных папках. Код выхода 1, если есть ошибки.
const dirs = process.argv.slice(2);
let failed = 0;

for (const dir of dirs) {
  for (const file of readdirSync(dir).filter((f) => f.endsWith('.json')).sort()) {
    const path = join(dir, file);
    const errors = validateTask(JSON.parse(readFileSync(path, 'utf8')));
    if (errors.length === 0) {
      console.log(`OK    ${path}`);
    } else {
      failed++;
      console.log(`FAIL  ${path}`);
      for (const e of errors) console.log(`      ${e}`);
    }
  }
}

process.exitCode = failed > 0 ? 1 : 0;
