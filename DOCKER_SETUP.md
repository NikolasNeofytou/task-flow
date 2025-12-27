# 🐳 Docker Setup Guide

## Quick Start for Friends

Your friends can run the entire TaskFlow backend with just 3 commands:

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/task-flow.git
cd task-flow

# 2. Start the backend with Docker
docker-compose up -d

# 3. Backend is now running on http://localhost:3000
```

That's it! No Node.js installation needed, no dependency issues.

---

## What's Included

The Docker setup includes:
- **Backend API Server** (Node.js + Express)
- **Socket.IO** for real-time features
- **Auto-restart** if container crashes
- **Health checks** for monitoring
- **Hot reload** during development

---

## Prerequisites

Install Docker Desktop:
- **Windows/Mac**: [Docker Desktop](https://www.docker.com/products/docker-desktop)
- **Linux**: [Docker Engine](https://docs.docker.com/engine/install/)

Verify installation:
```bash
docker --version
docker-compose --version
```

---

## Commands

### Start the Backend
```bash
# Start in background
docker-compose up -d

# Start with logs visible
docker-compose up
```

### Stop the Backend
```bash
docker-compose down
```

### View Logs
```bash
# Follow logs
docker-compose logs -f

# View last 50 lines
docker-compose logs --tail=50
```

### Restart Services
```bash
docker-compose restart
```

### Rebuild After Code Changes
```bash
# Rebuild and restart
docker-compose up -d --build

# Or rebuild without cache
docker-compose build --no-cache
docker-compose up -d
```

---

## Testing the Backend

Once running, test these endpoints:

**Health Check:**
```bash
curl http://localhost:3000/health
```

**Login:**
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@taskflow.com","password":"demo123"}'
```

**Get Projects (with auth token):**
```bash
curl http://localhost:3000/api/projects \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## Environment Configuration

### Default Settings
The backend works out-of-the-box with these defaults:
- **Port**: 3000
- **CORS**: Allow all origins (*)
- **JWT Secret**: Demo key (change for production!)
- **Environment**: development

### Custom Configuration
Create a `.env` file in the `backend/` directory:

```bash
cd backend
cp .env.example .env
# Edit .env with your values
```

Example `.env`:
```env
NODE_ENV=production
PORT=3000
JWT_SECRET=your-super-secret-key-here
JWT_EXPIRES_IN=7d
CORS_ORIGIN=http://localhost:8080
```

Then restart:
```bash
docker-compose down
docker-compose up -d
```

---

## Development Mode

The Docker setup includes hot reload for development:

1. Edit files in `backend/`
2. Changes are automatically detected
3. Server restarts inside container
4. No need to rebuild!

To see live logs:
```bash
docker-compose logs -f backend
```

---

## Production Deployment

### Security Checklist
Before deploying to production:

1. **Change JWT Secret**
   ```env
   JWT_SECRET=use-a-strong-random-secret-here
   ```

2. **Set CORS Origin**
   ```env
   CORS_ORIGIN=https://yourdomain.com
   ```

3. **Use Production Mode**
   ```env
   NODE_ENV=production
   ```

4. **Add Database** (Optional)
   Currently uses in-memory storage. For production, add PostgreSQL or MongoDB:
   
   ```yaml
   # Add to docker-compose.yml
   postgres:
     image: postgres:15-alpine
     environment:
       POSTGRES_DB: taskflow
       POSTGRES_USER: taskflow
       POSTGRES_PASSWORD: secure-password
     volumes:
       - postgres-data:/var/lib/postgresql/data
   ```

### Deploy to Cloud

**AWS ECS:**
```bash
docker build -t taskflow-backend ./backend
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin YOUR_ECR_URL
docker tag taskflow-backend:latest YOUR_ECR_URL/taskflow-backend:latest
docker push YOUR_ECR_URL/taskflow-backend:latest
```

**DigitalOcean:**
```bash
doctl auth init
doctl apps create --spec .do/app.yaml
```

**Heroku:**
```bash
heroku container:login
heroku container:push web -a your-app-name
heroku container:release web -a your-app-name
```

---

## Troubleshooting

### Port Already in Use
If port 3000 is busy, change it in `docker-compose.yml`:
```yaml
ports:
  - "3001:3000"  # Use port 3001 instead
```

### Container Won't Start
Check logs:
```bash
docker-compose logs backend
```

Common issues:
- Missing dependencies: `docker-compose build --no-cache`
- Permission errors: Run Docker as admin/sudo
- Port conflicts: Change port in docker-compose.yml

### Can't Connect from Flutter App
1. **Windows/Mac**: Use `http://localhost:3000`
2. **Android Emulator**: Use `http://10.0.2.2:3000`
3. **iOS Simulator**: Use `http://localhost:3000`
4. **Physical Device**: Use your computer's IP: `http://192.168.1.X:3000`

Find your IP:
- **Windows**: `ipconfig`
- **Mac/Linux**: `ifconfig` or `ip addr`

### Performance Issues
Increase Docker resources:
1. Docker Desktop → Settings → Resources
2. Increase CPU: 4 cores
3. Increase Memory: 4GB
4. Apply & Restart

---

## Docker Commands Cheat Sheet

```bash
# View running containers
docker ps

# View all containers (including stopped)
docker ps -a

# Stop specific container
docker stop taskflow-backend

# Remove container
docker rm taskflow-backend

# View container logs
docker logs taskflow-backend

# Execute command in container
docker exec -it taskflow-backend sh

# View resource usage
docker stats

# Clean up unused images/containers
docker system prune -a
```

---

## Multi-User Development

### Share with Friends

**Option 1: Docker Hub**
```bash
# Build and tag
docker build -t yourusername/taskflow-backend:latest ./backend

# Push to Docker Hub
docker login
docker push yourusername/taskflow-backend:latest

# Friends can pull
docker pull yourusername/taskflow-backend:latest
docker run -p 3000:3000 yourusername/taskflow-backend:latest
```

**Option 2: Export/Import**
```bash
# Save image to file
docker save taskflow-backend > taskflow-backend.tar

# Friends load the image
docker load < taskflow-backend.tar
docker run -p 3000:3000 taskflow-backend
```

**Option 3: GitHub + Auto Build**
Friends just need to:
```bash
git clone YOUR_REPO_URL
cd task-flow
docker-compose up -d
```

---

## Next Steps

- ✅ Backend running in Docker
- 🔄 Configure Flutter app to connect
- 🔐 Set up Firebase (optional)
- 🚀 Deploy to cloud (optional)

**Flutter Configuration:**
Update `lib/core/constants/api_config.dart`:
```dart
static const String baseUrl = 'http://YOUR_IP:3000/api';
```

**Need Help?**
- Check logs: `docker-compose logs -f`
- Restart: `docker-compose restart`
- Rebuild: `docker-compose up -d --build`
- Discord/Slack: [Your support channel]
