import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

class TokenStorage {
  static const _tokenKey = 'auth_token';

  String? _cachedToken;
  bool _loadedFromDisk = false;

  Future<void> saveToken(String token, {bool persist = true}) async {
    _cachedToken = token;
    _loadedFromDisk = true;
    final prefs = await SharedPreferences.getInstance();
    if (persist) {
      await prefs.setString(_tokenKey, token);
    } else {
      // Memory-only session: ensure no stale persisted token survives refresh.
      await prefs.remove(_tokenKey);
    }
  }

  Future<String?> getToken() async {
    if (_loadedFromDisk) return _cachedToken;
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString(_tokenKey);
    _loadedFromDisk = true;
    return _cachedToken;
  }

  String? get cachedToken => _loadedFromDisk ? _cachedToken : null;

  Future<void> deleteToken() async {
    _cachedToken = null;
    _loadedFromDisk = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
