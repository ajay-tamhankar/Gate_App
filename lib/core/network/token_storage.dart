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
    // Always write to disk so closing/reopening the app keeps the user
    // signed in. Previously a `persist: false` call would *delete* any
    // token already on disk, silently logging the user out on next launch
    // — which is what users reported as "having to log in every time".
    //
    // The `persist` flag is retained on the signature for API compat with
    // future "session-only" flows (e.g. shared-kiosk login), but on this
    // codebase we treat every successful login as persistent. Callers that
    // truly want to end a session should call `deleteToken()` explicitly.
    await prefs.setString(_tokenKey, token);
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
