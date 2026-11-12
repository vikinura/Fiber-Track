import 'package:equatable/equatable.dart';

class IssueType extends Equatable {
  final int id;
  final int tenantId;
  final String name;

  const IssueType({
    required this.id,
    required this.tenantId,
    required this.name,
  });

  @override
  List<Object?> get props => [id, tenantId, name];
}
