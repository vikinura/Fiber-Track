import 'package:equatable/equatable.dart';

import 'ticket_status.dart';
import 'sla_status.dart';
import 'ticket_photo.dart';

class Ticket extends Equatable {
  final int id;
  final int? tenantId;
  final String ticketNo;
  final TicketStatus status;
  final String description;
  final double? latitude;
  final double? longitude;
  final DateTime slaDueAt;
  final DateTime? resolvedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Relasi
  final int customerId;
  final String? customerName;
  final String? customerAddress;
  final String? customerPhone;

  final int areaId;
  final String? areaName;

  final int? odpId;
  final String? odpCode;

  final int issueTypeId;
  final String? issueTypeName;

  final int priorityId;
  final String? priorityName;
  final int? slaHours;

  final int? vendorId;
  final String? vendorName;

  final int? technicianId;
  final String? technicianName;

  final int? createdBy;
  final String? creatorName;

  final SlaStatus slaStatus;
  final int slaRemainingSeconds;
  final List<TicketPhoto> photos;

  const Ticket({
    required this.id,
    this.tenantId,
    required this.ticketNo,
    required this.status,
    required this.description,
    this.latitude,
    this.longitude,
    required this.slaDueAt,
    this.resolvedAt,
    required this.createdAt,
    this.updatedAt,
    required this.customerId,
    this.customerName,
    this.customerAddress,
    this.customerPhone,
    required this.areaId,
    this.areaName,
    this.odpId,
    this.odpCode,
    required this.issueTypeId,
    this.issueTypeName,
    required this.priorityId,
    this.priorityName,
    this.slaHours,
    this.vendorId,
    this.vendorName,
    this.technicianId,
    this.technicianName,
    this.createdBy,
    this.creatorName,
    this.slaStatus = SlaStatus.onTrack,
    this.slaRemainingSeconds = 0,
    this.photos = const [],
  });

  @override
  List<Object?> get props => [
    id,
    tenantId,
    ticketNo,
    status,
    description,
    latitude,
    longitude,
    slaDueAt,
    resolvedAt,
    createdAt,
    updatedAt,
    customerId,
    customerName,
    customerAddress,
    customerPhone,
    areaId,
    areaName,
    odpId,
    odpCode,
    issueTypeId,
    issueTypeName,
    priorityId,
    priorityName,
    slaHours,
    vendorId,
    vendorName,
    technicianId,
    technicianName,
    createdBy,
    creatorName,
    slaStatus,
    slaRemainingSeconds,
    photos,
  ];
}
