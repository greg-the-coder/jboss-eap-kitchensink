import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Enable standalone output for Docker deployment
  output: 'standalone',
  
  // Configure rewrites for API proxy in development (helps with CORS)
  async rewrites() {
    return [
      {
        source: '/api/:path*',
        destination: `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080'}/rest/:path*`,
      },
    ];
  },
  
  // React strict mode for better development experience
  reactStrictMode: true,
  
  // Configure images if needed
  images: {
    remotePatterns: [],
  },
};

export default nextConfig;
