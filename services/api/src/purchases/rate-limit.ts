/**
 * Простое ограничение частоты по IP: не больше [max] запросов за [windowMs].
 * В памяти процесса, как и LoginThrottle: для одного сервера достаточно.
 */
export class RateLimit {
  private readonly hits = new Map<string, { count: number; resetAt: number }>();

  constructor(
    private readonly max = 30,
    private readonly windowMs = 10 * 60 * 1000,
    private readonly now: () => number = Date.now,
  ) {}

  /** true — запрос можно пропустить. */
  take(key: string): boolean {
    const now = this.now();
    // Старые записи чистим, когда их много, чтобы карта не росла бесконечно.
    if (this.hits.size > 10_000) {
      for (const [k, v] of this.hits) if (v.resetAt <= now) this.hits.delete(k);
    }
    const entry = this.hits.get(key);
    if (!entry || entry.resetAt <= now) {
      this.hits.set(key, { count: 1, resetAt: now + this.windowMs });
      return true;
    }
    entry.count += 1;
    return entry.count <= this.max;
  }
}
