# Full-Stack Development Quick Start Guide

This guide will help you get started with full-stack development of the Kitchensink application using both the Spring Boot backend and Next.js frontend.

## 🚀 Prerequisites

Before you begin, ensure you have:
1. Docker Desktop installed and running
2. VS Code with Dev Containers extension
3. This repository opened in VS Code
4. Container opened via "Reopen in Container"

## 📋 Step-by-Step Setup

### Step 1: Verify Environment

When the container opens, you should see a welcome message showing:
- Backend: Java 17, Gradle 8.5, Maven 3.9.6
- Frontend: Node.js 20.x, npm 10+

Verify tools are available:
```bash
java -version    # Should show Java 17
node --version   # Should show Node.js 20.x
npm --version    # Should show npm 10+
gradle --version # Should show Gradle 8.5
```

### Step 2: Start the Backend

Open a terminal and start the Spring Boot backend:

```bash
cd kitchensink
gradle bootRun --args='--spring.profiles.active=dev'
```

Wait for the message:
```
Started KitchensinkApplication in X.XXX seconds
```

The backend will be available at: **http://localhost:8080**

Test the backend:
```bash
curl http://localhost:8080/actuator/health
# Should return: {"status":"UP"}

curl http://localhost:8080/rest/members
# Should return: [{"id":0,"name":"John Smith",...}]
```

### Step 3: Start the Frontend

Open a **new terminal** (split terminal or new tab) and start the Next.js frontend:

```bash
cd frontend
npm run dev
```

Wait for the message:
```
▲ Next.js 16.x.x
- Local:        http://localhost:3000
```

The frontend will be available at: **http://localhost:3000**

### Step 4: Access the Application

1. **Frontend UI**: Open http://localhost:3000 in your browser
   - You should see the Kitchensink member registration form
   - The UI will communicate with the backend at http://localhost:8080

2. **Backend API**: Open http://localhost:8080/rest/members
   - You should see JSON array of members
   - This is the raw API that the frontend uses

3. **Health Check**: Open http://localhost:8080/actuator/health
   - Should show `{"status":"UP"}`

## 🎯 Common Development Workflows

### Making Backend Changes

1. Edit Java files in `kitchensink/src/main/java/`
2. Spring Boot DevTools will auto-reload (or stop/restart `gradle bootRun`)
3. Test changes: `cd kitchensink && gradle test`

### Making Frontend Changes

1. Edit TypeScript/React files in `frontend/src/`
2. Next.js will hot-reload automatically (Fast Refresh)
3. Changes appear instantly in browser
4. Check browser console for errors

### Testing the Full Stack

1. **Create a member via UI:**
   - Go to http://localhost:3000
   - Fill out the registration form
   - Submit
   - New member should appear in the list

2. **Verify via API:**
   ```bash
   curl http://localhost:8080/rest/members
   # Should include your newly created member
   ```

3. **Test validation:**
   - Try submitting invalid data (e.g., invalid email)
   - Should see validation errors in the UI
   - Backend returns 400 with detailed error messages

## 🗄️ Using Databases

### Option 1: H2 In-Memory (Default - Dev Profile)

Already running with backend! No setup needed.

- Database: H2 (in-memory)
- Console: http://localhost:8080/h2-console
- JDBC URL: `jdbc:h2:mem:kitchensink-dev`
- Username: `sa`
- Password: (empty)

### Option 2: MySQL (Production-like)

Start MySQL:
```bash
docker-compose -f .devcontainer/docker-compose.yml up -d mysql
```

Stop backend (Ctrl+C), then restart with prod profile:
```bash
cd kitchensink
gradle bootRun --args='--spring.profiles.active=prod'
```

Connect to MySQL:
```bash
mysql -h localhost -u kitchensink -pkitchensink kitchensink
```

### Option 3: PostgreSQL

Start PostgreSQL:
```bash
docker-compose -f .devcontainer/docker-compose.yml up -d postgres
```

Update `application-prod.yml` to use PostgreSQL (or create `application-postgres.yml`)

## 🐛 Debugging

### Debug Backend (Java)

1. Stop the backend (Ctrl+C)
2. Start with debug enabled:
   ```bash
   cd kitchensink
   gradle bootRun --debug-jvm
   ```
3. In VS Code:
   - Go to Run and Debug (Ctrl+Shift+D)
   - Select "Attach to Remote Java Application"
   - Click Start Debugging (F5)
4. Set breakpoints in Java files
5. Trigger the code (e.g., create member via frontend)

### Debug Frontend (Next.js)

1. Frontend already running with `npm run dev`
2. Open browser DevTools (F12)
3. Go to Sources tab
4. Set breakpoints in TypeScript files
5. Or use React DevTools extension for component inspection

### View Logs

**Backend logs:**
```bash
# In the terminal running gradle bootRun
# Logs appear automatically
```

**Frontend logs:**
```bash
# In the terminal running npm run dev
# Logs appear automatically
# Also check browser console for client-side logs
```

## 📦 Building for Production

### Build Backend

```bash
cd kitchensink
gradle build
# JAR created at: build/libs/jboss-kitchensink-6.4.0-SNAPSHOT.jar
```

Run production JAR:
```bash
java -jar build/libs/jboss-kitchensink-*.jar --spring.profiles.active=prod
```

### Build Frontend

```bash
cd frontend
npm run build
# Optimized production build created in .next/
```

Start production frontend:
```bash
npm run start
# Runs on http://localhost:3000
```

### Build Docker Images

**Backend:**
```bash
cd kitchensink
docker build -t kitchensink-backend:latest .
```

**Frontend:**
```bash
cd frontend
docker build -t kitchensink-frontend:latest .
```

## 🔄 Resetting Your Environment

### Clear Backend Build Cache
```bash
cd kitchensink
gradle clean
rm -rf build/
```

### Clear Frontend Node Modules
```bash
cd frontend
rm -rf node_modules .next
npm install
```

### Reset Databases
```bash
docker-compose -f .devcontainer/docker-compose.yml down -v
docker-compose -f .devcontainer/docker-compose.yml up -d
```

## ⚡ Performance Tips

1. **Keep dependencies installed:**
   - Backend: Keep Gradle cache at `/workspace/.gradle`
   - Frontend: Keep node_modules cached

2. **Use Hot Reload:**
   - Backend: Spring DevTools enables auto-restart
   - Frontend: Next.js Fast Refresh enables instant updates

3. **Parallel Development:**
   - Run backend and frontend simultaneously
   - Use split terminals in VS Code
   - Each runs on different port (no conflicts)

4. **Database Choice:**
   - Dev: Use H2 (fastest, in-memory)
   - Integration Testing: Use MySQL/PostgreSQL
   - Production: Use external managed database

## 🎨 VS Code Tips

### Recommended Terminal Layout

1. Open integrated terminal (Ctrl+`)
2. Split terminal (Ctrl+Shift+5)
3. Terminal 1: Backend (`cd kitchensink && gradle bootRun`)
4. Terminal 2: Frontend (`cd frontend && npm run dev`)
5. Terminal 3: Free for commands, git, etc.

### Recommended Extensions

All pre-installed! But useful to know:
- **Backend**: Java Extension Pack, Spring Boot Dashboard
- **Frontend**: ESLint, Prettier, ES7 React snippets
- **Common**: GitLens, REST Client, Docker

### Keyboard Shortcuts

- `Ctrl+P`: Quick file open
- `Ctrl+Shift+P`: Command palette
- `F5`: Start debugging
- `Ctrl+\``: Toggle terminal
- `Ctrl+B`: Toggle sidebar

## 📚 Next Steps

1. **Explore the Code:**
   - Backend: `kitchensink/src/main/java/org/jboss/as/quickstarts/kitchensink/`
   - Frontend: `frontend/src/app/`

2. **Read Documentation:**
   - Backend: See `kitchensink/README.md`
   - Frontend: See `frontend/README.md`

3. **Make Changes:**
   - Add new REST endpoints in backend
   - Create new React components in frontend
   - Test full stack integration

4. **Run Tests:**
   - Backend: `cd kitchensink && gradle test`
   - Frontend: Add tests with Jest/React Testing Library

## 🆘 Troubleshooting

### Port Already in Use

```bash
# Check what's using port 8080 or 3000
lsof -i :8080
lsof -i :3000

# Kill the process
kill -9 <PID>
```

### Backend Won't Start

```bash
# Check Java version
java -version  # Must be 17

# Check Gradle
gradle --version

# Clean and rebuild
cd kitchensink
gradle clean build
```

### Frontend Won't Start

```bash
# Check Node.js version
node --version  # Must be 20.x

# Reinstall dependencies
cd frontend
rm -rf node_modules package-lock.json
npm install
```

### CORS Errors

If frontend can't reach backend:

1. Check backend is running: `curl http://localhost:8080/actuator/health`
2. Check CORS configuration in `SecurityConfig.java`
3. Verify frontend uses correct API URL: Check `.env.local`

### Database Connection Failed

```bash
# Check database is running
docker-compose -f .devcontainer/docker-compose.yml ps

# Start database
docker-compose -f .devcontainer/docker-compose.yml up -d mysql

# Check connection
mysql -h localhost -u kitchensink -pkitchensink kitchensink
```

## 💡 Pro Tips

1. **Use REST Client extension**: Create `.http` files to test APIs directly in VS Code
2. **Enable Auto Save**: File → Auto Save
3. **Use Git frequently**: Commit small changes often
4. **Watch logs**: Keep terminal visible to catch errors early
5. **Browser DevTools**: Network tab shows API calls, Console shows errors

## 🎉 You're Ready!

You now have a complete full-stack development environment with:
- ✅ Spring Boot backend running on port 8080
- ✅ Next.js frontend running on port 3000
- ✅ Hot reload enabled for fast development
- ✅ Debugging configured for both sides
- ✅ Database options (H2, MySQL, PostgreSQL)

Happy coding! 🚀
