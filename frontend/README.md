# Kitchensink Frontend - Next.js Application

Modern React-based frontend for the Kitchensink member registration application, built with Next.js 15, TypeScript, and Tailwind CSS.

## 🚀 Features

- **Modern UI**: Clean, responsive interface built with Tailwind CSS
- **Type Safety**: Full TypeScript implementation with strict type checking
- **Real-time Updates**: Automatic data refreshing with React Query
- **Form Validation**: Client-side validation matching backend constraints
- **Multiple Views**: Table and card views for member listings
- **Search & Filter**: Full-text search and sorting capabilities
- **Error Handling**: Comprehensive error handling with user-friendly messages
- **Accessibility**: WCAG-compliant components with ARIA attributes
- **Performance**: Optimized with Next.js App Router and Server Components

## 📋 Prerequisites

- **Node.js**: 18.x or higher
- **npm**: 9.x or higher (comes with Node.js)
- **Backend API**: Spring Boot backend running on port 8080

## 🛠️ Installation

1. **Navigate to the frontend directory**:
   ```bash
   cd frontend
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **Configure environment variables**:
   
   Create a `.env.local` file (already configured by default):
   ```bash
   NEXT_PUBLIC_API_URL=http://localhost:8080
   ```

## 🚀 Development

Start the development server:

```bash
npm run dev
```

The application will be available at: [http://localhost:3000](http://localhost:3000)

### Development Features

- **Hot Module Replacement (HMR)**: Instant updates on code changes
- **Error Overlay**: Detailed error messages in development mode
- **TypeScript Checking**: Real-time type checking
- **Turbopack**: Fast bundling with Turbopack

## 🏗️ Building for Production

Build the optimized production bundle:

```bash
npm run build
```

Start the production server:

```bash
npm start
```

## 🐳 Docker

### Build the Docker Image

```bash
docker build -t kitchensink-frontend:latest .
```

With custom API URL:

```bash
docker build \
  --build-arg NEXT_PUBLIC_API_URL=https://api.example.com \
  -t kitchensink-frontend:latest .
```

### Run the Docker Container

```bash
docker run -p 3000:3000 \
  -e NEXT_PUBLIC_API_URL=http://localhost:8080 \
  kitchensink-frontend:latest
```

### Docker Compose

See `docker-compose.yml` in the project root for running both frontend and backend together.

## 📁 Project Structure

```
frontend/
├── src/
│   ├── app/                    # Next.js App Router pages
│   │   ├── layout.tsx          # Root layout
│   │   ├── page.tsx            # Home page
│   │   ├── providers.tsx       # React Query provider
│   │   └── members/[id]/       # Dynamic member detail page
│   ├── components/             # React components
│   │   ├── Header.tsx          # Site header
│   │   ├── Footer.tsx          # Site footer
│   │   ├── MemberRegistrationForm.tsx
│   │   ├── MemberList.tsx      # Member list with search/filter
│   │   ├── MemberTable.tsx     # Table view component
│   │   ├── MemberCard.tsx      # Card view component
│   │   ├── MemberStats.tsx     # Statistics dashboard
│   │   └── ui/                 # Reusable UI components
│   │       ├── FormField.tsx
│   │       ├── Toast.tsx
│   │       ├── LoadingSkeleton.tsx
│   │       └── EmptyState.tsx
│   ├── hooks/                  # Custom React hooks
│   │   ├── useMembers.ts       # Fetch members data
│   │   └── useMemberRegistration.ts
│   ├── lib/                    # Utility libraries
│   │   ├── api-client.ts       # Axios API client
│   │   └── validation-schemas.ts  # Zod validation schemas
│   └── types/                  # TypeScript type definitions
│       └── member.ts
├── public/                     # Static assets
├── .env.local                  # Local environment variables
├── .env.production             # Production environment template
├── Dockerfile                  # Multi-stage production build
├── .dockerignore               # Docker ignore rules
├── next.config.ts              # Next.js configuration
├── tailwind.config.ts          # Tailwind CSS configuration
├── tsconfig.json               # TypeScript configuration
└── package.json                # Dependencies and scripts
```

## 🔌 API Integration

The frontend communicates with the Spring Boot backend via REST API:

### Endpoints Used

- `GET /rest/members` - Fetch all members
- `GET /rest/members/{id}` - Fetch member by ID
- `POST /rest/members` - Register new member

### API Client

The application uses Axios for HTTP requests with:
- Automatic error handling
- Request/response interceptors
- Type-safe API calls
- Validation error extraction

## 📝 Available Scripts

- `npm run dev` - Start development server with Turbopack
- `npm run build` - Build for production
- `npm start` - Start production server
- `npm run lint` - Run ESLint for code quality
- `npm run type-check` - Run TypeScript type checking (if configured)

## 🎨 Styling

- **Tailwind CSS**: Utility-first CSS framework
- **Custom Components**: Reusable styled components
- **Responsive Design**: Mobile-first approach
- **Dark Mode Ready**: Theme support infrastructure

## 🔒 Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `NEXT_PUBLIC_API_URL` | Backend API base URL | `http://localhost:8080` |
| `NODE_ENV` | Environment mode | `development` |

**Note**: Variables prefixed with `NEXT_PUBLIC_` are exposed to the browser.

## 🧪 Testing

*Testing infrastructure can be added with:*

```bash
npm install --save-dev @testing-library/react @testing-library/jest-dom jest jest-environment-jsdom
```

## 🚢 Deployment

### Vercel (Recommended)

1. Push your code to GitHub
2. Import project in Vercel
3. Set environment variable: `NEXT_PUBLIC_API_URL`
4. Deploy

### Docker Deployment

Use the provided Dockerfile for containerized deployment in any Docker-compatible environment (Kubernetes, AWS ECS, Azure Container Apps, etc.).

### Static Export (Optional)

For static hosting, update `next.config.ts`:

```typescript
output: 'export'
```

**Note**: API routes won't work with static export.

## 🔧 Configuration

### CORS

Ensure the backend allows requests from the frontend origin. The Spring Boot backend should be configured with:

```yaml
cors:
  allowed-origins:
    - http://localhost:3000
```

### API Proxy (Development)

The `next.config.ts` includes API rewrites for development:

```typescript
async rewrites() {
  return [
    {
      source: '/api/:path*',
      destination: 'http://localhost:8080/rest/:path*',
    },
  ];
}
```

## 📖 Key Technologies

- **Next.js 15**: React framework with App Router
- **React 19**: Latest React with Server Components
- **TypeScript**: Type-safe development
- **Tailwind CSS**: Utility-first styling
- **React Query (TanStack Query)**: Data fetching and caching
- **React Hook Form**: Efficient form handling
- **Zod**: Schema validation
- **Axios**: HTTP client

## 🤝 Contributing

When making changes:

1. Follow TypeScript best practices
2. Maintain component documentation
3. Keep styling consistent with Tailwind
4. Test responsive layouts
5. Ensure accessibility standards

## 📄 License

This project is part of the Kitchensink application migration from J2EE to Spring Boot + Next.js.

## 🆘 Support

For issues or questions:

1. Check the backend API is running on port 8080
2. Verify environment variables are set correctly
3. Review browser console for error messages
4. Check network tab for failed API requests

## 🔗 Related Documentation

- [Next.js Documentation](https://nextjs.org/docs)
- [React Query Documentation](https://tanstack.com/query/latest)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)
- [TypeScript Documentation](https://www.typescriptlang.org/docs/)
