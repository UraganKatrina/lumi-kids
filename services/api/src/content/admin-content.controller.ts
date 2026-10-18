import {
  BadRequestException,
  Body,
  Controller,
  Get,
  HttpCode,
  Param,
  Post,
  Put,
  Query,
  UseGuards,
} from '@nestjs/common';

import { CurrentStaff, Roles, StaffGuard } from '../staff/auth.guard';
import type { StaffUser } from '../staff/staff';
import { PacksService } from './packs.service';
import { REVIEW_ACTIONS, STATUSES, type ReviewAction, type TaskStatus } from './review-policy';
import { TasksService } from './tasks.service';

function requireVersion(value: unknown): number {
  if (!Number.isInteger(value)) throw new BadRequestException('Нужен expectedVersion');
  return value as number;
}

/** Редакция: задания, проверка, выпуск пакетов. Только для сотрудников. */
@Controller('v1/admin')
@UseGuards(StaffGuard)
export class AdminContentController {
  constructor(
    private readonly tasks: TasksService,
    private readonly packs: PacksService,
  ) {}

  @Get('tasks')
  list(@Query('status') status?: string) {
    if (status !== undefined && !(STATUSES as readonly string[]).includes(status)) {
      throw new BadRequestException('Неизвестный статус');
    }
    return this.tasks.list(status as TaskStatus | undefined);
  }

  @Post('tasks/validate')
  @HttpCode(200)
  validate(@Body() body: { task?: unknown }) {
    return { errors: this.tasks.validate(body?.task) };
  }

  @Get('tasks/:id')
  get(@Param('id') id: string) {
    return this.tasks.get(id);
  }

  @Post('tasks')
  create(@CurrentStaff() staff: StaffUser, @Body() body: { task?: unknown }) {
    return this.tasks.create(staff, body?.task);
  }

  @Put('tasks/:id')
  update(
    @CurrentStaff() staff: StaffUser,
    @Param('id') id: string,
    @Body() body: { task?: unknown; expectedVersion?: unknown },
  ) {
    return this.tasks.update(staff, id, body?.task, requireVersion(body?.expectedVersion));
  }

  @Post('tasks/:id/review')
  @HttpCode(200)
  review(
    @CurrentStaff() staff: StaffUser,
    @Param('id') id: string,
    @Body() body: { action?: unknown; expectedVersion?: unknown; notes?: unknown },
  ) {
    if (!(REVIEW_ACTIONS as readonly unknown[]).includes(body?.action)) {
      throw new BadRequestException('Неизвестное действие');
    }
    const notes = typeof body.notes === 'string' ? body.notes : undefined;
    return this.tasks.review(
      staff,
      id,
      body.action as ReviewAction,
      requireVersion(body.expectedVersion),
      notes,
    );
  }

  @Get('packs')
  listPacks() {
    return this.packs.list();
  }

  @Post('packs')
  @Roles('methodologist', 'admin')
  publish(@CurrentStaff() staff: StaffUser, @Body() body: { languages?: unknown }) {
    const languages = body?.languages;
    if (languages !== undefined && !(Array.isArray(languages) && languages.every((l) => typeof l === 'string'))) {
      throw new BadRequestException('languages — список кодов языков');
    }
    return this.packs.publish(staff, languages as string[] | undefined);
  }
}
