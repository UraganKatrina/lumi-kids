import { ConflictException, Injectable } from '@nestjs/common';

import { Database } from '../db/database';
import { hashPassword, MIN_PASSWORD_LENGTH } from './password';
import type { Role, StaffUser } from './staff';

@Injectable()
export class StaffService {
  constructor(private readonly db: Database) {}

  async create(input: { email: string; name: string; role: Role; password: string }): Promise<StaffUser> {
    if (input.password.length < MIN_PASSWORD_LENGTH) {
      throw new Error(`Пароль должен быть не короче ${MIN_PASSWORD_LENGTH} символов`);
    }
    const hash = await hashPassword(input.password);
    try {
      const [row] = await this.db.query<StaffUser>(
        `INSERT INTO staff_users (email, name, role, password_hash)
         VALUES (lower($1), $2, $3, $4)
         RETURNING id, email, name, role`,
        [input.email.trim(), input.name.trim(), input.role, hash],
      );
      return row!;
    } catch (error) {
      if ((error as { code?: string }).code === '23505') {
        throw new ConflictException('Сотрудник с такой почтой уже есть');
      }
      throw error;
    }
  }
}
