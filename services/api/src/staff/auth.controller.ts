import { BadRequestException, Body, Controller, Get, HttpCode, Post, UseGuards } from '@nestjs/common';

import { AuthService } from './auth.service';
import { CurrentStaff, CurrentToken, StaffGuard } from './auth.guard';
import type { StaffUser } from './staff';

@Controller('v1/admin')
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Post('login')
  @HttpCode(200)
  login(@Body() body: { email?: unknown; password?: unknown }) {
    if (typeof body?.email !== 'string' || typeof body?.password !== 'string') {
      throw new BadRequestException('Нужны почта и пароль');
    }
    return this.auth.login(body.email, body.password);
  }

  @Post('logout')
  @HttpCode(204)
  @UseGuards(StaffGuard)
  async logout(@CurrentToken() token: string): Promise<void> {
    await this.auth.logout(token);
  }

  @Get('me')
  @UseGuards(StaffGuard)
  me(@CurrentStaff() staff: StaffUser): StaffUser {
    return staff;
  }
}
