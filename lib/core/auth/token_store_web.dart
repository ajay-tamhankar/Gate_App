import 'token_store.dart';
import 'package:universal_html/html.dart' as html;

class TokenStoreWeb implements TokenStore {
  static const _refreshKey = 'gate_reco_refresh_token';

  @override
  Future<void> saveRefreshToken(String token) async {
    // Note: If backend provides HttpOnly cookies, this could be a no-op
    // instead of local storage. Storing here for mock setup.
    html.window.localStorage[_refreshKey] = token;
  }

  @override
  Future<String?> readRefreshToken() async {
    return html.window.localStorage[_refreshKey];
  }

  @override
  Future<void> clear() async {
    html.window.localStorage.remove(_refreshKey);
  }
}
