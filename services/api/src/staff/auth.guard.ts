import {
  type CanActivate,
  type ExecutionContext,
  ForbiddenException,
  Injectable,
  SetMetadata,
  UnauthorizedException,
  createParamDecorator,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import type { Request } from 'express';

import { AuthService } from './auth.service';
import type { Role, StaffUser } from './staff';

const ROLES_KEY = 'lumi.roles';

/** Какие роли допускаются к обработчику; без декоратора — любой сотрудник. */
export const Roles = (...roles: Role[]) => SetMetadata(ROLES_KEY, roles);

type StaffRequest = Request & { staff?: StaffUser; staffToken?: string };

export function bearerToken(request: Request): string | null {
  const header = request.headers.authorization;
  if (!header?.startsWith('Bearer ')) return null;
  return header.slice('Bearer '.length).trim() || null;
}

@Injectable()
export class StaffGuard implements CanActivate {
  constructor(
    private readonly auth: AuthService,
    private readonly reflector: Reflector,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<StaffRequest>();
    const token = bearerToken(request);
    const staff = token ? await this.auth.staffForToken(token) : null;
    if (!staff || !token) throw new UnauthorizedException('Нужно войти');
    const roles = this.reflector.getAllAndOverride<Role[] | undefined>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (roles && !roles.includes(staff.role)) {
      throw new ForbiddenException('Недостаточно прав');
    }
    request.staff = staff;
    request.staffToken = token;
    return true;
  }
}

export const CurrentStaff = createParamDecorator(
  (_: unknown, context: ExecutionContext): StaffUser =>
    context.switchToHttp().getRequest<StaffRequest>().staff!,
);

export const CurrentToken = createParamDecorator(
  (_: unknown, context: ExecutionContext): string =>
    context.switchToHttp().getRequest<StaffRequest>().staffToken!,
);
