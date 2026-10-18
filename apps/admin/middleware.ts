import { NextResponse, type NextRequest } from 'next/server';

/** Без cookie сессии все страницы, кроме входа, ведут на вход. */
export function middleware(request: NextRequest) {
  if (!request.cookies.has('lumi_admin')) {
    return NextResponse.redirect(new URL('/login', request.url));
  }
  return NextResponse.next();
}

export const config = {
  matcher: ['/((?!login|_next|favicon.ico).*)'],
};
