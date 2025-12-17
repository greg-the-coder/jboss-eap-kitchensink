import { Header } from '@/components/Header';
import { Footer } from '@/components/Footer';
import { MemberStats } from '@/components/MemberStats';
import { MemberRegistrationForm } from '@/components/MemberRegistrationForm';
import { MemberList } from '@/components/MemberList';

export default function Home() {
  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      <Header />
      
      <main className="flex-grow container mx-auto px-4 py-8">
        {/* Welcome Section */}
        <div className="text-center mb-12">
          <h2 className="text-4xl font-bold text-gray-900 mb-4">
            Welcome to Kitchensink!
          </h2>
          <p className="text-lg text-gray-600 max-w-3xl mx-auto">
            This application demonstrates a modern full-stack architecture with{' '}
            <span className="font-semibold text-blue-600">Spring Boot 3.x</span> backend and{' '}
            <span className="font-semibold text-blue-600">Next.js 15</span> frontend.
            Register new members and manage your community with ease.
          </p>
        </div>

        {/* Statistics Dashboard */}
        <MemberStats />

        {/* Main Content Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 mb-12">
          {/* Registration Form - Takes 1 column */}
          <div className="lg:col-span-1">
            <MemberRegistrationForm />
          </div>

          {/* Member List - Takes 2 columns */}
          <div className="lg:col-span-2">
            <MemberList />
          </div>
        </div>

        {/* Info Section */}
        <div className="bg-blue-50 border border-blue-200 rounded-lg p-6 mb-8">
          <h3 className="text-lg font-semibold text-blue-900 mb-2">
            🚀 About This Application
          </h3>
          <p className="text-blue-800 mb-3">
            This application has been migrated from a legacy J2EE application with JSF to a modern 
            full-stack architecture:
          </p>
          <ul className="list-disc list-inside text-blue-800 space-y-1 ml-4">
            <li><strong>Backend:</strong> Spring Boot 3.x with Spring MVC, Spring Data JPA, Spring Security</li>
            <li><strong>Frontend:</strong> Next.js 15 with TypeScript, React 19, Tailwind CSS</li>
            <li><strong>API:</strong> RESTful API with JSON responses</li>
            <li><strong>Validation:</strong> Client-side (Zod) and server-side (Bean Validation)</li>
            <li><strong>Data Management:</strong> Real-time updates with React Query</li>
          </ul>
        </div>
      </main>

      <Footer />
    </div>
  );
}
