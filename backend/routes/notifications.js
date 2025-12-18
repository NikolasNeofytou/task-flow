const express = require('express');
const { notifications } = require('../data/store');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

/**
 * GET /api/notifications
 * Get notifications for current user
 */
router.get('/', authenticateToken, (req, res) => {
  const userNotifications = notifications.get(req.user.id) || [];

  res.json(userNotifications);
});

/**
 * PATCH /api/notifications/:id/read
 * Mark notification as read
 */
router.patch('/:id/read', authenticateToken, (req, res) => {
  const userNotifications = notifications.get(req.user.id) || [];
  const notification = userNotifications.find(n => n.id === req.params.id);

  if (!notification) {
    return res.status(404).json({ error: 'Notification not found' });
  }

  notification.read = true;
  notifications.set(req.user.id, userNotifications);

  res.json(notification);
});

/**
 * DELETE /api/notifications/:id
 * Delete a notification
 */
router.delete('/:id', authenticateToken, (req, res) => {
  const userNotifications = notifications.get(req.user.id) || [];
  const updatedNotifications = userNotifications.filter(n => n.id !== req.params.id);

  notifications.set(req.user.id, updatedNotifications);

  res.json({ message: 'Notification deleted successfully' });
});

module.exports = router;
