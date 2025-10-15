// lib/Utils/Constants.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// A simple model class to represent a REST API endpoint,
/// containing its URL and HTTP method.
class RestApi {
  final String url;   // must start with '/' and be relative to baseUrl
  final String method;
  const RestApi({
    required this.url,
    required this.method,
  });
}

/// A centralized class for application-wide constants.
class ApiConstants {
  // --- Base URL ---

  static const String baseUrl = 'http://10.135.83.132:3000';

  // --- HTTP Methods ---
  static const String post = 'POST';
  static const String get = 'GET';
  static const String put = 'PUT';
  static const String patch = 'PATCH';
  static const String delete = 'DELETE';

  // Request timeout
  static const Duration httpTimeout = Duration(seconds: 20);

  // Toggle request logging
  static const bool debugNetwork = true;
}

/// Contains all API endpoint definitions.
class ApiEndpoints {
  // ---------- Auth ----------
  static const RestApi login        = RestApi(url: '/api/auth/login',   method: ApiConstants.post);
  static const RestApi register     = RestApi(url: '/api/auth/register',method: ApiConstants.post);
  static const RestApi refresh      = RestApi(url: '/api/auth/refresh', method: ApiConstants.post);
  static const RestApi logout       = RestApi(url: '/api/auth/logout',  method: ApiConstants.post);
  static const RestApi verify       = RestApi(url: '/api/auth/verify',  method: ApiConstants.get);
  static const RestApi me           = RestApi(url: '/api/auth/me',      method: ApiConstants.get);

  // ---------- Shipments (placeholders; wire as you implement) ----------
  static const RestApi shipments    = RestApi(url: '/api/shipments',    method: ApiConstants.get);
  static RestApi shipmentById(String id) =>
      RestApi(url: '/api/shipments/$id', method: ApiConstants.get);
  static const RestApi createShipment =
  RestApi(url: '/api/shipments', method: ApiConstants.post);
  static RestApi updateShipment(String id) =>
      RestApi(url: '/api/shipments/$id', method: ApiConstants.patch);
  static RestApi deleteShipment(String id) =>
      RestApi(url: '/api/shipments/$id', method: ApiConstants.delete);

  // ---------- Assignments (placeholders) ----------
  static const RestApi assignments  = RestApi(url: '/api/assignments',  method: ApiConstants.get);
  static RestApi assignmentById(String id) =>
      RestApi(url: '/api/assignments/$id', method: ApiConstants.get);
}

/// Normalized API error (what we throw from ApiClient on failure).
class ApiException implements IOException {
  final int? statusCode;
  final String message;
  final dynamic data; // optional decoded server payload

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException(${statusCode ?? '-'}) $message';
}

/// Maps backend error codes to user-friendly messages (extend as you need).
class ApiErrors {
  static final Map<int, String> codeToMessage = {
    1001: 'Account already exists.',
    1002: 'No account found for this email.',
    1003: 'Incorrect password.',
    1004: 'Session expired. Please log in again.',
    1005: 'This account is suspended.',
    5000: 'Server error. Please try again later.',
  };

  static String fromCode(int? code, {String? fallback}) {
    if (code == null) return fallback ?? 'Unexpected error.';
    return codeToMessage[code] ?? (fallback ?? 'Unexpected error.');
  }
}

/// Small, opinionated HTTP client wrapping `http` with:
/// - baseUrl handling
/// - auth header support
/// - JSON encode/decode
/// - normalized error handling
class ApiClient {
  static Uri _buildUri(RestApi endpoint, {Map<String, dynamic>? query}) {
    final base = ApiConstants.baseUrl;
    final u = endpoint.url.startsWith('/') ? endpoint.url : '/${endpoint.url}';
    final uri = Uri.parse('$base$u');

    if (query == null || query.isEmpty) return uri;

    // convert dynamic query values to string
    final q = <String, String>{};
    query.forEach((k, v) => q[k] = v?.toString() ?? '');
    return uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...q,
    });
  }

  static Map<String, String> _headers({String? token, Map<String, String>? extra}) {
    final h = <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      h[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
    if (extra != null) h.addAll(extra);
    return h;
  }

  /// Call an endpoint returning decoded JSON (Map/List/null).
  /// Throws [ApiException] on any error.
  static Future<dynamic> request(
      RestApi endpoint, {
        Map<String, dynamic>? body,
        Map<String, dynamic>? query,
        String? token,
        Map<String, String>? extraHeaders,
      }) async {
    final uri = _buildUri(endpoint, query: query);
    final headers = _headers(token: token, extra: extraHeaders);

    if (ApiConstants.debugNetwork) {
      debugPrint('[HTTP] ${endpoint.method} $uri');
      if (body != null) debugPrint('[HTTP] body: ${jsonEncode(body)}');
    }

    http.Response resp;
    try {
      switch (endpoint.method.toUpperCase()) {
        case 'GET':
          resp = await http.get(uri, headers: headers).timeout(ApiConstants.httpTimeout);
          break;
        case 'POST':
          resp = await http
              .post(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
              .timeout(ApiConstants.httpTimeout);
          break;
        case 'PUT':
          resp = await http
              .put(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
              .timeout(ApiConstants.httpTimeout);
          break;
        case 'PATCH':
          resp = await http
              .patch(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
              .timeout(ApiConstants.httpTimeout);
          break;
        case 'DELETE':
          resp = await http
              .delete(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
              .timeout(ApiConstants.httpTimeout);
          break;
        default:
          throw ApiException('Unsupported HTTP method: ${endpoint.method}');
      }
    } on SocketException {
      throw ApiException('Network unavailable. Check your connection.');
    } on TimeoutException {
      throw ApiException('Request timed out.');
    } on HandshakeException {
      throw ApiException('SSL handshake failed. Check your network or server SSL.');
    } on HttpException catch (e) {
      throw ApiException('HTTP error: ${e.message}');
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }

    final status = resp.statusCode;
    final raw = resp.body;

    dynamic json;
    try {
      json = raw.isNotEmpty ? jsonDecode(raw) : null;
    } catch (_) {
      json = raw; // non-JSON
    }

    if (status >= 200 && status < 300) {
      if (ApiConstants.debugNetwork) debugPrint('[HTTP] <- $status OK');
      return json;
    }

    // Try to extract helpful server message
    String message = 'Request failed ($status)';
    int? code;
    if (json is Map) {
      if (json['message'] is String && (json['message'] as String).isNotEmpty) {
        message = json['message'];
      }
      if (json['code'] is int) code = json['code'] as int;
    } else if (json is String && json.trim().isNotEmpty) {
      message = json.trim();
    }

    // Prefer backend-provided message; else map known codes; else generic.
    final friendly = ApiErrors.fromCode(code, fallback: message);

    switch (status) {
      case 400:
      case 401:
      case 403:
      case 404:
      case 409:
      case 422:
        throw ApiException(friendly, statusCode: status, data: json);
      default:
        throw ApiException(friendly, statusCode: status, data: json);
    }
  }
}
