// lib/Models/Driver.dart
import 'User.dart';

class Driver extends User {
  final String licenceNumber;
  final String vehicleNumber;
  final String vehicleType;
  final double rating;
  final bool isAvailable;
  final Map<String, dynamic> location;

  Driver({
    required String id,
    required String name,
    required String email,
    String phone = '',
    String avatarUrl = '',
    Role role = Role.driver,
    bool isActive = true,
    this.licenceNumber = '',
    this.vehicleNumber = '',
    this.vehicleType = '',
    this.rating = 0.0,
    this.isAvailable = true,
    this.location = const {},
  }) : super(
    id: id,
    name: name,
    email: email,
    phone: phone,
    avatarUrl: avatarUrl,
    role: role,
    isActive: isActive,
  );

  factory Driver.fromJson(Map<String, dynamic> json) {
    final base = User.fromJson(json);
    return Driver(
      id: base.id,
      name: base.name,
      email: base.email,
      phone: base.phone,
      avatarUrl: base.avatarUrl,
      role: Role.driver,
      isActive: base.isActive,
      licenceNumber: json['licenceNumber'] ?? json['licenseNo'] ?? '',
      vehicleNumber: json['vehicleNumber'] ?? json['vehicle_no'] ?? '',
      vehicleType: json['vehicleType'] ?? json['vehicle_type'] ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '') ?? 0.0,
      isAvailable: json['isAvailable'] == null ? true : (json['isAvailable'] == true),
      location: (json['location'] is Map) ? Map<String, dynamic>.from(json['location']) : {},
    );
  }

  Map<String, dynamic> toJson() {
    final base = super.toJson();
    base.addAll({
      'licenceNumber': licenceNumber,
      'vehicleNumber': vehicleNumber,
      'vehicleType': vehicleType,
      'rating': rating,
      'isAvailable': isAvailable,
      'location': location,
    });
    return base;
  }

  /// Role-specific copyWith (no override) to avoid signature conflict
  Driver copyWithDriver({
    // shared fields (optional)
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    bool? isActive,

    // driver-specific
    String? licenceNumber,
    String? vehicleNumber,
    String? vehicleType,
    double? rating,
    bool? isAvailable,
    Map<String, dynamic>? location,
  }) {
    return Driver(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: Role.driver,
      isActive: isActive ?? this.isActive,
      licenceNumber: licenceNumber ?? this.licenceNumber,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      rating: rating ?? this.rating,
      isAvailable: isAvailable ?? this.isAvailable,
      location: location ?? this.location,
    );
  }
}
