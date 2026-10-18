export const ROLES = ['editor', 'methodologist', 'admin'] as const;
export type Role = (typeof ROLES)[number];

export interface StaffUser {
  id: string;
  email: string;
  name: string;
  role: Role;
}

export function isRole(value: unknown): value is Role {
  return typeof value === 'string' && (ROLES as readonly string[]).includes(value);
}
