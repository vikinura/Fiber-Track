import '../../domain/entities/priority.dart';

class PriorityModel extends Priority {
  const PriorityModel({
    required super.id,
    required super.tenantId,
    required super.name,
    required super.slaHours,
  });

  factory PriorityModel.fromJson(Map<String, dynamic> json) {
    return PriorityModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      tenantId: json['tenant_id'] is int
          ? json['tenant_id'] as int
          : int.parse(json['tenant_id'].toString()),
      name: json['name'] as String? ?? '',
      slaHours: json['sla_hours'] is int
          ? json['sla_hours'] as int
          : int.parse(json['sla_hours'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'name': name,
      'sla_hours': slaHours,
    };
  }

  Priority toEntity() {
    return Priority(id: id, tenantId: tenantId, name: name, slaHours: slaHours);
  }
}
