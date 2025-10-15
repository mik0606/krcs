// lib/Providers/app_providers.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/User.dart';
import '../Models/Driver.dart';
import '../Models/Merchant.dart';
import '../Models/Logistic.dart';
import '../Models/Sanjit.dart';

/// Central app provider: handles authentication & user session only.
class AppProvider extends ChangeNotifier {
  static const _kTokenKey = 'spazigo_token';
  static const _kUserJsonKey = 'spazigo_user_json';

  dynamic _user; // can be User, Driver, Merchant, Logistics, Sanjit
  String? _token;

  // --- Getters ---
  dynamic get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _user != null && _token != null;

  bool get isDriver => _user is Driver;
  bool get isMerchant => _user is Merchant;
  bool get isLogistics => _user is Logistics;
  bool get isSanjit => _user is Sanjit;
  bool get isAdmin => _user is User && (_user.role == Role.admin);

  // --- Session methods ---

  /// Save user + token in memory and persist to SharedPreferences
  Future<void> setUser(dynamic typedUser, String token) async {
    _user = typedUser;
    _token = token;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kTokenKey, token);

      Map<String, dynamic> userJson = (typedUser as dynamic).toJson();
      await prefs.setString(_kUserJsonKey, jsonEncode(userJson));
    } catch (e) {
      debugPrint('AppProvider.setUser: persist failed $e');
    }
  }

  /// Restore session from SharedPreferences
  Future<bool> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_kTokenKey);
      final userStr = prefs.getString(_kUserJsonKey);
      if (token == null || userStr == null) return false;

      final userJson = jsonDecode(userStr) as Map<String, dynamic>;
      final typed = _parseUser(userJson);
      if (typed == null) return false;

      _token = token;
      _user = typed;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('AppProvider.restoreSession failed $e');
      return false;
    }
  }

  /// Clear session
  Future<void> signOut() async {
    _user = null;
    _token = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTokenKey);
    await prefs.remove(_kUserJsonKey);
  }

  /// Parse JSON into correct user type
  dynamic _parseUser(Map<String, dynamic> json) {
    final role = User.parseRole(json['role']?.toString());
    switch (role) {
      case Role.driver:
        return Driver.fromJson(json);
      case Role.merchant:
        return Merchant.fromJson(json);
      case Role.logistics:
        return Logistics.fromJson(json);
      case Role.sanjit:
        return Sanjit.fromJson(json);
      case Role.admin:
      case Role.unknown:
      default:
        return User.fromJson(json);
    }
  }

  /// Convenience to set user from API JSON + token
  Future<void> setUserFromApiJson(Map<String, dynamic> json, String token) async {
    final typed = _parseUser(json);
    await setUser(typed, token);
  }
}
