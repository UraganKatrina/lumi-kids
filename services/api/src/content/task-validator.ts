import { Injectable, type OnModuleInit } from '@nestjs/common';

type ValidateTask = (task: unknown) => string[];

/**
 * Та же проверка, что в content/ и в CI: JSON Schema и связи между полями.
 * Модуль проверки — ESM, поэтому загружается динамическим импортом.
 */
@Injectable()
export class TaskValidator implements OnModuleInit {
  private validateTask?: ValidateTask;

  async onModuleInit(): Promise<void> {
    const module = await import('@lumi-kids/content/validate');
    this.validateTask = module.validateTask;
  }

  validate(task: unknown): string[] {
    if (!this.validateTask) throw new Error('Проверка заданий ещё не загружена');
    return this.validateTask(task);
  }
}
