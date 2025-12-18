const express = require('express');
const { v4: uuidv4 } = require('uuid');
const { projects } = require('../data/store');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

/**
 * GET /api/projects
 * Get all projects for current user
 */
router.get('/', authenticateToken, (req, res) => {
  const userProjects = Array.from(projects.values()).filter(project =>
    project.members.includes(req.user.id)
  );

  res.json(userProjects);
});

/**
 * GET /api/projects/:id
 * Get specific project
 */
router.get('/:id', authenticateToken, (req, res) => {
  const project = projects.get(req.params.id);

  if (!project) {
    return res.status(404).json({ error: 'Project not found' });
  }

  if (!project.members.includes(req.user.id)) {
    return res.status(403).json({ error: 'Access denied' });
  }

  res.json(project);
});

/**
 * POST /api/projects
 * Create a new project
 */
router.post('/', authenticateToken, (req, res) => {
  const { name, description, color } = req.body;

  if (!name) {
    return res.status(400).json({ error: 'Project name required' });
  }

  const project = {
    id: uuidv4(),
    name,
    description: description || '',
    color: color || '#9747FF',
    members: [req.user.id],
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };

  projects.set(project.id, project);

  res.status(201).json(project);
});

/**
 * PATCH /api/projects/:id
 * Update a project
 */
router.patch('/:id', authenticateToken, (req, res) => {
  const project = projects.get(req.params.id);

  if (!project) {
    return res.status(404).json({ error: 'Project not found' });
  }

  if (!project.members.includes(req.user.id)) {
    return res.status(403).json({ error: 'Access denied' });
  }

  const { name, description, color } = req.body;

  if (name !== undefined) project.name = name;
  if (description !== undefined) project.description = description;
  if (color !== undefined) project.color = color;

  project.updatedAt = new Date().toISOString();
  projects.set(project.id, project);

  res.json(project);
});

/**
 * DELETE /api/projects/:id
 * Delete a project
 */
router.delete('/:id', authenticateToken, (req, res) => {
  const project = projects.get(req.params.id);

  if (!project) {
    return res.status(404).json({ error: 'Project not found' });
  }

  if (!project.members.includes(req.user.id)) {
    return res.status(403).json({ error: 'Access denied' });
  }

  projects.delete(req.params.id);

  res.json({ message: 'Project deleted successfully' });
});

/**
 * POST /api/projects/:id/members
 * Add member to project
 */
router.post('/:id/members', authenticateToken, (req, res) => {
  const project = projects.get(req.params.id);

  if (!project) {
    return res.status(404).json({ error: 'Project not found' });
  }

  if (!project.members.includes(req.user.id)) {
    return res.status(403).json({ error: 'Access denied' });
  }

  const { userId } = req.body;

  if (!userId) {
    return res.status(400).json({ error: 'User ID required' });
  }

  if (!project.members.includes(userId)) {
    project.members.push(userId);
    project.updatedAt = new Date().toISOString();
    projects.set(project.id, project);
  }

  res.json(project);
});

module.exports = router;
