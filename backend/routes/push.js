const express = require('express');
const { fcmTokens } = require('../data/store');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

/**
 * POST /api/notifications/register-device
 * Register FCM token for push notifications
 */
router.post('/register-device', authenticateToken, (req, res) => {
  const { fcmToken, platform } = req.body;

  if (!fcmToken) {
    return res.status(400).json({ error: 'FCM token is required' });
  }

  // Store FCM token for user
  const userTokens = fcmTokens.get(req.user.id) || [];
  
  // Check if token already exists
  const existingToken = userTokens.find(t => t.token === fcmToken);
  
  if (!existingToken) {
    userTokens.push({
      token: fcmToken,
      platform: platform || 'unknown',
      registeredAt: new Date().toISOString(),
    });
    fcmTokens.set(req.user.id, userTokens);
  }

  res.json({ message: 'Device registered successfully' });
});

/**
 * DELETE /api/notifications/register-device
 * Unregister FCM token
 */
router.delete('/register-device', authenticateToken, (req, res) => {
  const { fcmToken } = req.body;

  const userTokens = fcmTokens.get(req.user.id) || [];
  const updatedTokens = userTokens.filter(t => t.token !== fcmToken);
  
  fcmTokens.set(req.user.id, updatedTokens);

  res.json({ message: 'Device unregistered successfully' });
});

/**
 * POST /api/notifications/send-push
 * Send push notification to user(s) - Internal use
 */
router.post('/send-push', authenticateToken, async (req, res) => {
  const { userIds, title, body, data } = req.body;

  if (!userIds || !Array.isArray(userIds) || userIds.length === 0) {
    return res.status(400).json({ error: 'userIds array is required' });
  }

  if (!title || !body) {
    return res.status(400).json({ error: 'title and body are required' });
  }

  // Get all FCM tokens for target users
  const tokens = [];
  userIds.forEach(userId => {
    const userTokens = fcmTokens.get(userId) || [];
    tokens.push(...userTokens.map(t => t.token));
  });

  if (tokens.length === 0) {
    return res.json({ 
      message: 'No devices registered for target users',
      sent: 0 
    });
  }

  try {
    // NOTE: This is a placeholder for actual FCM API call
    // In production, you would use Firebase Admin SDK:
    // 
    // const admin = require('firebase-admin');
    // const message = {
    //   notification: { title, body },
    //   data: data || {},
    //   tokens: tokens
    // };
    // const response = await admin.messaging().sendMulticast(message);
    
    console.log(`[PUSH] Would send to ${tokens.length} devices:`, { title, body, data });

    res.json({ 
      message: 'Push notifications queued (mock)',
      sent: tokens.length,
      tokens: tokens.length
    });
  } catch (error) {
    console.error('Failed to send push notification:', error);
    res.status(500).json({ error: 'Failed to send push notification' });
  }
});

/**
 * Helper function to send push notification (for internal use)
 */
function sendPushToUser(userId, title, body, data = {}) {
  const userTokens = fcmTokens.get(userId) || [];
  const tokens = userTokens.map(t => t.token);

  if (tokens.length === 0) {
    console.log(`[PUSH] No devices for user ${userId}`);
    return;
  }

  console.log(`[PUSH] Sending to user ${userId}:`, { title, body, data });
  
  // NOTE: Replace with actual FCM call in production
  // This is a mock implementation for development
}

module.exports = { 
  router,
  sendPushToUser 
};
