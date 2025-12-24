const express = require('express');
const { v4: uuidv4 } = require('uuid');
const { loadData, saveData } = require('../data/storage');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Get all comments for a task
router.get('/', authenticateToken, (req, res) => {
  try {
    const { taskId } = req.query;
    
    if (!taskId) {
      return res.status(400).json({ error: 'taskId query parameter is required' });
    }

    const data = loadData();
    const comments = (data.comments || []).filter(c => c.taskId === taskId);
    
    res.json(comments);
  } catch (error) {
    console.error('Error fetching comments:', error);
    res.status(500).json({ error: 'Failed to fetch comments' });
  }
});

// Add a comment to a task
router.post('/', authenticateToken, (req, res) => {
  try {
    const { taskId, content } = req.body;

    if (!taskId || !content) {
      return res.status(400).json({ error: 'taskId and content are required' });
    }

    const data = loadData();
    if (!data.comments) {
      data.comments = [];
    }

    const newComment = {
      id: uuidv4(),
      taskId,
      authorId: req.user.userId,
      authorName: req.user.email.split('@')[0], // Simple name from email
      content,
      createdAt: new Date().toISOString(),
    };

    data.comments.push(newComment);
    saveData(data);

    res.status(201).json(newComment);
  } catch (error) {
    console.error('Error creating comment:', error);
    res.status(500).json({ error: 'Failed to create comment' });
  }
});

// Delete a comment
router.delete('/:id', authenticateToken, (req, res) => {
  try {
    const data = loadData();
    if (!data.comments) {
      return res.status(404).json({ error: 'Comment not found' });
    }

    const commentIndex = data.comments.findIndex(c => c.id === req.params.id);
    
    if (commentIndex === -1) {
      return res.status(404).json({ error: 'Comment not found' });
    }

    const comment = data.comments[commentIndex];
    
    // Only the author can delete their comment
    if (comment.authorId !== req.user.userId) {
      return res.status(403).json({ error: 'Only the comment author can delete it' });
    }

    data.comments.splice(commentIndex, 1);
    saveData(data);

    res.json({ message: 'Comment deleted successfully' });
  } catch (error) {
    console.error('Error deleting comment:', error);
    res.status(500).json({ error: 'Failed to delete comment' });
  }
});

module.exports = router;
