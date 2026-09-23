import 'dart:async';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/backend_config.dart';

/// An HTTP client that automatically persists and sends auth cookies.
///
/// On every response it captures any `Set-Cookie` headers and **merges** the
/// `name=value` pairs into the stored jar (a response that only refreshes
/// `accessToken` must not wipe the `refreshToken` that came with login). On
/// every request it reads those stored pairs back and injects them as the
/// `Cookie:` header, so the server always sees the session cookies even
/// across app restarts.
///
/// When the server answers 401 the client transparently calls
/// `POST /auth/refresh-token` once (single-flight — concurrent 401s wait on
/// the same attempt) and replays the original request with the refreshed
/// cookies. [onUnauthorized] is only invoked when that refresh itself fails,
/// i.e. when the session is genuinely gone.
class AuthenticatedClient extends http.BaseClient {
  final http.Client _inner;
  final SharedPreferences _prefs;

  static const _cookiesKey = 'auth_cookies';

  /// Called at most once every 3 seconds when the session cannot be refreshed.
  void Function()? onUnauthorized;
  DateTime? _lastUnauthorizedAt;

  /// In-flight refresh, shared by every request that hits a 401 at once.
  Future<bool>? _refreshInFlight;

  AuthenticatedClient(this._inner, this._prefs);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Buffer the body up front so the request can be replayed after a
    // refresh — a BaseRequest's stream can only be read once.
    final body = await request.finalize().toBytes();

    var response = await _send(request, body);

    if (response.statusCode != 401 || _isAuthEndpoint(request.url)) {
      return response;
    }

    // Session may just have expired — try to refresh once and replay.
    final refreshed = await _refreshSession();
    if (refreshed) {
      response = await _send(request, body);
      if (response.statusCode != 401) return response;
    }

    _notifyUnauthorized();
    return response;
  }

  Future<http.StreamedResponse> _send(
    http.BaseRequest original,
    List<int> body,
  ) async {
    final request = http.Request(original.method, original.url)
      ..headers.addAll(original.headers)
      ..followRedirects = original.followRedirects
      ..maxRedirects = original.maxRedirects
      ..persistentConnection = original.persistentConnection;
    // Leave bodyless requests (GET, DELETE) without a content-length.
    if (body.isNotEmpty) request.bodyBytes = body;

    final stored = _prefs.getString(_cookiesKey);
    if (stored != null && stored.isNotEmpty) {
      request.headers['cookie'] = stored;
    }

    final response = await _inner.send(request);
    await _storeCookies(response.headers['set-cookie']);
    return response;
  }

  /// Calls the refresh-token endpoint at most once at a time. Returns true
  /// when the server handed back a fresh session.
  Future<bool> _refreshSession() {
    return _refreshInFlight ??= _doRefresh().whenComplete(() {
      _refreshInFlight = null;
    });
  }

  Future<bool> _doRefresh() async {
    try {
      final request = http.Request('POST', Uri.parse(BackendConfig.refreshTokenUrl))
        ..headers.addAll(BackendConfig.headers);
      final stored = _prefs.getString(_cookiesKey);
      if (stored != null && stored.isNotEmpty) {
        request.headers['cookie'] = stored;
      }

      final response = await _inner.send(request);
      await response.stream.drain<void>();
      await _storeCookies(response.headers['set-cookie']);

      final ok = response.statusCode == 200;
      log('AuthenticatedClient: session refresh '
          '${ok ? 'succeeded' : 'failed (${response.statusCode})'}');
      return ok;
    } catch (e) {
      log('AuthenticatedClient: session refresh errored — $e');
      return false;
    }
  }

  void _notifyUnauthorized() {
    final now = DateTime.now();
    final last = _lastUnauthorizedAt;
    if (last == null || now.difference(last).inSeconds > 3) {
      _lastUnauthorizedAt = now;
      onUnauthorized?.call();
    }
  }

  /// The auth endpoints below either establish a session or are the refresh
  /// itself — a 401 from them is a real failure, never something to retry.
  bool _isAuthEndpoint(Uri url) {
    const authPaths = [
      '/auth/login',
      '/auth/sign-in',
      '/auth/register',
      '/auth/verify-otp',
      '/auth/resend-otp',
      '/auth/refresh-token',
      '/auth/forgot-password',
      '/auth/reset-password',
    ];
    return authPaths.any(url.path.contains);
  }

  Future<void> _storeCookies(String? setCookieHeader) async {
    if (setCookieHeader == null || setCookieHeader.isEmpty) return;

    final incoming = _parseSetCookie(setCookieHeader);
    if (incoming.isEmpty) return;

    final jar = _readJar();
    incoming.forEach((name, value) {
      // An empty value is the server expiring that cookie.
      if (value.isEmpty) {
        jar.remove(name);
      } else {
        jar[name] = value;
      }
    });

    if (jar.isEmpty) {
      await _prefs.remove(_cookiesKey);
    } else {
      await _prefs.setString(
        _cookiesKey,
        jar.entries.map((e) => '${e.key}=${e.value}').join('; '),
      );
    }
  }

  Map<String, String> _readJar() {
    final stored = _prefs.getString(_cookiesKey);
    final jar = <String, String>{};
    if (stored == null || stored.isEmpty) return jar;
    for (final pair in stored.split(';')) {
      final trimmed = pair.trim();
      final eq = trimmed.indexOf('=');
      if (eq <= 0) continue;
      jar[trimmed.substring(0, eq)] = trimmed.substring(eq + 1);
    }
    return jar;
  }

  /// Clears all stored cookies. Call before establishing a new session and
  /// on sign-out, so one account's cookies can never leak into another's.
  Future<void> clearCookies() => _prefs.remove(_cookiesKey);

  /// Parses the combined `Set-Cookie` header string (Dart's http package joins
  /// multiple Set-Cookie headers with `,`) into `name -> value` pairs.
  ///
  /// For example:
  ///   `accessToken=abc; Path=/; HttpOnly,refreshToken=xyz; Path=/; HttpOnly`
  /// becomes:
  ///   `{accessToken: abc, refreshToken: xyz}`
  ///
  /// The split deliberately requires a non-space after the comma so the
  /// `Expires=Wed, 18 Sep 2026 ...` attribute (comma *plus* space) doesn't
  /// look like the start of another cookie.
  static Map<String, String> _parseSetCookie(String setCookieHeader) {
    final cookies = <String, String>{};
    for (final directive in setCookieHeader.split(RegExp(r',(?=\S)'))) {
      final pair = directive.split(';').first.trim();
      final eq = pair.indexOf('=');
      if (eq <= 0) continue;
      cookies[pair.substring(0, eq)] = pair.substring(eq + 1);
    }
    return cookies;
  }
}
