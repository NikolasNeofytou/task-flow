import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _tokenKey = 'auth_token';
final _secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final authTokenProvider =
    AsyncNotifierProvider<AuthTokenController, String?>(AuthTokenController.new);

class AuthTokenController extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    final storage = ref.read(_secureStorageProvider);
    return storage.read(key: _tokenKey);
  }

  Future<void> setToken(String? token) async {
    final storage = ref.read(_secureStorageProvider);
    if (token == null || token.isEmpty) {
      await storage.delete(key: _tokenKey);
      state = const AsyncData(null);
    } else {
      await storage.write(key: _tokenKey, value: token);
      state = AsyncData(token);
    }
  }
}
