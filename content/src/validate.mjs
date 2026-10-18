import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import Ajv2020 from 'ajv/dist/2020.js';
import addFormats from 'ajv-formats';

const schemaPath = fileURLToPath(new URL('../schema/task.schema.json', import.meta.url));
const schema = JSON.parse(readFileSync(schemaPath, 'utf8'));

const ajv = new Ajv2020({ allErrors: true, strict: true, strictRequired: false });
addFormats(ajv);
const checkSchema = ajv.compile(schema);

/**
 * Проверяет одно задание: сначала по JSON Schema, затем правила,
 * которые схема выразить не может (ссылки между полями).
 * Возвращает список ошибок; пустой список означает, что задание корректно.
 */
export function validateTask(task) {
  if (!checkSchema(task)) {
    return checkSchema.errors.map((e) => `${e.instancePath || '/'} ${e.message}`);
  }
  return checkReferences(task);
}

function checkReferences(task) {
  const errors = [];
  const { ageRange, content, exerciseType } = task;

  if (ageRange.minMonths > ageRange.maxMonths) {
    errors.push('/ageRange minMonths больше maxMonths');
  }

  if (ageRange.minMonths < 12 && !task.withParent) {
    errors.push('задания для детей до года выполняются только вместе со взрослым (withParent: true)');
  }

  const mediaIds = new Set(task.media.map((m) => m.id));
  for (const ref of collectMediaRefs(task)) {
    if (!mediaIds.has(ref)) errors.push(`медиафайл "${ref}" не описан в media`);
  }

  const licensed = new Set(task.rights.map((r) => r.mediaId));
  for (const id of mediaIds) {
    if (!licensed.has(id)) errors.push(`у медиафайла "${id}" не указаны права`);
  }

  const itemIds = collectItemIds(task);
  const duplicates = itemIds.filter((id, i) => itemIds.indexOf(id) !== i);
  for (const id of new Set(duplicates)) errors.push(`повторяющийся id элемента "${id}"`);

  if (exerciseType === 'choice') {
    const optionIds = new Set(content.options.map((o) => o.id));
    for (const id of content.correct) {
      if (!optionIds.has(id)) errors.push(`правильный ответ "${id}" отсутствует среди вариантов`);
    }
  }

  if (exerciseType === 'sort' || exerciseType === 'classify') {
    const groupIds = new Set(content.groups.map((g) => g.id));
    for (const { item, groupId } of content.items) {
      if (!groupIds.has(groupId)) errors.push(`элемент "${item.id}" ссылается на неизвестную группу "${groupId}"`);
    }
  }

  return errors;
}

function collectMediaRefs(task) {
  const refs = new Set(Object.values(task.instruction.audio ?? {}));
  walk(task.content, (node) => {
    for (const key of ['imageId', 'audioId']) {
      if (typeof node[key] === 'string') refs.add(node[key]);
    }
  });
  return refs;
}

function collectItemIds(task) {
  const ids = [];
  const { content, exerciseType } = task;
  const items = [
    ...(content.options ?? []),
    ...(exerciseType === 'sequence' ? content.steps : []),
    ...(content.groups ?? []),
    ...(content.items ?? []).map((x) => x.item),
    ...(content.pairs ?? []).flatMap((p) => [p.left, p.right]),
  ];
  for (const item of items) ids.push(item.id);
  return ids;
}

function walk(node, visit) {
  if (Array.isArray(node)) {
    node.forEach((child) => walk(child, visit));
  } else if (node && typeof node === 'object') {
    visit(node);
    Object.values(node).forEach((child) => walk(child, visit));
  }
}
