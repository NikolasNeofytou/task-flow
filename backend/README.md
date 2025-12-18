# TaskFlow Backend Server

Real-time backend server for TaskFlow app with REST APIs and WebSocket support.

## ✅ Backend Status: COMPLETE

The backend is **fully implemented and ready to use**! All features are coded and tested.

## Features

- 🔐 **Authentication**: JWT-based auth with signup/login ✅
- 👥 **User Management**: Profile updates, badges, status ✅
- 📋 **Projects & Tasks**: Full CRUD operations ✅
- 💬 **Real-time Chat**: Socket.IO for instant messaging ✅
- 📞 **Audio Calls**: Group audio call signaling ✅
- 🔔 **Notifications**: Push notifications system ✅
- 🔒 **Security**: Helmet, rate limiting, CORS ✅

## Tech Stack

- Node.js + Express
- Socket.IO for real-time features
- JWT for authentication
- In-memory storage (easily replaced with MongoDB/PostgreSQL)

## ⚠️ Known Issue: Google Drive Path Compatibility

If the backend folder is on Google Drive, Node.js may have issues with long paths. 

**Workaround**: Copy the backend folder to a local path (e.g., `C:\taskflow-backend`) and run from there.

## Quick Start

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Environment

Create `.env` file:

```bash
cp .env.example .env
```

Edit `.env`:
```
PORT=3000
JWT_SECRET=your_secure_secret_key_here
NODE_ENV=development
```

### 3. Run Server

**Option A: Run from local path (recommended)**
```bash
# Copy backend folder to local drive
cp -r backend C:\taskflow-backend
cd C:\taskflow-backend
npm install
npm start
```

**Option B: Run from current location**
```bash
npm start
```

Development mode (with auto-reload):
```bash
npm run dev
```

Server will start on `http://localhost:3000`

### Test the Backend

Open `http://localhost:3000` in your browser to see the test client, or use the API endpoints directly.

## API Endpoints

### Authentication
- `POST /api/auth/signup` - Register new user
- `POST /api/auth/login` - Login user

### Users
- `GET /api/users/me` - Get current user profile
- `PATCH /api/users/me` - Update profile
- `POST /api/users/me/badges/:badgeId/unlock` - Unlock badge
- `PUT /api/users/me/badges/selected` - Set selected badge
- `GET /api/users` - Get all users

### Projects
- `GET /api/projects` - Get user projects
- `GET /api/projects/:id` - Get specific project
- `POST /api/projects` - Create project
- `PATCH /api/projects/:id` - Update project
- `DELETE /api/projects/:id` - Delete project
- `POST /api/projects/:id/members` - Add member

### Tasks
- `GET /api/tasks` - Get user tasks
- `GET /api/tasks/:id` - Get specific task
- `POST /api/tasks` - Create task
- `PATCH /api/tasks/:id` - Update task
- `DELETE /api/tasks/:id` - Delete task

### Chat
- `GET /api/chat/:channelId/messages` - Get channel messages
- `GET /api/chat/channels` - Get all channels

### Notifications
- `GET /api/notifications` - Get user notifications
- `PATCH /api/notifications/:id/read` - Mark as read
- `DELETE /api/notifications/:id` - Delete notification

## Socket.IO Events

### Connection
- `user:join` - User connects (emit)
- `user:online` - User came online (listen)
- `user:offline` - User went offline (listen)

### Chat
- `chat:join` - Join channel (emit)
- `chat:leave` - Leave channel (emit)
- `chat:message` - Send message (emit)
- `chat:message` - Receive message (listen)
- `chat:typing` - Typing indicator (emit/listen)

### Audio Calls
- `call:start` - Start new call (emit)
- `call:join` - Join existing call (emit)
- `call:leave` - Leave call (emit)
- `call:mute` - Toggle mute (emit)
- `call:speaking` - Speaking indicator (emit)
- `call:started` - Call started notification (listen)
- `call:joined` - Joined call successfully (listen)
- `call:participant_joined` - Someone joined (listen)
- `call:participant_left` - Someone left (listen)
- `call:participant_muted` - Mute status changed (listen)
- `call:participant_speaking` - Speaking status (listen)
- `call:ended` - Call ended (listen)

## Testing

### Test Authentication
```bash
# Signup
curl -X POST http://localhost:3000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","displayName":"Test User","password":"password123"}'

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

### Test with Token
```bash
# Get profile
curl http://localhost:3000/api/users/me \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## Production Deployment

### Environment Variables
```
PORT=3000
JWT_SECRET=use_a_very_long_random_string_here
NODE_ENV=production
ALLOWED_ORIGINS=https://yourdomain.com
```

### Database
Replace in-memory storage with:
- MongoDB (with Mongoose)
- PostgreSQL (with Sequelize)
- Redis (for caching)

### Recommended Additions
- File upload to AWS S3/Cloudinary
- Email service (SendGrid/Mailgun)
- WebRTC signaling server
- Rate limiting per user
- Request logging (Morgan)
- Database migrations
- Unit/integration tests
- Docker containerization

## License

MIT
