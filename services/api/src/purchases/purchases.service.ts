import { BadGatewayException, Inject, Injectable, Logger, ServiceUnavailableException } from '@nestjs/common';

import { APP_CONFIG, type AppConfig } from '../config';
import { AppStoreVerifier } from './app-store.verifier';
import { GooglePlayVerifier } from './google-play.verifier';
import { FETCH, type FetchFn, type Platform, StoreError, type VerifyResult } from './purchase';

const STORE_NAMES: Record<Platform, string> = { android: 'Android', ios: 'iOS' };

/**
 * Проверка подписок без хранения: сервер ничего не записывает в базу и не знает,
 * чей это телефон. Приложение спрашивает — магазин отвечает — сервер пересказывает.
 */
@Injectable()
export class PurchasesService {
  private readonly logger = new Logger('Purchases');
  readonly productIds: ReadonlySet<string>;
  private readonly google?: GooglePlayVerifier;
  private readonly apple?: AppStoreVerifier;

  constructor(@Inject(APP_CONFIG) config: AppConfig, @Inject(FETCH) fetchFn: FetchFn) {
    const purchases = config.purchases;
    this.productIds = new Set(purchases?.productIds ?? []);
    if (purchases?.google) this.google = new GooglePlayVerifier(purchases.google, fetchFn);
    if (purchases?.apple) this.apple = new AppStoreVerifier(purchases.apple, fetchFn);
  }

  async verify(platform: Platform, productId: string, token: string): Promise<VerifyResult> {
    const verifier = platform === 'android' ? this.google : this.apple;
    if (!verifier) {
      throw new ServiceUnavailableException({ message: `Проверка покупок для ${STORE_NAMES[platform]} не настроена` });
    }
    try {
      return await verifier.verify(productId, token);
    } catch (error) {
      // В журнал — только магазин и код ответа; токен и тело ответа не пишем.
      this.logger.warn(error instanceof StoreError ? error.message : `${platform}: внутренняя ошибка проверки`);
      throw new BadGatewayException('Магазин приложений не ответил, попробуйте позже');
    }
  }
}
