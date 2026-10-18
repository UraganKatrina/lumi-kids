import { BadRequestException, Controller, Get, Headers, Param, Res } from '@nestjs/common';
import type { Response } from 'express';

import { PacksService, type PublishedPack } from './packs.service';

/**
 * Публичная выдача пакетов для приложения. Без входа и без данных о ребёнке:
 * приложение просто скачивает пакет и проверяет хэш.
 */
@Controller('v1/content/packs')
export class PublicContentController {
  constructor(private readonly packs: PacksService) {}

  @Get('latest')
  async latest(@Headers('if-none-match') etag: string | undefined, @Res() res: Response) {
    send(res, await this.packs.get(), etag);
  }

  @Get(':version')
  async byVersion(
    @Param('version') version: string,
    @Headers('if-none-match') etag: string | undefined,
    @Res() res: Response,
  ) {
    const n = Number(version);
    if (!Number.isInteger(n) || n < 1) throw new BadRequestException('Неверная версия пакета');
    send(res, await this.packs.get(n), etag);
  }
}

function send(res: Response, pack: PublishedPack, etag: string | undefined) {
  const tag = `"${pack.sha256}"`;
  res.setHeader('ETag', tag);
  res.setHeader('X-Pack-Sha256', pack.sha256);
  res.setHeader('Cache-Control', 'public, max-age=300');
  if (etag === tag) {
    res.status(304).end();
    return;
  }
  res.type('application/json').send(pack.body);
}
