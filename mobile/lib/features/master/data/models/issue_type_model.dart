import '../../domain/entities/issue_type.dart';

class IssueTypeModel extends IssueType {
  const IssueTypeModel({
    required super.id,
    required super.tenantId,
    required super.name,
  });

  factory IssueTypeModel.fromJson(Map<String, dynamic> json) {
    return IssueTypeModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      tenantId: json['tenant_id'] is int
          ? json['tenant_id'] as int
          : int.parse(json['tenant_id'].toString()),
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'tenant_id': tenantId, 'name': name};
  }

  IssueType toEntity() {
    return IssueType(id: id, tenantId: tenantId, name: name);
  }
}
