import '../../domain/entities/odp.dart';

class OdpModel extends Odp {
  const OdpModel({
    required super.id,
    required super.tenantId,
    required super.areaId,
    required super.code,
    super.latitude,
    super.longitude,
  });

  factory OdpModel.fromJson(Map<String, dynamic> json) {
    return OdpModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      tenantId: json['tenant_id'] is int
          ? json['tenant_id'] as int
          : int.parse(json['tenant_id'].toString()),
      areaId: json['area_id'] is int
          ? json['area_id'] as int
          : int.parse(json['area_id'].toString()),
      code: json['code'] as String? ?? '',
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'area_id': areaId,
      'code': code,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  Odp toEntity() {
    return Odp(
      id: id,
      tenantId: tenantId,
      areaId: areaId,
      code: code,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
