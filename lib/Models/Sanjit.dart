// lib/Models/Sanjit.dart
import 'User.dart';

class Sanjit extends User {
  final String department;
  final String badgeId;
  final Map<String, dynamic> extras;

  Sanjit({
    required String id,
    required String name,
    required String email,
    String phone = '',
    String avatarUrl = '',
    Role role = Role.sanjit,
    bool isActive = true,
    this.department = '',
    this.badgeId = '',
    this.extras = const {},
  }) : super(
    id: id,
    name: name,
    email: email,
    phone: phone,
    avatarUrl: avatarUrl,
    role: role,
    isActive: isActive,
  );

  factory Sanjit.fromJson(Map<String, dynamic> json) {
    final base = User.fromJson(json);
    return Sanjit(
      id: base.id,
      name: base.name,
      email: base.email,
      phone: base.phone,
      avatarUrl: base.avatarUrl,
      role: Role.sanjit,
      isActive: base.isActive,
      department: json['department'] ?? '',
      badgeId: json['badgeId'] ?? json['badges']?['id'] ?? '',
      extras: json['extras'] is Map ? Map<String, dynamic>.from(json['extras']) : {},
    );
  }

  Map<String, dynamic> toJson() {
    final base = super.toJson();
    base.addAll({
      'department': department,
      'badgeId': badgeId,
      'extras': extras,
    });
    return base;
  }

  /// Role-specific copyWith
  Sanjit copyWithSanjit({
    // shared fields
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    bool? isActive,

    // sanjit-specific
    String? department,
    String? badgeId,
    Map<String, dynamic>? extras,
  }) {
    return Sanjit(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: Role.sanjit,
      isActive: isActive ?? this.isActive,
      department: department ?? this.department,
      badgeId: badgeId ?? this.badgeId,
      extras: extras ?? this.extras,
    );
  }
}
