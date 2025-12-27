# Quick Start for Your Friends

## Run TaskFlow Backend in 3 Steps

```bash
# 1. Clone repo
git clone YOUR_REPO_URL
cd task-flow

# 2. Start backend
docker-compose up -d

# 3. Done! Backend running on http://localhost:3000
```

## Test It Works

```bash
curl http://localhost:3000/health
```

Should return: `{"status":"ok","timestamp":"..."}`

## Stop Backend

```bash
docker-compose down
```

## See Full Guide

Check [DOCKER_SETUP.md](DOCKER_SETUP.md) for complete documentation.
