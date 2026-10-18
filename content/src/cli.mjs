import { readFileSync, readdirSync, statSync } from 'node:fs';
import { join } from 'node:path';
import { validateTask } from './validate.mjs';

// Проверяет задания в указанных файлах и папках (*.json). Файл может быть
// одним заданием или пакетом с полем tasks. Код выхода 1, если есть ошибки.
let failed = 0;

for (const path of process.argv.slice(2).flatMap(jsonFiles)) {
  const json = JSON.parse(readFileSync(path, 'utf8'));
  const tasks = Array.isArray(json.tasks) ? json.tasks : [json];
  tasks.forEach((task, i) => {
    const name = Array.isArray(json.tasks) ? `${path} [${task.id ?? i}]` : path;
    const errors = validateTask(task);
    if (errors.length === 0) {
      console.log(`OK    ${name}`);
    } else {
      failed++;
      console.log(`FAIL  ${name}`);
      for (const e of errors) console.log(`      ${e}`);
    }
  });
}

process.exitCode = failed > 0 ? 1 : 0;

function jsonFiles(path) {
  if (!statSync(path).isDirectory()) return [path];
  return readdirSync(path)
    .filter((f) => f.endsWith('.json'))
    .sort()
    .map((f) => join(path, f));
}
