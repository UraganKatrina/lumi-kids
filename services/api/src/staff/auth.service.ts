import { HttpException, HttpStatus, Inject, Injectable, UnauthorizedException } from '@nestjs/common';
import { createHash, randomBytes } from 'node:crypto';

import { AuditService } from '../audit/audit.service';
import { APP_CONFIG, type AppConfig } from '../config';
import { Database } from '../db/database';
import { LoginThrottle } from './login-throttle';
import { verifyPassword } from './password';
import type { StaffUser } from './staff';

const sha256 = (value: string) => createHash('sha256').update(value).digest('hex');

@Injectable()
export class AuthService {
  private readonly throttle = new LoginThrottle();

  constructor(
    private readonly db: Database,
    private readonly audit: AuditService,
    @Inject(APP_CONFIG) private readonly config: AppConfig,
  ) {}

  /** Возвращает токен сессии. Ошибка одна и та же для неверной почты и пароля. */
  async login(email: string, password: string): Promise<{ token: string; staff: StaffUser }> {
    const key = email.trim().toLowerCase();
    if (this.throttle.isLocked(key)) {
      throw new HttpException('Слишком много попыток, попробуйте позже', HttpStatus.TOO_MANY_REQUESTS);
    }
    const [row] = await this.db.query<StaffUser & { password_hash: string }>(
      `SELECT id, email, name, role, password_hash FROM staff_users
       WHERE email = $1 AND disabled_at IS NULL`,
      [key],
    );
    if (!row || !(await verifyPassword(password, row.password_hash))) {
      this.throttle.fail(key);
      throw new UnauthorizedException('Неверная почта или пароль');
    }
    this.throttle.succeed(key);
    const token = randomBytes(32).toString('base64url');
    await this.db.query(
      `INSERT INTO staff_sessions (token_hash, staff_id, expires_at)
       VALUES ($1, $2, now() + make_interval(hours => $3))`,
      [sha256(token), row.id, this.config.sessionTtlHours],
    );
    await this.audit.record(row.id, 'staff.login', null);
    const { password_hash: _, ...staff } = row;
    return { token, staff };
  }

  async staffForToken(token: string): Promise<StaffUser | null> {
    const [row] = await this.db.query<StaffUser>(
      `SELECT u.id, u.email, u.name, u.role FROM staff_sessions s
       JOIN staff_users u ON u.id = s.staff_id
       WHERE s.token_hash = $1 AND s.expires_at > now() AND u.disabled_at IS NULL`,
      [sha256(token)],
    );
    return row ?? null;
  }

  async logout(token: string): Promise<void> {
    await this.db.query('DELETE FROM staff_sessions WHERE token_hash = $1', [sha256(token)]);
  }
}
