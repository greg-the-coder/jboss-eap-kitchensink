'use client';

import { use } from 'react';
import Link from 'next/link';
import { useMember } from '@/hooks/useMembers';

export default function MemberDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const resolvedParams = use(params);
  const memberId = parseInt(resolvedParams.id);
  const { data: member, isLoading, error } = useMember(memberId);

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
        <div className="max-w-3xl mx-auto">
          <div className="animate-pulse">
            <div className="h-8 bg-gray-200 rounded w-1/4 mb-8"></div>
            <div className="bg-white rounded-lg shadow-md p-6">
              <div className="h-6 bg-gray-200 rounded w-1/3 mb-4"></div>
              <div className="space-y-3">
                <div className="h-4 bg-gray-200 rounded"></div>
                <div className="h-4 bg-gray-200 rounded"></div>
                <div className="h-4 bg-gray-200 rounded"></div>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  if (error || !member) {
    return (
      <div className="min-h-screen bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
        <div className="max-w-3xl mx-auto">
          <Link
            href="/"
            className="text-blue-600 hover:text-blue-800 mb-8 inline-block"
          >
            ← Back to Members
          </Link>
          <div className="bg-white rounded-lg shadow-md p-6 text-center">
            <div className="text-red-500 mb-4">
              <svg
                className="mx-auto h-12 w-12"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
            </div>
            <h2 className="text-xl font-semibold text-gray-900 mb-2">
              Member Not Found
            </h2>
            <p className="text-gray-600">
              The member you're looking for doesn't exist.
            </p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-3xl mx-auto">
        <Link
          href="/"
          className="text-blue-600 hover:text-blue-800 mb-8 inline-block"
        >
          ← Back to Members
        </Link>

        <div className="bg-white rounded-lg shadow-md overflow-hidden">
          <div className="bg-blue-600 px-6 py-4">
            <h1 className="text-2xl font-bold text-white">Member Details</h1>
          </div>

          <div className="p-6">
            <dl className="space-y-4">
              <div className="border-b pb-4">
                <dt className="text-sm font-medium text-gray-500 mb-1">ID</dt>
                <dd className="text-lg text-gray-900">{member.id}</dd>
              </div>

              <div className="border-b pb-4">
                <dt className="text-sm font-medium text-gray-500 mb-1">Name</dt>
                <dd className="text-lg text-gray-900">{member.name}</dd>
              </div>

              <div className="border-b pb-4">
                <dt className="text-sm font-medium text-gray-500 mb-1">Email</dt>
                <dd className="text-lg text-gray-900">
                  <a
                    href={`mailto:${member.email}`}
                    className="text-blue-600 hover:text-blue-800"
                  >
                    {member.email}
                  </a>
                </dd>
              </div>

              <div className="border-b pb-4">
                <dt className="text-sm font-medium text-gray-500 mb-1">
                  Phone Number
                </dt>
                <dd className="text-lg text-gray-900">
                  <a
                    href={`tel:${member.phoneNumber}`}
                    className="text-blue-600 hover:text-blue-800"
                  >
                    {member.phoneNumber}
                  </a>
                </dd>
              </div>

              <div>
                <dt className="text-sm font-medium text-gray-500 mb-1">
                  REST API Endpoint
                </dt>
                <dd className="text-lg">
                  <a
                    href={`${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080'}/rest/members/${member.id}`}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-blue-600 hover:text-blue-800 break-all"
                  >
                    {`${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080'}/rest/members/${member.id}`}
                  </a>
                </dd>
              </div>
            </dl>
          </div>
        </div>
      </div>
    </div>
  );
}
