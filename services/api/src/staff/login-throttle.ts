/**
 * Защита от подбора пароля: после [maxFailures] неудачных попыток почта
 * блокируется на [lockMs]. Хранится в памяти процесса — для одного сервера
 * этого достаточно, для нескольких понадобится общее хранилище.
 */
export class LoginThrottle {
  constructor(
    private readonly maxFailures = 5,
    private readonly lockMs = 15 * 60 * 1000,
    private readonly now: () => number = Date.now,
  ) {}

  private readonly failures = new Map<string, { count: number; lockedUntil: number }>();

  isLocked(key: string): boolean {
    const entry = this.failures.get(key);
    return entry !== undefined && entry.lockedUntil > this.now();
  }

  fail(key: string): void {
    const entry = this.failures.get(key) ?? { count: 0, lockedUntil: 0 };
    if (entry.lockedUntil && entry.lockedUntil <= this.now()) entry.count = 0;
    entry.count += 1;
    if (entry.count >= this.maxFailures) entry.lockedUntil = this.now() + this.lockMs;
    this.failures.set(key, entry);
  }

  succeed(key: string): void {
    this.failures.delete(key);
  }
}
