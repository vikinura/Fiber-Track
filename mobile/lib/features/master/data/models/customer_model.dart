import '../../domain/entities/customer.dart';

class CustomerModel extends Customer {
  const CustomerModel({
    required super.id,
    required super.tenantId,
    super.areaId,
    super.odpId,
    required super.name,
    super.address,
    super.phone,
    super.areaName,
    super.odpCode,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      tenantId: json['tenant_id'] is int
          ? json['tenant_id'] as int
          : int.parse(json['tenant_id'].toString()),
      areaId: json['area_id'] != null
          ? (json['area_id'] is int
                ? json['area_id'] as int
                : int.tryParse(json['area_id'].toString()))
          : null,
      odpId: json['odp_id'] != null
          ? (json['odp_id'] is int
                ? json['odp_id'] as int
                : int.tryParse(json['odp_id'].toString()))
          : null,
      name: json['name'] as String? ?? '',
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      areaName: json['area_name'] as String?,
      odpCode: json['odp_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'area_id': areaId,
      'odp_id': odpId,
      'name': name,
      'address': address,
      'phone': phone,
      'area_name': areaName,
      'odp_code': odpCode,
    };
  }

  Customer toEntity() {
    return Customer(
      id: id,
      tenantId: tenantId,
      areaId: areaId,
      odpId: odpId,
      name: name,
      address: address,
      phone: phone,
      areaName: areaName,
      odpCode: odpCode,
    );
  }
}
