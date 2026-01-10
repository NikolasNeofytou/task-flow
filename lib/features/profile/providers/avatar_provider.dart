import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final avatarProvider =
    AsyncNotifierProvider<AvatarController, Uint8List?>(AvatarController.new);

class AvatarController extends AsyncNotifier<Uint8List?> {
  static const _prefsKey = 'profile_avatar_b64';

  @override
  Future<Uint8List?> build() async {
    final prefs = await SharedPreferences.getInstance();
    final b64 = prefs.getString(_prefsKey);
    if (b64 == null || b64.isEmpty) return null;

    try {
      return base64Decode(b64);
    } catch (_) {
      return null;
    }
  }

  Future<void> pickAndSaveAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true, // IMPORTANT: για Web δίνει bytes
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, base64Encode(bytes));

    // update state για να φανεί άμεσα
    state = AsyncData(Uint8List.fromList(bytes));
  }

  Future<void> clearAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    state = const AsyncData(null);
  }
}