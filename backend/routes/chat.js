const express = require('express');
const { chatMessages } = require('../data/store');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

/**
 * GET /api/chat/:channelId/messages
 * Get chat messages for a channel
 */
router.get('/:channelId/messages', authenticateToken, (req, res) => {
  const { channelId } = req.params;
  const { limit = 50, before } = req.query;

  let messages = chatMessages.get(channelId) || [];

  // Filter messages before a certain timestamp if provided
  if (before) {
    messages = messages.filter(msg => new Date(msg.timestamp) < new Date(before));
  }

  // Limit results
  messages = messages.slice(-parseInt(limit));

  res.json(messages);
});

/**
 * GET /api/chat/channels
 * Get all channels user has access to
 */
router.get('/channels', authenticateToken, (req, res) => {
  const channels = Array.from(chatMessages.keys()).map(channelId => ({
    id: channelId,
    name: channelId === 'all' ? 'All Projects' : channelId,
    messageCount: (chatMessages.get(channelId) || []).length,
  }));

  res.json(channels);
});

module.exports = router;
