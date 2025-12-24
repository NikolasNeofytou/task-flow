/**
 * Simple file-based storage for development
 * Replace with a proper database in production
 */

const fs = require('fs');
const path = require('path');

const DATA_FILE = path.join(__dirname, 'data.json');

// Default data structure
const defaultData = {
  users: [
    {
      id: 'user1',
      email: 'demo@taskflow.com',
      displayName: 'Demo User',
      photoUrl: null,
      createdAt: new Date().toISOString(),
    },
  ],
  requests: [
    {
      id: 'req_1',
      title: 'Review UI Design',
      status: 'pending',
      type: 'general',
      fromUserId: 'user1',
      toUserId: null,
      taskId: null,
      projectId: null,
      dueDate: null,
      createdAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000).toISOString(),
      updatedAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000).toISOString(),
    },
    {
      id: 'req_2',
      title: 'Complete Backend Integration',
      status: 'accepted',
      type: 'taskAssignment',
      fromUserId: 'user1',
      toUserId: null,
      taskId: 'task1',
      projectId: 'proj1',
      dueDate: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000).toISOString(),
      createdAt: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000).toISOString(),
      updatedAt: new Date(Date.now() - 12 * 60 * 60 * 1000).toISOString(),
    },
    {
      id: 'req_3',
      title: 'Test Authentication Flow',
      status: 'pending',
      type: 'general',
      fromUserId: 'user1',
      toUserId: null,
      taskId: null,
      projectId: null,
      dueDate: new Date(Date.now() + 1 * 24 * 60 * 60 * 1000).toISOString(),
      createdAt: new Date(Date.now() - 3 * 60 * 60 * 1000).toISOString(),
      updatedAt: new Date(Date.now() - 3 * 60 * 60 * 1000).toISOString(),
    },
  ],
  comments: [],
};

/**
 * Load data from file or return default data
 */
function loadData() {
  try {
    if (fs.existsSync(DATA_FILE)) {
      const fileContent = fs.readFileSync(DATA_FILE, 'utf8');
      return JSON.parse(fileContent);
    }
  } catch (error) {
    console.warn('Failed to load data file, using default data:', error.message);
  }
  return JSON.parse(JSON.stringify(defaultData)); // Deep clone
}

/**
 * Save data to file
 */
function saveData(data) {
  try {
    fs.writeFileSync(DATA_FILE, JSON.stringify(data, null, 2), 'utf8');
  } catch (error) {
    console.error('Failed to save data:', error);
    throw error;
  }
}

/**
 * Reset data to defaults
 */
function resetData() {
  try {
    if (fs.existsSync(DATA_FILE)) {
      fs.unlinkSync(DATA_FILE);
    }
  } catch (error) {
    console.error('Failed to reset data:', error);
  }
}

module.exports = {
  loadData,
  saveData,
  resetData,
  defaultData,
};
