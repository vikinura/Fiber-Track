import 'package:equatable/equatable.dart';

class Area extends Equatable {
  final int id;
  final int tenantId;
  final String name;
  final String? description;

  const Area({
    required this.id,
    required this.tenantId,
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [id, tenantId, name, description];
}
