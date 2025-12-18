const express = require('express');
const { users } = require('../data/store');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

/**
 * GET /api/users/me
 * Get current user profile
 */
router.get('/me', authenticateToken, (req, res) => {
  const user = users.get(req.user.id);
  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }

  const { password, ...userWithoutPassword } = user;
  res.json(userWithoutPassword);
});

/**
 * PATCH /api/users/me
 * Update current user profile
 */
router.patch('/me', authenticateToken, (req, res) => {
  const user = users.get(req.user.id);
  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }

  const { displayName, photoPath, status, customStatusMessage } = req.body;

  if (displayName !== undefined) user.displayName = displayName;
  if (photoPath !== undefined) user.photoPath = photoPath;
  if (status !== undefined) user.status = status;
  if (customStatusMessage !== undefined) user.customStatusMessage = customStatusMessage;

  user.lastActiveAt = new Date().toISOString();
  users.set(user.id, user);

  const { password, ...userWithoutPassword } = user;
  res.json(userWithoutPassword);
});

/**
 * POST /api/users/me/badges/:badgeId/unlock
 * Unlock a badge for current user
 */
router.post('/me/badges/:badgeId/unlock', authenticateToken, (req, res) => {
  const user = users.get(req.user.id);
  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }

  const { badgeId } = req.params;

  if (!user.unlockedBadgeIds.includes(badgeId)) {
    user.unlockedBadgeIds.push(badgeId);
    users.set(user.id, user);
  }

  const { password, ...userWithoutPassword } = user;
  res.json(userWithoutPassword);
});

/**
 * PUT /api/users/me/badges/selected
 * Set selected badge for display
 */
router.put('/me/badges/selected', authenticateToken, (req, res) => {
  const user = users.get(req.user.id);
  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }

  const { badgeId } = req.body;

  user.selectedBadgeId = badgeId;
  users.set(user.id, user);

  const { password, ...userWithoutPassword } = user;
  res.json(userWithoutPassword);
});

/**
 * GET /api/users
 * Get all users (for team features)
 */
router.get('/', authenticateToken, (req, res) => {
  const allUsers = Array.from(users.values()).map(user => {
    const { password, ...userWithoutPassword } = user;
    return userWithoutPassword;
  });

  res.json(allUsers);
});

/**
 * GET /api/users/:userId
 * Get user by ID (for QR code validation)
 */
router.get('/:userId', authenticateToken, (req, res) => {
  const { userId } = req.params;
  const user = users.get(userId);
  
  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }

  const { password, ...userWithoutPassword } = user;
  res.json(userWithoutPassword);
});

/**
 * POST /api/users/team/add
 * Add a user to current user's team via QR code
 */
router.post('/team/add', authenticateToken, (req, res) => {
  const currentUser = users.get(req.user.id);
  if (!currentUser) {
    return res.status(404).json({ error: 'Current user not found' });
  }

  const { userId, email, displayName } = req.body;

  // Validate the user being added exists
  const userToAdd = users.get(userId);
  if (!userToAdd) {
    return res.status(404).json({ 
      error: 'User not found',
      message: 'The user you are trying to add does not exist.'
    });
  }

  // Verify the data matches (basic security check)
  if (userToAdd.email !== email || userToAdd.displayName !== displayName) {
    return res.status(400).json({ 
      error: 'Invalid user data',
      message: 'User information does not match. QR code may be invalid.'
    });
  }

  // Prevent adding yourself
  if (userId === req.user.id) {
    return res.status(400).json({ 
      error: 'Invalid operation',
      message: 'You cannot add yourself to your team.'
    });
  }

  // Initialize team array if it doesn't exist
  if (!currentUser.team) {
    currentUser.team = [];
  }

  // Check if user is already in team
  if (currentUser.team.includes(userId)) {
    return res.status(400).json({ 
      error: 'Already in team',
      message: `${displayName} is already in your team.`
    });
  }

  // Add user to team
  currentUser.team.push(userId);
  currentUser.lastActiveAt = new Date().toISOString();
  users.set(currentUser.id, currentUser);

  // Add current user to the other user's team (bidirectional)
  if (!userToAdd.team) {
    userToAdd.team = [];
  }
  if (!userToAdd.team.includes(req.user.id)) {
    userToAdd.team.push(req.user.id);
  }
  users.set(userId, userToAdd);

  // Create notification for the added user
  const notificationId = `notif_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  const notification = {
    id: notificationId,
    userId: userId,
    type: 'team_invite_accepted',
    title: 'New Team Member',
    message: `${currentUser.displayName} added you to their team via QR code!`,
    data: {
      fromUserId: req.user.id,
      fromUserName: currentUser.displayName,
      addedAt: new Date().toISOString(),
    },
    isRead: false,
    createdAt: new Date().toISOString(),
  };

  const { notifications } = require('../data/store');
  notifications.set(notificationId, notification);

  // Return success with user info
  const { password, ...userWithoutPassword } = userToAdd;
  res.json({
    success: true,
    message: `${displayName} has been added to your team!`,
    user: userWithoutPassword,
    teamSize: currentUser.team.length,
  });
});

/**
 * GET /api/users/me/team
 * Get current user's team members
 */
router.get('/me/team', authenticateToken, (req, res) => {
  const currentUser = users.get(req.user.id);
  if (!currentUser) {
    return res.status(404).json({ error: 'User not found' });
  }

  if (!currentUser.team || currentUser.team.length === 0) {
    return res.json({ team: [] });
  }

  // Get full user objects for team members
  const teamMembers = currentUser.team
    .map(userId => users.get(userId))
    .filter(user => user !== undefined)
    .map(user => {
      const { password, ...userWithoutPassword } = user;
      return userWithoutPassword;
    });

  res.json({ 
    team: teamMembers,
    count: teamMembers.length 
  });
});

/**
 * DELETE /api/users/me/team/:userId
 * Remove a user from current user's team
 */
router.delete('/me/team/:userId', authenticateToken, (req, res) => {
  const currentUser = users.get(req.user.id);
  if (!currentUser) {
    return res.status(404).json({ error: 'User not found' });
  }

  const { userId } = req.params;

  if (!currentUser.team || !currentUser.team.includes(userId)) {
    return res.status(400).json({ 
      error: 'User not in team',
      message: 'This user is not in your team.'
    });
  }

  // Remove user from team
  currentUser.team = currentUser.team.filter(id => id !== userId);
  users.set(currentUser.id, currentUser);

  // Remove current user from the other user's team (bidirectional)
  const otherUser = users.get(userId);
  if (otherUser && otherUser.team) {
    otherUser.team = otherUser.team.filter(id => id !== req.user.id);
    users.set(userId, otherUser);
  }

  res.json({ 
    success: true,
    message: 'User removed from team',
    teamSize: currentUser.team.length
  });
});

module.exports = router;
