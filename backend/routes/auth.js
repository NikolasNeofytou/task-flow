const express = require('express');
const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');
const { users } = require('../data/store');
const { generateToken } = require('../middleware/auth');

const router = express.Router();

/**
 * POST /api/auth/signup
 * Register a new user
 */
router.post('/signup', async (req, res) => {
  try {
    const { email, displayName, password } = req.body;

    // Validation
    if (!email || !displayName || !password) {
      return res.status(400).json({ error: 'All fields are required' });
    }

    // Check if user already exists
    const existingUser = Array.from(users.values()).find(u => u.email === email);
    if (existingUser) {
      return res.status(409).json({ error: 'Email already registered' });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create user
    const user = {
      id: uuidv4(),
      email,
      displayName,
      password: hashedPassword,
      photoPath: null,
      status: 'online',
      customStatusMessage: null,
      unlockedBadgeIds: ['first_task'],
      selectedBadgeId: null,
      createdAt: new Date().toISOString(),
      lastActiveAt: new Date().toISOString(),
    };

    users.set(user.id, user);

    // Generate token
    const token = generateToken(user);

    // Return user data (without password)
    const { password: _, ...userWithoutPassword } = user;

    res.status(201).json({
      user: userWithoutPassword,
      token,
    });
  } catch (error) {
    console.error('Signup error:', error);
    res.status(500).json({ error: 'Signup failed' });
  }
});

/**
 * POST /api/auth/login
 * Login user
 */
router.post('/login', async (req, res) => {
  console.log('🔑 Login request received:', { email: req.body.email });
  try {
    const { email, password } = req.body;

    // Validation
    if (!email || !password) {
      console.log('❌ Missing email or password');
      return res.status(400).json({ error: 'Email and password required' });
    }

    // Find user
    const user = Array.from(users.values()).find(u => u.email === email);
    if (!user) {
      console.log('❌ User not found:', email);
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    
    console.log('✅ User found:', user.displayName);

    // For demo purposes, skip password validation for demo user
    if (email === 'demo@taskflow.com') {
      console.log('🔓 Demo user - skipping password validation');
    } else {
      // Check password for other users
      const validPassword = await bcrypt.compare(password, user.password);
      console.log('🔐 Password validation:', validPassword ? '✅ Valid' : '❌ Invalid');
      if (!validPassword) {
        console.log('❌ Password mismatch for user:', email);
        return res.status(401).json({ error: 'Invalid credentials' });
      }
    }

    // Update last active
    user.lastActiveAt = new Date().toISOString();
    users.set(user.id, user);

    // Generate token
    const token = generateToken(user);

    // Return user data (without password)
    const { password: _, ...userWithoutPassword } = user;

    console.log('✅ Login successful for:', user.displayName);
    res.json({
      user: userWithoutPassword,
      token,
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Login failed' });
  }
});

module.exports = router;
