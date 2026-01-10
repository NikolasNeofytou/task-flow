const express = require('express');
const { projects, users } = require('../data/store');
const router = express.Router();

// In-memory storage for invites (in production, use database)
const invites = new Map();

/**
 * GET /api/invites/:token
 * Validate an invite token and get project info
 */
router.get('/:token', (req, res) => {
  try {
    const { token } = req.params;
    console.log('🔍 Validating invite token:', token);

    const invite = invites.get(token);
    if (!invite) {
      console.log('❌ Invalid invite token:', token);
      return res.status(404).json({ error: 'Invalid invite token' });
    }

    // Check if invite has expired
    if (invite.expiresAt && new Date() > invite.expiresAt) {
      console.log('⏰ Invite token expired:', token);
      invites.delete(token);
      return res.status(410).json({ error: 'Invite token has expired' });
    }

    const project = projects.get(invite.projectId);
    if (!project) {
      console.log('❌ Project not found for invite:', invite.projectId);
      return res.status(404).json({ error: 'Project not found' });
    }

    console.log('✅ Invite token valid for project:', project.name);
    res.json({
      projectId: invite.projectId,
      projectName: project.name,
      projectDescription: project.description,
      projectColor: project.color,
      inviterName: invite.inviterName,
      createdAt: invite.createdAt,
      expiresAt: invite.expiresAt,
    });
  } catch (error) {
    console.error('Invite validation error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * POST /api/invites/:token/accept
 * Accept an invite and join the project
 */
router.post('/:token/accept', (req, res) => {
  try {
    const { token } = req.params;
    const { userId } = req.body; // In real app, get from auth token

    console.log('📨 Processing invite acceptance:', { token, userId });

    const invite = invites.get(token);
    if (!invite) {
      return res.status(404).json({ error: 'Invalid invite token' });
    }

    // Check if invite has expired
    if (invite.expiresAt && new Date() > invite.expiresAt) {
      invites.delete(token);
      return res.status(410).json({ error: 'Invite token has expired' });
    }

    const project = projects.get(invite.projectId);
    if (!project) {
      return res.status(404).json({ error: 'Project not found' });
    }

    const user = users.get(userId || 'user1'); // Default to demo user
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Add user to project if not already a member
    if (!project.members.includes(user.id)) {
      project.members.push(user.id);
      projects.set(project.id, project);
      console.log('✅ User joined project:', { userId: user.id, projectId: project.id });
    }

    // Mark invite as used if single-use
    if (invite.singleUse) {
      invites.delete(token);
      console.log('🗑️ Single-use invite consumed:', token);
    }

    res.json({
      success: true,
      project: {
        id: project.id,
        name: project.name,
        description: project.description,
        color: project.color,
      },
      message: `Successfully joined ${project.name}`,
    });
  } catch (error) {
    console.error('Invite acceptance error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * POST /api/invites/generate
 * Generate a new project invite
 */
router.post('/generate', (req, res) => {
  try {
    const { projectId, inviterName, expiresIn, singleUse } = req.body;

    console.log('🎫 Generating invite for project:', projectId);

    const project = projects.get(projectId);
    if (!project) {
      return res.status(404).json({ error: 'Project not found' });
    }

    // Generate random token
    const token = require('crypto').randomBytes(16).toString('hex');
    
    // Set expiration (default 7 days)
    const expiresAt = expiresIn 
      ? new Date(Date.now() + expiresIn * 1000)
      : new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);

    const invite = {
      token,
      projectId,
      projectName: project.name,
      inviterName: inviterName || 'TaskFlow User',
      createdAt: new Date().toISOString(),
      expiresAt,
      singleUse: singleUse || false,
    };

    // Store invite
    invites.set(token, invite);

    // Generate deep link
    const inviteUrl = `taskflow://invite/${projectId}/${token}`;
    
    console.log('✅ Invite generated:', { token, projectId, inviteUrl });

    res.json({
      token,
      inviteUrl,
      qrData: inviteUrl,
      project: {
        id: project.id,
        name: project.name,
        description: project.description,
      },
      expiresAt: expiresAt.toISOString(),
    });
  } catch (error) {
    console.error('Invite generation error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * GET /api/invites/project/:projectId
 * Get all active invites for a project
 */
router.get('/project/:projectId', (req, res) => {
  try {
    const { projectId } = req.params;
    
    const projectInvites = Array.from(invites.values())
      .filter(invite => invite.projectId === projectId)
      .map(invite => ({
        token: invite.token,
        inviterName: invite.inviterName,
        createdAt: invite.createdAt,
        expiresAt: invite.expiresAt,
        singleUse: invite.singleUse,
      }));

    res.json({ invites: projectInvites });
  } catch (error) {
    console.error('Project invites error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;