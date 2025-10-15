// lib/Models/User.dart
import 'package:flutter/foundation.dart';

enum Role {
  admin,
  driver,
  merchant,
  logistics,
  sanjit,
  unknown,
}

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final Role role;
  final bool isActive;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.avatarUrl = '',
    this.role = Role.unknown,
    this.isActive = true,
  });

  // Parse a string into Role enum
  static Role parseRole(String? r) {
    if (r == null) return Role.unknown;
    final key = r.toLowerCase();
    switch (key) {
      case 'admin':
        return Role.admin;
      case 'driver':
        return Role.driver;
      case 'merchant':
        return Role.merchant;
      case 'logistics':
      case 'logistic':
        return Role.logistics;
      case 'sanjit':
        return Role.sanjit;
      default:
        return Role.unknown;
    }
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatarUrl: json['avatar'] ?? json['avatarUrl'] ?? '',
      role: parseRole(json['role']?.toString() ?? json['userType']?.toString()),
      isActive: json['isActive'] == null ? true : (json['isActive'] == true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatarUrl,
      'role': describeEnum(role),
      'isActive': isActive,
    };
  }

  // Base copyWith for shared fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    Role? role,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
    );
  }

  // Convenience getters
  bool get isDriver => role == Role.driver;
  bool get isMerchant => role == Role.merchant;
  bool get isLogistics => role == Role.logistics;
  bool get isSanjit => role == Role.sanjit;
  bool get isAdmin => role == Role.admin;
}
