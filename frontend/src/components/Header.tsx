'use client';

import Link from 'next/link';

export function Header() {
  return (
    <header className="bg-blue-600 text-white shadow-lg">
      <div className="container mx-auto px-4 py-6">
        <div className="flex items-center justify-between">
          <div>
            <Link href="/" className="hover:opacity-90 transition-opacity">
              <h1 className="text-3xl font-bold">Kitchensink</h1>
              <p className="text-blue-100 text-sm mt-1">
                Spring Boot + Next.js Application
              </p>
            </Link>
          </div>
          
          <nav className="flex gap-6">
            <Link
              href="/"
              className="hover:text-blue-200 transition-colors font-medium"
            >
              Home
            </Link>
            <a
              href={`${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080'}/rest/members`}
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-blue-200 transition-colors font-medium flex items-center gap-1"
            >
              API
              <svg
                className="w-4 h-4"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"
                />
              </svg>
            </a>
          </nav>
        </div>
      </div>
    </header>
  );
}
