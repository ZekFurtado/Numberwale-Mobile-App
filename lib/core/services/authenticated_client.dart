import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// An HTTP client that automatically persists and sends auth cookies.
///
/// On every response it captures any `Set-Cookie` headers and stores the
/// `name=value` pairs in SharedPreferences. On every request it reads those
/// stored pairs back and injects them as the `Cookie:` header, so the server
/// always sees the session cookies even across app restarts.
class AuthenticatedClient extends http.BaseClient {
  final http.Client _inner;
  final SharedPreferences _prefs;

  static const _cookiesKey = 'auth_cookies';

  AuthenticatedClient(this._inner, this._prefs);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final stored = _prefs.getString(_cookiesKey);
    if (stored != null && stored.isNotEmpty) {
      request.headers['cookie'] = stored;
    }

    final response = await _inner.send(request);

    final setCookie = response.headers['set-cookie'];
    if (setCookie != null && setCookie.isNotEmpty) {
      final parsed = _extractCookies(setCookie);
      if (parsed.isNotEmpty) {
        await _prefs.setString(_cookiesKey, parsed);
      }
    }

    return response;
  }

  /// Clears all stored cookies (call on sign-out).
  Future<void> clearCookies() => _prefs.remove(_cookiesKey);

  /// Parses the combined `Set-Cookie` header string (Dart's http package joins
  /// multiple Set-Cookie headers with `, `) into a `Cookie:` header value.
  ///
  /// For example:
  ///   `accessToken=abc; Path=/; HttpOnly, refreshToken=xyz; Path=/; HttpOnly`
  /// becomes:
  ///   `accessToken=abc; refreshToken=xyz`
  static String _extractCookies(String setCookieHeader) {
    // Split on comma that is immediately followed by a non-space (next cookie
    // name starts without a leading space), then take only the name=value part
    // of each directive (before the first `;`).
    return setCookieHeader
        .split(RegExp(r',(?=\S)'))
        .map((c) => c.split(';').first.trim())
        .where((c) => c.contains('='))
        .join('; ');
  }
}
