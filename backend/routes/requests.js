const express = require('express');
const { authenticateToken } = require('../middleware/auth');
const { loadData, saveData } = require('../data/storage');

const router = express.Router();

// Get all requests for the authenticated user
router.get('/', authenticateToken, (req, res) => {
  try {
    const data = loadData();
    const userRequests = data.requests.filter(
      (request) => request.fromUserId === req.user.userId || request.toUserId === req.user.userId
    );
    res.json(userRequests);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch requests' });
  }
});

// Get a specific request by ID
router.get('/:id', authenticateToken, (req, res) => {
  try {
    const data = loadData();
    const request = data.requests.find((r) => r.id === req.params.id);
    
    if (!request) {
      return res.status(404).json({ error: 'Request not found' });
    }

    // Check if user has access to this request
    if (request.fromUserId !== req.user.userId && request.toUserId !== req.user.userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    res.json(request);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch request' });
  }
});

// Create a new request
router.post('/', authenticateToken, (req, res) => {
  try {
    const { title, type = 'general', toUserId, taskId, projectId, dueDate } = req.body;

    if (!title) {
      return res.status(400).json({ error: 'Title is required' });
    }

    const data = loadData();
    const newRequest = {
      id: `req_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      title,
      status: 'pending',
      type,
      fromUserId: req.user.userId,
      toUserId: toUserId || null,
      taskId: taskId || null,
      projectId: projectId || null,
      dueDate: dueDate || null,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    data.requests.push(newRequest);
    saveData(data);

    res.status(201).json(newRequest);
  } catch (error) {
    console.error('Error creating request:', error);
    res.status(500).json({ error: 'Failed to create request' });
  }
});

// Update request status (accept/reject)
router.patch('/:id', authenticateToken, (req, res) => {
  try {
    const { status } = req.body;
    
    if (!status) {
      return res.status(400).json({ error: 'Status is required' });
    }

    if (!['pending', 'accepted', 'rejected', 'sent'].includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }

    const data = loadData();
    const requestIndex = data.requests.findIndex((r) => r.id === req.params.id);

    if (requestIndex === -1) {
      return res.status(404).json({ error: 'Request not found' });
    }

    const request = data.requests[requestIndex];

    // Check if user has access to this request
    if (request.fromUserId !== req.user.userId && request.toUserId !== req.user.userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    // Update the request
    data.requests[requestIndex] = {
      ...request,
      status,
      updatedAt: new Date().toISOString(),
    };

    saveData(data);
    res.json(data.requests[requestIndex]);
  } catch (error) {
    console.error('Error updating request:', error);
    res.status(500).json({ error: 'Failed to update request' });
  }
});

// Delete a request
router.delete('/:id', authenticateToken, (req, res) => {
  try {
    const data = loadData();
    const requestIndex = data.requests.findIndex((r) => r.id === req.params.id);

    if (requestIndex === -1) {
      return res.status(404).json({ error: 'Request not found' });
    }

    const request = data.requests[requestIndex];

    // Only the creator can delete the request
    if (request.fromUserId !== req.user.userId) {
      return res.status(403).json({ error: 'Only the request creator can delete it' });
    }

    data.requests.splice(requestIndex, 1);
    saveData(data);

    res.json({ message: 'Request deleted successfully' });
  } catch (error) {
    console.error('Error deleting request:', error);
    res.status(500).json({ error: 'Failed to delete request' });
  }
});

module.exports = router;
