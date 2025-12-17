# 🚀 Kitchensink Deployment Guide

Complete deployment guide for the Kitchensink full-stack application.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Local Development](#local-development)
- [Docker Deployment](#docker-deployment)
- [Production Deployment](#production-deployment)
- [Cloud Deployment](#cloud-deployment)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### For Local Development
- Java 17+
- Node.js 18+
- Maven 3.8+ or Gradle 8.5+
- MySQL 8.x (optional, H2 in-memory available)

### For Docker Deployment
- Docker 20.x+
- Docker Compose 2.x+

### For Production
- Kubernetes cluster or cloud platform
- MySQL/PostgreSQL database
- SSL certificates
- Domain name

## 🖥️ Local Development

### Step 1: Clone Repository

```bash
git clone <repository-url>
cd jboss-eap-kitchensink
```

### Step 2: Backend Setup

```bash
cd kitchensink

# Option 1: Maven
./mvnw clean install
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev

# Option 2: Gradle
./gradlew clean build
./gradlew bootRun --args='--spring.profiles.active=dev'
```

**Backend runs on**: http://localhost:8080

**Test the API**:
```bash
curl http://localhost:8080/rest/members
curl http://localhost:8080/actuator/health
```

### Step 3: Frontend Setup

```bash
cd frontend

# Install dependencies
npm install

# Start development server
npm run dev
```

**Frontend runs on**: http://localhost:3000

### Step 4: Verify Integration

1. Open browser: http://localhost:3000
2. Register a new member
3. Verify member appears in list
4. Check H2 console: http://localhost:8080/h2-console
   - JDBC URL: `jdbc:h2:mem:kitchensink-dev`
   - Username: `sa`
   - Password: (empty)

## 🐳 Docker Deployment

### Quick Start with Docker Compose

#### Step 1: Configure Environment

```bash
# Copy environment template
cp .env.example .env

# Edit .env file with your values
nano .env
```

**Minimum required settings**:
```env
MYSQL_ROOT_PASSWORD=your_secure_password
MYSQL_PASSWORD=your_secure_password
DB_PASSWORD=your_secure_password
```

#### Step 2: Build and Start

```bash
# Build and start all services
docker-compose up --build

# OR run in detached mode
docker-compose up -d --build
```

#### Step 3: Verify Deployment

```bash
# Check container status
docker-compose ps

# View logs
docker-compose logs -f

# Check health
curl http://localhost:8080/actuator/health  # Backend
curl http://localhost:3000/api/health       # Frontend
```

#### Step 4: Access Application

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8080/rest/members
- **Health Check**: http://localhost:8080/actuator/health

### Docker Commands Reference

```bash
# Stop services
docker-compose down

# Stop and remove volumes (WARNING: deletes data)
docker-compose down -v

# Rebuild specific service
docker-compose up -d --build frontend

# View logs for specific service
docker-compose logs -f backend

# Execute command in container
docker-compose exec backend bash
docker-compose exec mysql mysql -u kitchensink -p

# Scale services (if configured)
docker-compose up -d --scale backend=3
```

## 🚢 Production Deployment

### Pre-Deployment Checklist

- [ ] Database credentials secured
- [ ] SSL certificates obtained
- [ ] Environment variables configured
- [ ] CORS origins updated
- [ ] Logging configured
- [ ] Health checks configured
- [ ] Backup strategy defined
- [ ] Monitoring setup (e.g., Prometheus, Grafana)
- [ ] Container vulnerability scanning completed

### Option 1: Docker on VPS/Server

#### Step 1: Server Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker --version
docker-compose --version
```

#### Step 2: Deploy Application

```bash
# Clone repository
git clone <repository-url>
cd jboss-eap-kitchensink

# Configure production environment
cp .env.example .env
nano .env  # Update with production values

# Important: Update these in .env
# - MYSQL_ROOT_PASSWORD (strong password)
# - MYSQL_PASSWORD (strong password)
# - ALLOWED_ORIGINS (your domain)
# - NEXT_PUBLIC_API_URL (your API domain)
```

#### Step 3: Configure SSL (Recommended)

**Using Nginx Reverse Proxy**:

```bash
# Install Nginx
sudo apt install nginx -y

# Install Certbot for Let's Encrypt
sudo apt install certbot python3-certbot-nginx -y

# Obtain SSL certificate
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Configure Nginx
sudo nano /etc/nginx/sites-available/kitchensink
```

**Nginx configuration**:
```nginx
upstream backend {
    server localhost:8080;
}

upstream frontend {
    server localhost:3000;
}

server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com www.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

    # Frontend
    location / {
        proxy_pass http://frontend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # Backend API
    location /rest/ {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /actuator/ {
        proxy_pass http://backend;
        proxy_set_header Host $host;
    }
}
```

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/kitchensink /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
```

#### Step 4: Start Application

```bash
# Start with production profile
SPRING_PROFILES_ACTIVE=prod docker-compose up -d --build

# Verify
docker-compose ps
docker-compose logs -f
```

#### Step 5: Setup Monitoring

```bash
# View logs
docker-compose logs -f backend
docker-compose logs -f frontend

# Setup log rotation
sudo nano /etc/logrotate.d/docker-containers
```

### Option 2: Kubernetes Deployment

#### Prerequisites

- Kubernetes cluster (EKS, GKE, AKS, or self-hosted)
- kubectl configured
- Helm (optional but recommended)

#### Step 1: Create Namespace

```bash
kubectl create namespace kitchensink
kubectl config set-context --current --namespace=kitchensink
```

#### Step 2: Create Secrets

```bash
# Database credentials
kubectl create secret generic mysql-credentials \
  --from-literal=root-password='your_root_password' \
  --from-literal=username='kitchensink' \
  --from-literal=password='your_secure_password'

# Backend secrets
kubectl create secret generic backend-secrets \
  --from-literal=db-url='jdbc:mysql://mysql-service:3306/kitchensink' \
  --from-literal=allowed-origins='https://yourdomain.com'
```

#### Step 3: Deploy MySQL

**mysql-deployment.yaml**:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql-service
spec:
  ports:
    - port: 3306
  selector:
    app: mysql
  clusterIP: None
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  serviceName: mysql-service
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        ports:
        - containerPort: 3306
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-credentials
              key: root-password
        - name: MYSQL_DATABASE
          value: kitchensink
        - name: MYSQL_USER
          valueFrom:
            secretKeyRef:
              name: mysql-credentials
              key: username
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-credentials
              key: password
        volumeMounts:
        - name: mysql-storage
          mountPath: /var/lib/mysql
  volumeClaimTemplates:
  - metadata:
      name: mysql-storage
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 10Gi
```

#### Step 4: Deploy Backend

**backend-deployment.yaml**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: your-registry/kitchensink-backend:latest
        ports:
        - containerPort: 8080
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "prod"
        - name: DB_URL
          valueFrom:
            secretKeyRef:
              name: backend-secrets
              key: db-url
        - name: DB_USERNAME
          valueFrom:
            secretKeyRef:
              name: mysql-credentials
              key: username
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-credentials
              key: password
        - name: ALLOWED_ORIGINS
          valueFrom:
            secretKeyRef:
              name: backend-secrets
              key: allowed-origins
        livenessProbe:
          httpGet:
            path: /actuator/health/liveness
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /actuator/health/readiness
            port: 8080
          initialDelaySeconds: 20
          periodSeconds: 5
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
  selector:
    app: backend
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
  type: ClusterIP
```

#### Step 5: Deploy Frontend

**frontend-deployment.yaml**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: your-registry/kitchensink-frontend:latest
        ports:
        - containerPort: 3000
        env:
        - name: NEXT_PUBLIC_API_URL
          value: "https://api.yourdomain.com"
        livenessProbe:
          httpGet:
            path: /api/health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /api/health
            port: 3000
          initialDelaySeconds: 20
          periodSeconds: 5
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
spec:
  selector:
    app: frontend
  ports:
    - protocol: TCP
      port: 3000
      targetPort: 3000
  type: ClusterIP
```

#### Step 6: Configure Ingress

**ingress.yaml**:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kitchensink-ingress
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - yourdomain.com
    - api.yourdomain.com
    secretName: kitchensink-tls
  rules:
  - host: yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 3000
  - host: api.yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 8080
```

#### Step 7: Apply Configurations

```bash
kubectl apply -f mysql-deployment.yaml
kubectl apply -f backend-deployment.yaml
kubectl apply -f frontend-deployment.yaml
kubectl apply -f ingress.yaml

# Verify
kubectl get pods
kubectl get services
kubectl get ingress
```

## ☁️ Cloud Deployment

### AWS ECS/Fargate

1. Push images to ECR
2. Create ECS cluster
3. Define task definitions
4. Create services
5. Configure Application Load Balancer
6. Setup RDS for MySQL

### Google Cloud Run

1. Push images to Artifact Registry
2. Deploy backend to Cloud Run
3. Deploy frontend to Cloud Run
4. Setup Cloud SQL for MySQL
5. Configure custom domain

### Azure Container Apps

1. Push images to ACR
2. Create Container App environment
3. Deploy containers
4. Setup Azure Database for MySQL
5. Configure custom domain

## 🔍 Troubleshooting

### Container Issues

**Container won't start**:
```bash
# Check logs
docker-compose logs backend
docker-compose logs frontend

# Check container status
docker-compose ps

# Inspect container
docker inspect kitchensink-backend
```

**Health checks failing**:
```bash
# Test manually
docker-compose exec backend curl http://localhost:8080/actuator/health
docker-compose exec frontend curl http://localhost:3000/api/health

# Check resource usage
docker stats
```

### Database Issues

**Connection refused**:
```bash
# Verify MySQL is running
docker-compose ps mysql

# Check MySQL logs
docker-compose logs mysql

# Test connection
docker-compose exec mysql mysql -u kitchensink -p
```

**Data not persisting**:
```bash
# Check volume
docker volume ls
docker volume inspect jboss-eap-kitchensink_mysql_data

# Backup data
docker-compose exec mysql mysqldump -u kitchensink -p kitchensink > backup.sql
```

### Network Issues

**CORS errors**:
- Verify `ALLOWED_ORIGINS` includes frontend URL
- Check browser console for error details
- Verify backend CORS configuration

**Frontend can't reach backend**:
- Check `NEXT_PUBLIC_API_URL` is correct
- Verify backend is accessible from frontend container
- Test: `docker-compose exec frontend curl http://backend:8080/actuator/health`

### Performance Issues

**Slow response times**:
```bash
# Check resource usage
docker stats

# Increase container resources
# Edit docker-compose.yml:
# deploy:
#   resources:
#     limits:
#       cpus: '2'
#       memory: 2G
```

### SSL/HTTPS Issues

**Certificate errors**:
```bash
# Renew Let's Encrypt certificate
sudo certbot renew

# Verify certificate
openssl s_client -connect yourdomain.com:443
```

## 📊 Monitoring

### Basic Monitoring

```bash
# Container health
docker-compose ps

# Resource usage
docker stats

# Logs
docker-compose logs -f --tail=100
```

### Production Monitoring

- **Application Metrics**: Spring Boot Actuator + Prometheus
- **Logs**: ELK Stack (Elasticsearch, Logstash, Kibana)
- **APM**: New Relic, Datadog, or AppDynamics
- **Uptime**: UptimeRobot, Pingdom

## 🔄 Updates and Maintenance

### Update Application

```bash
# Pull latest changes
git pull origin main

# Rebuild and restart
docker-compose up -d --build

# Or specific service
docker-compose up -d --build frontend
```

### Database Backup

```bash
# Create backup
docker-compose exec mysql mysqldump -u root -p kitchensink > backup_$(date +%Y%m%d).sql

# Restore backup
docker-compose exec -T mysql mysql -u root -p kitchensink < backup_20240115.sql
```

### Container Updates

```bash
# Update base images
docker-compose pull

# Rebuild with latest base images
docker-compose build --no-cache
docker-compose up -d
```

---

**For more information, see [README_FULLSTACK.md](./README_FULLSTACK.md)**
