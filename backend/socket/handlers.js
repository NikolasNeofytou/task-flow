const { v4: uuidv4 } = require('uuid');
const { chatMessages, users, audioCalls } = require('../data/store');

/**
 * Socket.IO event handlers
 */
module.exports = (io) => {
  // Store connected users
  const connectedUsers = new Map();

  io.on('connection', (socket) => {
    console.log(`✅ Client connected: ${socket.id}`);

    // User joins
    socket.on('user:join', (data) => {
      const { userId, userName } = data;
      connectedUsers.set(socket.id, { userId, userName });
      
      // Update user status to online
      const user = users.get(userId);
      if (user) {
        user.status = 'online';
        user.lastActiveAt = new Date().toISOString();
        users.set(userId, user);
      }

      socket.broadcast.emit('user:online', { userId, userName });
      console.log(`👤 User joined: ${userName} (${userId})`);
    });

    // Join chat channel
    socket.on('chat:join', (data) => {
      const { channelId } = data;
      socket.join(`chat:${channelId}`);
      console.log(`💬 Joined chat channel: ${channelId}`);
    });

    // Leave chat channel
    socket.on('chat:leave', (data) => {
      const { channelId } = data;
      socket.leave(`chat:${channelId}`);
      console.log(`👋 Left chat channel: ${channelId}`);
    });

    // Send chat message
    socket.on('chat:message', (data) => {
      const { channelId, message } = data;
      const user = connectedUsers.get(socket.id);

      if (!user) {
        socket.emit('error', { message: 'User not authenticated' });
        return;
      }

      const chatMessage = {
        id: uuidv4(),
        channelId,
        userId: user.userId,
        author: user.userName,
        timestamp: new Date().toISOString(),
        type: message.type || 'text',
        text: message.text,
        voicePath: message.voicePath,
        voiceDuration: message.voiceDuration,
        filePath: message.filePath,
        fileName: message.fileName,
        fileSize: message.fileSize,
        fileType: message.fileType,
        viewedBy: [], // Initialize empty viewers list
      };

      // Store message
      const messages = chatMessages.get(channelId) || [];
      messages.push(chatMessage);
      chatMessages.set(channelId, messages);

      // Broadcast to channel
      io.to(`chat:${channelId}`).emit('chat:message', chatMessage);
      console.log(`💬 Message sent to ${channelId}: ${message.text}`);
    });

    // Typing indicator
    socket.on('chat:typing', (data) => {
      const { channelId, isTyping } = data;
      const user = connectedUsers.get(socket.id);

      if (user) {
        socket.to(`chat:${channelId}`).emit('chat:typing', {
          userId: user.userId,
          userName: user.userName,
          isTyping,
        });
      }
    });

    // Mark message as viewed
    socket.on('chat:message:viewed', (data) => {
      const { channelId, messageId } = data;
      const user = connectedUsers.get(socket.id);

      if (!user) {
        socket.emit('error', { message: 'User not authenticated' });
        return;
      }

      const messages = chatMessages.get(channelId) || [];
      const message = messages.find(msg => msg.id === messageId);

      if (message) {
        // Check if user hasn't already viewed this message
        const alreadyViewed = message.viewedBy?.some(viewer => viewer.userId === user.userId);
        
        if (!alreadyViewed) {
          // Add viewer information
          if (!message.viewedBy) {
            message.viewedBy = [];
          }
          
          message.viewedBy.push({
            userId: user.userId,
            userName: user.userName,
            viewedAt: new Date().toISOString(),
          });

          // Broadcast viewer update to channel
          io.to(`chat:${channelId}`).emit('chat:message:viewed', {
            messageId,
            viewer: {
              userId: user.userId,
              userName: user.userName,
              viewedAt: new Date().toISOString(),
            },
          });

          console.log(`👁️ Message ${messageId} viewed by ${user.userName}`);
        }
      }
    });

    // Pin message
    socket.on('chat:message:pin', (data) => {
      const { channelId, messageId } = data;
      const user = connectedUsers.get(socket.id);

      if (!user) {
        socket.emit('error', { message: 'User not authenticated' });
        return;
      }

      const messages = chatMessages.get(channelId) || [];
      const message = messages.find(msg => msg.id === messageId);

      if (message) {
        message.isPinned = true;
        message.pinnedBy = user.userName;
        message.pinnedAt = new Date().toISOString();

        // Broadcast pin update to channel
        io.to(`chat:${channelId}`).emit('chat:message:pinned', {
          messageId,
          pinnedBy: user.userName,
          pinnedAt: message.pinnedAt,
        });

        console.log(`📌 Message ${messageId} pinned by ${user.userName}`);
      }
    });

    // Unpin message
    socket.on('chat:message:unpin', (data) => {
      const { channelId, messageId } = data;
      const user = connectedUsers.get(socket.id);

      if (!user) {
        socket.emit('error', { message: 'User not authenticated' });
        return;
      }

      const messages = chatMessages.get(channelId) || [];
      const message = messages.find(msg => msg.id === messageId);

      if (message) {
        message.isPinned = false;
        message.pinnedBy = null;
        message.pinnedAt = null;

        // Broadcast unpin update to channel
        io.to(`chat:${channelId}`).emit('chat:message:unpinned', {
          messageId,
        });

        console.log(`📌 Message ${messageId} unpinned by ${user.userName}`);
      }
    });

    // Audio call: start
    socket.on('call:start', (data) => {
      const { channelId, channelName, participants } = data;
      const user = connectedUsers.get(socket.id);

      if (!user) {
        socket.emit('error', { message: 'User not authenticated' });
        return;
      }

      const callId = uuidv4();
      const call = {
        id: callId,
        channelId,
        channelName,
        startTime: new Date().toISOString(),
        participants: participants || [{ id: user.userId, name: user.userName }],
      };

      audioCalls.set(callId, call);
      socket.join(`call:${callId}`);

      // Notify channel members
      io.to(`chat:${channelId}`).emit('call:started', call);
      console.log(`📞 Call started: ${callId} in ${channelName}`);

      socket.emit('call:joined', { callId, call });
    });

    // Audio call: join
    socket.on('call:join', (data) => {
      const { callId } = data;
      const user = connectedUsers.get(socket.id);
      const call = audioCalls.get(callId);

      if (!call) {
        socket.emit('error', { message: 'Call not found' });
        return;
      }

      if (!user) {
        socket.emit('error', { message: 'User not authenticated' });
        return;
      }

      // Add participant if not already in call
      if (!call.participants.find(p => p.id === user.userId)) {
        call.participants.push({ id: user.userId, name: user.userName });
        audioCalls.set(callId, call);
      }

      socket.join(`call:${callId}`);

      // Notify other participants
      socket.to(`call:${callId}`).emit('call:participant_joined', {
        userId: user.userId,
        userName: user.userName,
      });

      socket.emit('call:joined', { callId, call });
      console.log(`📞 User joined call: ${user.userName} -> ${callId}`);
    });

    // Audio call: leave
    socket.on('call:leave', (data) => {
      const { callId } = data;
      const user = connectedUsers.get(socket.id);
      const call = audioCalls.get(callId);

      if (!call || !user) return;

      // Remove participant
      call.participants = call.participants.filter(p => p.id !== user.userId);

      // If no participants left, delete call
      if (call.participants.length === 0) {
        audioCalls.delete(callId);
        io.to(`chat:${call.channelId}`).emit('call:ended', { callId });
        console.log(`📞 Call ended: ${callId}`);
      } else {
        audioCalls.set(callId, call);
        socket.to(`call:${callId}`).emit('call:participant_left', {
          userId: user.userId,
          userName: user.userName,
        });
      }

      socket.leave(`call:${callId}`);
      console.log(`📞 User left call: ${user.userName} <- ${callId}`);
    });

    // Audio call: mute toggle
    socket.on('call:mute', (data) => {
      const { callId, isMuted } = data;
      const user = connectedUsers.get(socket.id);

      if (user) {
        socket.to(`call:${callId}`).emit('call:participant_muted', {
          userId: user.userId,
          isMuted,
        });
      }
    });

    // Audio call: speaking indicator
    socket.on('call:speaking', (data) => {
      const { callId, isSpeaking } = data;
      const user = connectedUsers.get(socket.id);

      if (user) {
        socket.to(`call:${callId}`).emit('call:participant_speaking', {
          userId: user.userId,
          isSpeaking,
        });
      }
    });

    // Disconnect
    socket.on('disconnect', () => {
      const user = connectedUsers.get(socket.id);

      if (user) {
        // Update user status to offline
        const userData = users.get(user.userId);
        if (userData) {
          userData.status = 'offline';
          userData.lastActiveAt = new Date().toISOString();
          users.set(user.userId, userData);
        }

        socket.broadcast.emit('user:offline', { userId: user.userId });
        console.log(`👋 User disconnected: ${user.userName}`);
      }

      connectedUsers.delete(socket.id);
      console.log(`❌ Client disconnected: ${socket.id}`);
    });
  });

  console.log('🔌 Socket.IO handlers initialized');
};
