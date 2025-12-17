# ⚡ Quick Start Guide

Get the Kitchensink application running in under 5 minutes!

## 🎯 Choose Your Path

### Path 1: Docker Compose (Easiest - Recommended)

**Requirements**: Docker + Docker Compose installed

```bash
# 1. Clone and navigate
git clone <repository-url>
cd jboss-eap-kitchensink

# 2. Configure environment
cp .env.example .env
# Edit .env and set passwords (or use defaults for testing)

# 3. Start everything
docker-compose up --build

# 4. Open your browser
# http://localhost:3000
```

**That's it!** 🎉

The application will:
- Start MySQL database on port 3306
- Start Spring Boot backend on port 8080
- Start Next.js frontend on port 3000

---

### Path 2: Local Development (More Control)

**Requirements**: Java 17+, Node.js 18+, Maven/Gradle

#### Terminal 1 - Start Backend

```bash
cd kitchensink

# With Maven
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev

# OR with Gradle  
./gradlew bootRun --args='--spring.profiles.active=dev'
```

✅ Backend running at: http://localhost:8080

#### Terminal 2 - Start Frontend

```bash
cd frontend

# Install dependencies
npm install

# Start development server
npm run dev
```

✅ Frontend running at: http://localhost:3000

---

### Path 3: Individual Docker Containers

#### Start Backend

```bash
cd kitchensink
docker build -t kitchensink-backend:latest .
docker run -p 8080:8080 -e SPRING_PROFILES_ACTIVE=dev kitchensink-backend:latest
```

#### Start Frontend

```bash
cd frontend
docker build --build-arg NEXT_PUBLIC_API_URL=http://localhost:8080 -t kitchensink-frontend:latest .
docker run -p 3000:3000 -e NEXT_PUBLIC_API_URL=http://localhost:8080 kitchensink-frontend:latest
```

---

## 🧪 Test It Out

1. **Open the application**: http://localhost:3000

2. **Register a member**:
   - Name: "John Doe"
   - Email: "john.doe@example.com"
   - Phone: "1234567890"
   - Click "Register"

3. **Verify**:
   - Member appears in the list
   - Statistics update
   - Click on member to view details

4. **Try the search**: Type "John" in the search box

5. **Test different views**: Toggle between Table and Grid views

## 🔍 Verify Backend API

```bash
# Health check
curl http://localhost:8080/actuator/health

# Get all members
curl http://localhost:8080/rest/members

# Register via API
curl -X POST http://localhost:8080/rest/members \
  -H "Content-Type: application/json" \
  -d '{"name":"Jane Doe","email":"jane@example.com","phoneNumber":"9876543210"}'
```

## 📱 Access Points

| Service | URL | Description |
|---------|-----|-------------|
| Frontend | http://localhost:3000 | Main application UI |
| Backend API | http://localhost:8080/rest/members | REST API |
| Health Check | http://localhost:8080/actuator/health | Backend health |
| H2 Console | http://localhost:8080/h2-console | Database (dev mode) |

**H2 Console Credentials (dev mode only)**:
- JDBC URL: `jdbc:h2:mem:kitchensink-dev`
- Username: `sa`
- Password: (leave empty)

## 🛑 Stop Services

### Docker Compose
```bash
docker-compose down
```

### Local Development
Press `Ctrl+C` in each terminal

### Individual Containers
```bash
docker ps  # Get container IDs
docker stop <container-id>
```

## 🐛 Troubleshooting

### Port Already in Use

**Frontend (3000)**:
```bash
# Find process
lsof -i :3000
# Kill it
kill -9 <PID>
```

**Backend (8080)**:
```bash
# Find process
lsof -i :8080
# Kill it
kill -9 <PID>
```

### Docker Issues

**Container won't start**:
```bash
# Check logs
docker-compose logs backend
docker-compose logs frontend
```

**Port conflicts**:
```bash
# Edit docker-compose.yml and change ports:
ports:
  - "8081:8080"  # Backend on 8081
  - "3001:3000"  # Frontend on 3001
```

### Frontend Can't Connect to Backend

1. Check backend is running: `curl http://localhost:8080/actuator/health`
2. Check CORS is configured (it should be)
3. Verify `.env.local`: `NEXT_PUBLIC_API_URL=http://localhost:8080`
4. Restart frontend

### Database Connection Failed

**For Docker Compose**:
```bash
# Check MySQL is healthy
docker-compose ps

# View MySQL logs
docker-compose logs mysql

# Reset everything
docker-compose down -v  # WARNING: Deletes data
docker-compose up --build
```

**For Local Dev with H2**:
- No action needed, H2 runs in-memory

## 📚 Next Steps

Once you have it running:

1. **Explore the UI**: Try all features (search, filter, sort, views)
2. **Check the API**: Use curl or Postman to test endpoints
3. **View the Database**: Connect to H2 console (dev) or MySQL
4. **Read the Docs**: See `README_FULLSTACK.md` for complete information
5. **Customize**: Modify code and see hot reload in action

## 🔗 Documentation Links

| Document | Purpose |
|----------|---------|
| [README_FULLSTACK.md](./README_FULLSTACK.md) | Complete project documentation |
| [DEPLOYMENT.md](./DEPLOYMENT.md) | Production deployment guide |
| [frontend/README.md](./frontend/README.md) | Frontend-specific documentation |
| [FRONTEND_IMPLEMENTATION_SUMMARY.md](./FRONTEND_IMPLEMENTATION_SUMMARY.md) | Detailed frontend implementation |
| [COMPLETE_IMPLEMENTATION_SUMMARY.md](./COMPLETE_IMPLEMENTATION_SUMMARY.md) | Full implementation summary |

## ⚡ Environment Variables (Optional)

For Docker Compose, create `.env` file:

```env
# Database
MYSQL_ROOT_PASSWORD=rootpassword
MYSQL_PASSWORD=kitchensinkpass

# Backend
SPRING_PROFILES_ACTIVE=prod
DB_PASSWORD=kitchensinkpass

# Frontend
NEXT_PUBLIC_API_URL=http://localhost:8080

# CORS
ALLOWED_ORIGINS=http://localhost:3000
```

## 🎉 You're Ready!

The application is now running. Start registering members and exploring the features!

### Need Help?

- Check the logs: `docker-compose logs -f`
- Review troubleshooting section above
- Read the full documentation
- Verify prerequisites are installed

---

**Happy Coding! 🚀**
