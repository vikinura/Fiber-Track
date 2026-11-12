import '../../domain/entities/area.dart';

class AreaModel extends Area {
  const AreaModel({
    required super.id,
    required super.tenantId,
    required super.name,
    super.description,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      tenantId: json['tenant_id'] is int
          ? json['tenant_id'] as int
          : int.parse(json['tenant_id'].toString()),
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'name': name,
      'description': description,
    };
  }

  Area toEntity() {
    return Area(
      id: id,
      tenantId: tenantId,
      name: name,
      description: description,
    );
  }
}
