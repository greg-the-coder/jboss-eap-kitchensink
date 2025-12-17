'use client';

export function Footer() {
  const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080';
  
  return (
    <footer className="bg-gray-800 text-white mt-auto">
      <div className="container mx-auto px-4 py-8">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div>
            <h3 className="text-lg font-semibold mb-3">About</h3>
            <p className="text-gray-300 text-sm">
              Kitchensink is a modern full-stack application demonstrating the migration
              from J2EE to Spring Boot + Next.js.
            </p>
          </div>
          
          <div>
            <h3 className="text-lg font-semibold mb-3">Technology Stack</h3>
            <ul className="text-gray-300 text-sm space-y-1">
              <li>• Spring Boot 3.x (Backend)</li>
              <li>• Next.js 15 (Frontend)</li>
              <li>• TypeScript & React</li>
              <li>• Tailwind CSS</li>
              <li>• Spring Security</li>
            </ul>
          </div>
          
          <div>
            <h3 className="text-lg font-semibold mb-3">REST API Endpoints</h3>
            <ul className="text-gray-300 text-sm space-y-2">
              <li>
                <a
                  href={`${apiUrl}/rest/members`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="hover:text-blue-400 transition-colors"
                >
                  GET /rest/members
                </a>
              </li>
              <li>
                <a
                  href={`${apiUrl}/actuator/health`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="hover:text-blue-400 transition-colors"
                >
                  GET /actuator/health
                </a>
              </li>
              <li className="text-gray-400">
                POST /rest/members (Registration)
              </li>
            </ul>
          </div>
        </div>
        
        <div className="border-t border-gray-700 mt-8 pt-6 text-center text-gray-400 text-sm">
          <p>
            © {new Date().getFullYear()} Kitchensink Application. Migrated from J2EE to Spring Boot + Next.js.
          </p>
        </div>
      </div>
    </footer>
  );
}
