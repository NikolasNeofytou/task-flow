const express = require('express');
const { v4: uuidv4 } = require('uuid');
const { tasks, projects } = require('../data/store');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

/**
 * GET /api/tasks
 * Get all tasks for current user
 */
router.get('/', authenticateToken, (req, res) => {
  const { projectId, status } = req.query;

  let userTasks = Array.from(tasks.values()).filter(task =>
    task.assignedTo.includes(req.user.id)
  );

  if (projectId) {
    userTasks = userTasks.filter(task => task.projectId === projectId);
  }

  if (status) {
    userTasks = userTasks.filter(task => task.status === status);
  }

  res.json(userTasks);
});

/**
 * GET /api/tasks/:id
 * Get specific task
 */
router.get('/:id', authenticateToken, (req, res) => {
  const task = tasks.get(req.params.id);

  if (!task) {
    return res.status(404).json({ error: 'Task not found' });
  }

  if (!task.assignedTo.includes(req.user.id)) {
    return res.status(403).json({ error: 'Access denied' });
  }

  res.json(task);
});

/**
 * POST /api/tasks
 * Create a new task
 */
router.post('/', authenticateToken, (req, res) => {
  const { projectId, title, description, priority, dueDate, assignedTo } = req.body;

  if (!projectId || !title) {
    return res.status(400).json({ error: 'Project ID and title required' });
  }

  // Verify project access
  const project = projects.get(projectId);
  if (!project || !project.members.includes(req.user.id)) {
    return res.status(403).json({ error: 'Access denied to project' });
  }

  const task = {
    id: uuidv4(),
    projectId,
    title,
    description: description || '',
    status: 'todo',
    priority: priority || 'medium',
    assignedTo: assignedTo || [req.user.id],
    dueDate: dueDate || null,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };

  tasks.set(task.id, task);

  res.status(201).json(task);
});

/**
 * PATCH /api/tasks/:id
 * Update a task
 */
router.patch('/:id', authenticateToken, (req, res) => {
  const task = tasks.get(req.params.id);

  if (!task) {
    return res.status(404).json({ error: 'Task not found' });
  }

  if (!task.assignedTo.includes(req.user.id)) {
    return res.status(403).json({ error: 'Access denied' });
  }

  const { title, description, status, priority, dueDate, assignedTo } = req.body;

  if (title !== undefined) task.title = title;
  if (description !== undefined) task.description = description;
  if (status !== undefined) task.status = status;
  if (priority !== undefined) task.priority = priority;
  if (dueDate !== undefined) task.dueDate = dueDate;
  if (assignedTo !== undefined) task.assignedTo = assignedTo;

  task.updatedAt = new Date().toISOString();
  tasks.set(task.id, task);

  res.json(task);
});

/**
 * DELETE /api/tasks/:id
 * Delete a task
 */
router.delete('/:id', authenticateToken, (req, res) => {
  const task = tasks.get(req.params.id);

  if (!task) {
    return res.status(404).json({ error: 'Task not found' });
  }

  if (!task.assignedTo.includes(req.user.id)) {
    return res.status(403).json({ error: 'Access denied' });
  }

  tasks.delete(req.params.id);

  res.json({ message: 'Task deleted successfully' });
});

module.exports = router;
