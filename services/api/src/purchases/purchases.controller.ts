import { BadRequestException, Body, Controller, HttpCode, HttpException, Inject, Post, Req } from '@nestjs/common';
import type { Request } from 'express';

import type { Platform } from './purchase';
import { PurchasesService } from './purchases.service';
import { RateLimit } from './rate-limit';

export const MAX_TOKEN_LENGTH = 4096;

/** Токен Google — печатные ASCII без пробелов; номер транзакции Apple — только цифры. */
const TOKEN_FORMAT: Record<Platform, RegExp> = {
  android: /^[\x21-\x7e]+$/,
  ios: /^[0-9]{1,64}$/,
};

/**
 * Публичная проверка подписки для приложения. Без входа: аккаунтов у детей нет.
 * Ничего не сохраняет и не пишет токены в журнал.
 */
@Controller('v1/purchases')
export class PurchasesController {
  constructor(
    private readonly purchases: PurchasesService,
    @Inject(RateLimit) private readonly rateLimit: RateLimit,
  ) {}

  @Post('verify')
  @HttpCode(200)
  verify(@Body() body: { platform?: unknown; productId?: unknown; token?: unknown }, @Req() req: Request) {
    if (!this.rateLimit.take(req.ip ?? 'unknown')) {
      throw new HttpException('Слишком много запросов, попробуйте позже', 429);
    }
    const { platform, productId, token } = body ?? {};
    if (platform !== 'android' && platform !== 'ios') {
      throw new BadRequestException('platform должен быть android или ios');
    }
    if (typeof productId !== 'string' || !this.purchases.productIds.has(productId)) {
      throw new BadRequestException('Неизвестный продукт');
    }
    if (typeof token !== 'string' || token.length === 0 || token.length > MAX_TOKEN_LENGTH) {
      throw new BadRequestException('Нужен токен покупки');
    }
    if (!TOKEN_FORMAT[platform].test(token)) {
      throw new BadRequestException('Неверный формат токена покупки');
    }
    return this.purchases.verify(platform, productId, token);
  }
}
