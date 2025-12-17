import { NextResponse } from 'next/server';

/**
 * Health check endpoint for Docker container health checks
 * Returns 200 OK if the application is running
 */
export async function GET() {
  return NextResponse.json(
    { 
      status: 'UP',
      timestamp: new Date().toISOString(),
      service: 'kitchensink-frontend'
    },
    { status: 200 }
  );
}
