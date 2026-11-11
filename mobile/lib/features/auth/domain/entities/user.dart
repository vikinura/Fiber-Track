import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String role;
  final int? tenantId;
  final int? vendorId;
  final String? phone;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.tenantId,
    this.vendorId,
    this.phone,
  });

  @override
  List<Object?> get props => [id, name, email, role, tenantId, vendorId, phone];
}
