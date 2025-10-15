// lib/Services/AuthServices.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../Utils/Constants.dart';

class AuthResult {
  final dynamic user;   // your role model or Map<String, dynamic>
  final String token;   // access token

  AuthResult({required this.user, required this.token});
}

/// AuthService: Orchestrates the entire authentication flow.
class AuthService {
  // 🔑 Singleton
  AuthService._private();
  static final AuthService instance = AuthService._private();

  // -------------------- Token helpers & keys --------------------
  static const String _tokenKey = 'x-auth-token';        // access token
  static const String _refreshKey = 'x-refresh-token';    // refresh token
  static const String _userCacheKey = 'x-user-json';      // cached user json

  String? _tokenCache;
  String? _refreshCache;
  Map<String, dynamic>? _userCache;

  Future<String?> _getToken() async {
    if (_tokenCache != null) return _tokenCache;
    final prefs = await SharedPreferences.getInstance();
    _tokenCache = prefs.getString(_tokenKey);
    return _tokenCache;
  }

  Future<String?> _getRefreshToken() async {
    if (_refreshCache != null) return _refreshCache;
    final prefs = await SharedPreferences.getInstance();
    _refreshCache = prefs.getString(_refreshKey);
    return _refreshCache;
  }

  Future<void> _saveTokenPair(String accessToken, {String? refreshToken}) async {
    final prefs = await SharedPreferences.getInstance();
    _tokenCache = accessToken;
    await prefs.setString(_tokenKey, accessToken);

    if (refreshToken != null && refreshToken.isNotEmpty) {
      _refreshCache = refreshToken;
      await prefs.setString(_refreshKey, refreshToken);
    }
  }

  Future<void> _cacheUser(Map<String, dynamic>? user) async {
    final prefs = await SharedPreferences.getInstance();
    _userCache = user;
    if (user == null) {
      await prefs.remove(_userCacheKey);
    } else {
      await prefs.setString(_userCacheKey, jsonEncode(user));
    }
  }

  Future<Map<String, dynamic>?> _loadCachedUser() async {
    if (_userCache != null) return _userCache;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userCacheKey);
    if (raw == null) return null;
    try {
      _userCache = (jsonDecode(raw) as Map).cast<String, dynamic>();
      return _userCache;
    } catch (_) {
      return null;
    }
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshKey);
    await prefs.remove(_userCacheKey);
    _tokenCache = null;
    _refreshCache = null;
    _userCache = null;
  }

  Future<T> _withAuth<T>(Future<T> Function(String token) fn) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) throw ApiException('Not logged in');
    return await fn(token);
  }

  // -------------------- Public accessors --------------------
  Map<String, dynamic>? get currentUser => _userCache;
  String? get currentRole => _userCache?['role'] as String?;

  // -------------------- Core auth flows --------------------

  /// Login -> saves tokens + user, returns AuthResult.
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    final res = await ApiClient.request(
      ApiEndpoints.login,
      body: {'email': email, 'password': password},
    ) as Map<String, dynamic>;

    // Our backend shape: { ok, message, user, tokens:{ accessToken, refreshToken } }
    final tokens = (res['tokens'] as Map?)?.cast<String, dynamic>();
    final userMap = (res['user'] as Map?)?.cast<String, dynamic>();

    final access = tokens?['accessToken'] as String?;
    if (access == null || access.isEmpty) {
      throw ApiException('Login response missing access token');
    }

    await _saveTokenPair(access, refreshToken: tokens?['refreshToken'] as String?);
    await _cacheUser(userMap);

    final parsed = _parseUserRole(userMap);
    return AuthResult(user: parsed, token: access);
  }

  /// Register -> saves tokens + user, returns AuthResult.
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String role, // 'admin'|'driver'|'merchant'|'logistic'|'sanjit'
    String? phone,
  }) async {
    final res = await ApiClient.request(
      ApiEndpoints.register,
      body: {'name': name, 'email': email, 'password': password, 'role': role, if (phone != null) 'phone': phone},
    ) as Map<String, dynamic>;

    final tokens = (res['tokens'] as Map?)?.cast<String, dynamic>();
    final userMap = (res['user'] as Map?)?.cast<String, dynamic>();
    final access = tokens?['accessToken'] as String?;
    if (access == null || access.isEmpty) {
      throw ApiException('Register response missing access token');
    }

    await _saveTokenPair(access, refreshToken: tokens?['refreshToken'] as String?);
    await _cacheUser(userMap);

    final parsed = _parseUserRole(userMap);
    return AuthResult(user: parsed, token: access);
  }

  /// Validate session & fetch user via /auth/me (or use cached user if offline).
  Future<AuthResult?> getUserData() async {
    final token = await _getToken();
    if (token == null) return null;

    try {
      final res = await ApiClient.request(ApiEndpoints.me, token: token) as Map<String, dynamic>;
      final userMap = (res['user'] as Map?)?.cast<String, dynamic>() ?? res.cast<String, dynamic>();
      await _cacheUser(userMap);
      return AuthResult(user: _parseUserRole(userMap), token: token);
    } on ApiException {
      // fallback to cached user if available
      final cached = await _loadCachedUser();
      if (cached != null) return AuthResult(user: _parseUserRole(cached), token: token);
      return null;
    }
  }

  /// Logout (server best-effort), then clear local session.
  Future<void> signOut() async {
    final r = await _getRefreshToken();
    if (r != null && r.isNotEmpty) {
      try {
        await ApiClient.request(ApiEndpoints.logout, body: {'refreshToken': r});
      } catch (_) {
        // ignore server errors on logout
      }
    }
    await _clearSession();
  }

  /// Refresh access token using stored refresh token and update storage.
  Future<String> refresh() async {
    final r = await _getRefreshToken();
    if (r == null || r.isEmpty) throw ApiException('Missing refresh token');

    final res = await ApiClient.request(
      ApiEndpoints.refresh,
      body: {'refreshToken': r},
    ) as Map<String, dynamic>;

    final tokens = (res['tokens'] as Map?)?.cast<String, dynamic>();
    final newAccess = tokens?['accessToken'] as String?;
    final newRefresh = tokens?['refreshToken'] as String?;

    if (newAccess == null || newAccess.isEmpty) {
      throw ApiException('Refresh did not return access token');
    }
    await _saveTokenPair(newAccess, refreshToken: newRefresh ?? r);
    return newAccess;
  }

  // -------------------- Auto-refresh wrapper for API calls --------------------

  /// Wrap any API call that needs auth. If it 401s once, try refresh then retry.
  Future<T> withAutoRefresh<T>(Future<T> Function(String token) call) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) throw ApiException('Not logged in');

    try {
      return await call(token);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        // try refresh once
        final newToken = await refresh();
        return await call(newToken);
      }
      rethrow;
    }
  }

  // -------------------- Convenience authorized calls --------------------

  Future<dynamic> get(RestApi ep, {Map<String, dynamic>? query}) {
    return withAutoRefresh((t) => ApiClient.request(ep, token: t, query: query));
  }

  Future<dynamic> post(RestApi ep, {Map<String, dynamic>? body}) {
    return withAutoRefresh((t) => ApiClient.request(ep, token: t, body: body));
  }

  Future<dynamic> patch(RestApi ep, {Map<String, dynamic>? body}) {
    return withAutoRefresh((t) => ApiClient.request(ep, token: t, body: body));
  }

  Future<dynamic> del(RestApi ep, {Map<String, dynamic>? body}) {
    return withAutoRefresh((t) => ApiClient.request(ep, token: t, body: body));
  }

  // -------------------- Role-aware parsing hook --------------------
  /// Convert backend `user` map into your app models.
  /// Replace with real constructors from your Models/*.dart if needed.
  dynamic _parseUserRole(Map<String, dynamic>? user) {
    if (user == null) return null;
    final role = user['role'] as String?;
    return user; // default: return raw map
  }
}
