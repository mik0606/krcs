// lib/Models/Merchant.dart
import 'User.dart';

class Merchant extends User {
  final String shopName;
  final String gstNumber;
  final String address;
  final bool verified;
  final Map<String, dynamic> metadata;

  Merchant({
    required String id,
    required String name,
    required String email,
    String phone = '',
    String avatarUrl = '',
    Role role = Role.merchant,
    bool isActive = true,
    this.shopName = '',
    this.gstNumber = '',
    this.address = '',
    this.verified = false,
    this.metadata = const {},
  }) : super(
    id: id,
    name: name,
    email: email,
    phone: phone,
    avatarUrl: avatarUrl,
    role: role,
    isActive: isActive,
  );

  factory Merchant.fromJson(Map<String, dynamic> json) {
    final base = User.fromJson(json);
    return Merchant(
      id: base.id,
      name: base.name,
      email: base.email,
      phone: base.phone,
      avatarUrl: base.avatarUrl,
      role: Role.merchant,
      isActive: base.isActive,
      shopName: json['shopName'] ?? json['businessName'] ?? '',
      gstNumber: json['gstNumber'] ?? json['gst'] ?? '',
      address: json['address'] ?? '',
      verified: (json['verified'] == null) ? false : (json['verified'] == true),
      metadata: json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata']) : {},
    );
  }

  Map<String, dynamic> toJson() {
    final base = super.toJson();
    base.addAll({
      'shopName': shopName,
      'gstNumber': gstNumber,
      'address': address,
      'verified': verified,
      'metadata': metadata,
    });
    return base;
  }

  /// Role-specific copyWith
  Merchant copyWithMerchant({
    // shared fields
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    bool? isActive,

    // merchant-specific
    String? shopName,
    String? gstNumber,
    String? address,
    bool? verified,
    Map<String, dynamic>? metadata,
  }) {
    return Merchant(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: Role.merchant,
      isActive: isActive ?? this.isActive,
      shopName: shopName ?? this.shopName,
      gstNumber: gstNumber ?? this.gstNumber,
      address: address ?? this.address,
      verified: verified ?? this.verified,
      metadata: metadata ?? this.metadata,
    );
  }
}
