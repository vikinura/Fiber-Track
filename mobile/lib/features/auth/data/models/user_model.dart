import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    super.tenantId,
    super.vendorId,
    super.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      tenantId: json['tenant_id'] != null
          ? (json['tenant_id'] is int
                ? json['tenant_id'] as int
                : int.tryParse(json['tenant_id'].toString()))
          : null,
      vendorId: json['vendor_id'] != null
          ? (json['vendor_id'] is int
                ? json['vendor_id'] as int
                : int.tryParse(json['vendor_id'].toString()))
          : null,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'tenant_id': tenantId,
      'vendor_id': vendorId,
      'phone': phone,
    };
  }

  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      role: role,
      tenantId: tenantId,
      vendorId: vendorId,
      phone: phone,
    );
  }
}
