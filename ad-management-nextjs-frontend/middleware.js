import { NextResponse } from 'next/server';

export function middleware(request) {
  // Get the origin of the request
  const origin = request.headers.get('origin') || '*';
  
  // Only apply to API routes
  if (request.nextUrl.pathname.startsWith('/api/')) {
    // For OPTIONS requests (CORS preflight)
    if (request.method === 'OPTIONS') {
      const response = new NextResponse(null, {
        status: 200,
        headers: {
          'Access-Control-Allow-Origin': origin,
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization',
          'Access-Control-Allow-Credentials': 'true',
          'Access-Control-Max-Age': '86400', // 24 hours
        },
      });
      return response;
    }

    // For actual requests
    const response = NextResponse.next();
    response.headers.set('Access-Control-Allow-Origin', origin);
    response.headers.set('Access-Control-Allow-Credentials', 'true');
    return response;
  }

  return NextResponse.next();
}

export const config = {
  matcher: [
    '/api/:path*',
  ],
};