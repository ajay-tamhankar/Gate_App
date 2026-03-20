import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

class TokenStorage {
  static const _tokenKey = 'auth_token';

  Future<void> saveToken(String token) async {
    debugPrint('TokenStorage: saving token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    debugPrint('TokenStorage: reading token');
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> deleteToken() async {
    debugPrint('TokenStorage: deleting token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
