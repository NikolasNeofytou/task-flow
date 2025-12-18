import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../models/user_profile_model.dart';
import '../models/badge_model.dart';

/// Provider for user profile state
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
  return UserProfileNotifier();
});

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  UserProfileNotifier() : super(null) {
    _loadProfile();
  }

  final _storage = const FlutterSecureStorage();
  final _imagePicker = ImagePicker();

  /// Load profile from storage
  Future<void> _loadProfile() async {
    try {
      final email = await _storage.read(key: 'user_email');
      final displayName = await _storage.read(key: 'user_displayName');
      final photoPath = await _storage.read(key: 'user_photoPath');
      final statusStr = await _storage.read(key: 'user_status');
      final customStatus = await _storage.read(key: 'user_customStatus');
      final badgesStr = await _storage.read(key: 'user_unlockedBadges');
      final selectedBadge = await _storage.read(key: 'user_selectedBadge');

      if (email != null && displayName != null) {
        final status = UserStatus.values.firstWhere(
          (s) => s.toString() == statusStr,
          orElse: () => UserStatus.online,
        );

        final unlockedBadges = badgesStr?.split(',').where((s) => s.isNotEmpty).toList() ?? [];

        state = UserProfile(
          id: 'current_user',
          email: email,
          displayName: displayName,
          photoPath: photoPath,
          status: status,
          customStatusMessage: customStatus,
          unlockedBadgeIds: unlockedBadges,
          selectedBadgeId: selectedBadge,
          createdAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  /// Create new profile (signup)
  Future<void> createProfile({
    required String email,
    required String displayName,
  }) async {
    try {
      final profile = UserProfile(
        id: 'current_user',
        email: email,
        displayName: displayName,
        status: UserStatus.online,
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
        unlockedBadgeIds: ['first_task'], // Give first badge
      );

      await _storage.write(key: 'user_email', value: email);
      await _storage.write(key: 'user_displayName', value: displayName);
      await _storage.write(key: 'user_status', value: UserStatus.online.toString());
      await _storage.write(key: 'user_unlockedBadges', value: 'first_task');
      await _storage.write(key: 'onboarding_complete', value: 'true');

      state = profile;
    } catch (e) {
      debugPrint('Error creating profile: $e');
      rethrow;
    }
  }

  /// Update profile picture from device
  Future<void> updateProfilePicture() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image == null) return;

      // Save to app directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = '${directory.path}/$fileName';
      
      await File(image.path).copy(savedPath);

      // Delete old photo if exists
      if (state?.photoPath != null) {
        try {
          await File(state!.photoPath!).delete();
        } catch (e) {
          debugPrint('Could not delete old photo: $e');
        }
      }

      await _storage.write(key: 'user_photoPath', value: savedPath);
      state = state?.copyWith(photoPath: savedPath);
    } catch (e) {
      debugPrint('Error updating profile picture: $e');
      rethrow;
    }
  }

  /// Update user status
  Future<void> updateStatus(UserStatus newStatus, {String? customMessage}) async {
    try {
      await _storage.write(key: 'user_status', value: newStatus.toString());
      if (customMessage != null) {
        await _storage.write(key: 'user_customStatus', value: customMessage);
      }
      
      state = state?.copyWith(
        status: newStatus,
        customStatusMessage: customMessage,
        lastActiveAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error updating status: $e');
    }
  }

  /// Unlock a badge
  Future<void> unlockBadge(String badgeId) async {
    if (state == null) return;
    
    final current = List<String>.from(state!.unlockedBadgeIds);
    if (!current.contains(badgeId)) {
      current.add(badgeId);
      await _storage.write(key: 'user_unlockedBadges', value: current.join(','));
      state = state!.copyWith(unlockedBadgeIds: current);
    }
  }

  /// Update profile information
  Future<void> updateProfile({
    String? displayName,
    String? email,
  }) async {
    if (state == null) return;
    
    try {
      if (displayName != null) {
        await _storage.write(key: 'user_displayName', value: displayName);
      }
      if (email != null) {
        await _storage.write(key: 'user_email', value: email);
      }
      
      state = state!.copyWith(
        displayName: displayName,
        email: email,
        lastActiveAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }

  /// Select a badge to display
  Future<void> selectBadge(String? badgeId) async {
    if (badgeId != null) {
      await _storage.write(key: 'user_selectedBadge', value: badgeId);
    } else {
      await _storage.delete(key: 'user_selectedBadge');
    }
    state = state?.copyWith(selectedBadgeId: badgeId);
  }

  /// Check if onboarding is complete
  Future<bool> isOnboardingComplete() async {
    final complete = await _storage.read(key: 'onboarding_complete');
    return complete == 'true';
  }

  /// Logout
  Future<void> logout() async {
    await _storage.deleteAll();
    state = null;
  }
}

/// Provider for badge collection with unlock status
final badgesProvider = Provider<List<AppBadge>>((ref) {
  final profile = ref.watch(userProfileProvider);
  if (profile == null) return BadgeCollection.all;

  return BadgeCollection.all.map((badge) {
    final isUnlocked = profile.unlockedBadgeIds.contains(badge.id);
    return badge.copyWith(
      isUnlocked: isUnlocked,
      unlockedAt: isUnlocked ? DateTime.now() : null,
    );
  }).toList();
});
