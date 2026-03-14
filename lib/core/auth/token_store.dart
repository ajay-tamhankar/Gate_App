abstract class TokenStore {
  Future<void> saveRefreshToken(String token);
  Future<String?> readRefreshToken();
  Future<void> clear();
}
