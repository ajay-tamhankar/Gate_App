import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'token_store.dart';

class TokenStoreMobile implements TokenStore {
  final FlutterSecureStorage _storage;

  const TokenStoreMobile(this._storage);

  static const _refreshKey = 'refresh_token';

  @override
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshKey, value: token);
  }

  @override
  Future<String?> readRefreshToken() async {
    return await _storage.read(key: _refreshKey);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _refreshKey);
  }
}
