// lib/Models/Logistics.dart
import 'User.dart';

class Logistics extends User {
  final String companyName;
  final String vehicleFleetId;
  final int activeShipments;
  final Map<String, dynamic> companyInfo;

  Logistics({
    required String id,
    required String name,
    required String email,
    String phone = '',
    String avatarUrl = '',
    Role role = Role.logistics,
    bool isActive = true,
    this.companyName = '',
    this.vehicleFleetId = '',
    this.activeShipments = 0,
    this.companyInfo = const {},
  }) : super(
    id: id,
    name: name,
    email: email,
    phone: phone,
    avatarUrl: avatarUrl,
    role: role,
    isActive: isActive,
  );

  factory Logistics.fromJson(Map<String, dynamic> json) {
    final base = User.fromJson(json);
    return Logistics(
      id: base.id,
      name: base.name,
      email: base.email,
      phone: base.phone,
      avatarUrl: base.avatarUrl,
      role: Role.logistics,
      isActive: base.isActive,
      companyName: json['companyName'] ?? json['orgName'] ?? '',
      vehicleFleetId: json['vehicleFleetId'] ?? json['fleetId'] ?? '',
      activeShipments: int.tryParse(json['activeShipments']?.toString() ?? '') ?? 0,
      companyInfo: json['companyInfo'] is Map ? Map<String, dynamic>.from(json['companyInfo']) : {},
    );
  }

  Map<String, dynamic> toJson() {
    final base = super.toJson();
    base.addAll({
      'companyName': companyName,
      'vehicleFleetId': vehicleFleetId,
      'activeShipments': activeShipments,
      'companyInfo': companyInfo,
    });
    return base;
  }

  /// Role-specific copyWith
  Logistics copyWithLogistics({
    // shared fields
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    bool? isActive,

    // logistics-specific
    String? companyName,
    String? vehicleFleetId,
    int? activeShipments,
    Map<String, dynamic>? companyInfo,
  }) {
    return Logistics(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: Role.logistics,
      isActive: isActive ?? this.isActive,
      companyName: companyName ?? this.companyName,
      vehicleFleetId: vehicleFleetId ?? this.vehicleFleetId,
      activeShipments: activeShipments ?? this.activeShipments,
      companyInfo: companyInfo ?? this.companyInfo,
    );
  }
}
