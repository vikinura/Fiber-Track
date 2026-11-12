import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final int id;
  final int tenantId;
  final int? areaId;
  final int? odpId;
  final String name;
  final String? address;
  final String? phone;
  final String? areaName;
  final String? odpCode;

  const Customer({
    required this.id,
    required this.tenantId,
    this.areaId,
    this.odpId,
    required this.name,
    this.address,
    this.phone,
    this.areaName,
    this.odpCode,
  });

  @override
  List<Object?> get props => [
    id,
    tenantId,
    areaId,
    odpId,
    name,
    address,
    phone,
    areaName,
    odpCode,
  ];
}
