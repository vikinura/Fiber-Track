import 'package:equatable/equatable.dart';

class Priority extends Equatable {
  final int id;
  final int tenantId;
  final String name;
  final int slaHours;

  const Priority({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.slaHours,
  });

  @override
  List<Object?> get props => [id, tenantId, name, slaHours];
}
