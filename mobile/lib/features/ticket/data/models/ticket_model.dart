import '../../domain/entities/sla_status.dart';
import '../../domain/entities/ticket.dart';
import '../../domain/entities/ticket_status.dart';
import 'ticket_photo_model.dart';

class TicketModel extends Ticket {
  const TicketModel({
    required super.id,
    super.tenantId,
    required super.ticketNo,
    required super.status,
    required super.description,
    super.latitude,
    super.longitude,
    required super.slaDueAt,
    super.resolvedAt,
    required super.createdAt,
    super.updatedAt,
    required super.customerId,
    super.customerName,
    super.customerAddress,
    super.customerPhone,
    required super.areaId,
    super.areaName,
    super.odpId,
    super.odpCode,
    required super.issueTypeId,
    super.issueTypeName,
    required super.priorityId,
    super.priorityName,
    super.slaHours,
    super.vendorId,
    super.vendorName,
    super.technicianId,
    super.technicianName,
    super.createdBy,
    super.creatorName,
    super.slaStatus,
    super.slaRemainingSeconds,
    super.photos,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    List<TicketPhotoModel> photosList = [];
    if (json['photos'] is List) {
      photosList = (json['photos'] as List)
          .map((p) => TicketPhotoModel.fromJson(p as Map<String, dynamic>))
          .toList();
    }

    double? parseCoord(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString());
    }

    return TicketModel(
      id: json['id'] as int,
      tenantId: json['tenant_id'] as int?,
      ticketNo: json['ticket_no'] as String,
      status: TicketStatus.fromString(json['status'] as String?),
      description: json['description'] as String? ?? '',
      latitude: parseCoord(json['latitude']),
      longitude: parseCoord(json['longitude']),
      slaDueAt: DateTime.parse(json['sla_due_at'] as String),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      customerId: json['customer_id'] as int,
      customerName: json['customer_name'] as String?,
      customerAddress: json['customer_address'] as String?,
      customerPhone: json['customer_phone'] as String?,
      areaId: json['area_id'] as int,
      areaName: json['area_name'] as String?,
      odpId: json['odp_id'] as int?,
      odpCode: json['odp_code'] as String?,
      issueTypeId: json['issue_type_id'] as int,
      issueTypeName: json['issue_type_name'] as String?,
      priorityId: json['priority_id'] as int,
      priorityName: json['priority_name'] as String?,
      slaHours: json['sla_hours'] as int?,
      vendorId: json['vendor_id'] as int?,
      vendorName: json['vendor_name'] as String?,
      technicianId: json['technician_id'] as int?,
      technicianName: json['technician_name'] as String?,
      createdBy: json['created_by'] as int?,
      creatorName: json['creator_name'] as String?,
      slaStatus: SlaStatus.fromString(json['sla_status'] as String?),
      slaRemainingSeconds: json['sla_remaining_seconds'] as int? ?? 0,
      photos: photosList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'ticket_no': ticketNo,
      'status': status.value,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'sla_due_at': slaDueAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'customer_id': customerId,
      'area_id': areaId,
      'odp_id': odpId,
      'issue_type_id': issueTypeId,
      'priority_id': priorityId,
      'vendor_id': vendorId,
      'technician_id': technicianId,
      'created_by': createdBy,
    };
  }
}
