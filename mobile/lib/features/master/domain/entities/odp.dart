import 'package:equatable/equatable.dart';

class Odp extends Equatable {
  final int id;
  final int tenantId;
  final int areaId;
  final String code;
  final double? latitude;
  final double? longitude;

  const Odp({
    required this.id,
    required this.tenantId,
    required this.areaId,
    required this.code,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [id, tenantId, areaId, code, latitude, longitude];
}
