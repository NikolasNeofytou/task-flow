/**
 * In-memory data store (replace with database in production)
 */

const users = new Map();
const projects = new Map();
const tasks = new Map();
const chatMessages = new Map();
const notifications = new Map();
const badges = new Map();
const audioCalls = new Map();

// Initialize with some sample data
function initializeSampleData() {
  // Sample users
  users.set('user1', {
    id: 'user1',
    email: 'demo@taskflow.com',
    displayName: 'Demo User',
    password: '$2a$10$Xw8Qq3qQZqOqZQqZqZqZqOqZqZqZqZqZqZqZqZqZqZqZqZqZq', // "password123"
    photoPath: null,
    status: 'online',
    customStatusMessage: null,
    unlockedBadgeIds: ['first_task', 'team_player'],
    selectedBadgeId: 'first_task',
    createdAt: new Date().toISOString(),
    lastActiveAt: new Date().toISOString(),
  });

  // Sample projects
  projects.set('proj1', {
    id: 'proj1',
    name: 'Project Alpha',
    description: 'First demo project',
    color: '#9747FF',
    members: ['user1'],
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  });

  // Sample tasks
  tasks.set('task1', {
    id: 'task1',
    projectId: 'proj1',
    title: 'Setup backend',
    description: 'Create Node.js backend with Express and Socket.IO',
    status: 'in_progress',
    priority: 'high',
    assignedTo: ['user1'],
    dueDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(),
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  });

  // Initialize empty collections for runtime data
  chatMessages.set('all', []);
  chatMessages.set('proj1', []);
  notifications.set('user1', []);
}

initializeSampleData();

module.exports = {
  users,
  projects,
  tasks,
  chatMessages,
  notifications,
  badges,
  audioCalls,
};
