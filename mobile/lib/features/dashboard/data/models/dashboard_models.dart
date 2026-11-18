import '../../domain/entities/dashboard_data.dart';

class DashboardSummaryModel extends DashboardSummary {
  const DashboardSummaryModel({
    required super.totalTickets,
    required super.byStatus,
    required super.overdueCount,
    required super.avgResolutionHours,
    required super.slaCompliancePercentage,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    final statusMapRaw = json['by_status'] as Map<String, dynamic>? ?? {};
    final byStatus = statusMapRaw.map(
      (k, v) => MapEntry(k, v is num ? v.toInt() : 0),
    );

    return DashboardSummaryModel(
      totalTickets: json['total_tickets'] as int? ?? 0,
      byStatus: byStatus,
      overdueCount: json['overdue_count'] as int? ?? 0,
      avgResolutionHours:
          (json['avg_resolution_hours'] as num?)?.toDouble() ?? 0.0,
      slaCompliancePercentage:
          (json['sla_compliance_percentage'] as num?)?.toDouble() ?? 100.0,
    );
  }
}

class DashboardAreaModel extends DashboardArea {
  const DashboardAreaModel({
    required super.areaId,
    required super.areaName,
    required super.totalTickets,
    required super.resolvedTickets,
    required super.activeTickets,
  });

  factory DashboardAreaModel.fromJson(Map<String, dynamic> json) {
    return DashboardAreaModel(
      areaId: json['area_id'] as int? ?? 0,
      areaName: json['area_name'] as String? ?? '-',
      totalTickets: json['total_tickets'] as int? ?? 0,
      resolvedTickets: json['resolved_tickets'] as int? ?? 0,
      activeTickets: json['active_tickets'] as int? ?? 0,
    );
  }
}

class DashboardVendorModel extends DashboardVendor {
  const DashboardVendorModel({
    required super.vendorId,
    required super.vendorName,
    required super.totalTickets,
    required super.resolvedTickets,
    required super.avgResolutionHours,
    required super.slaCompliancePercentage,
  });

  factory DashboardVendorModel.fromJson(Map<String, dynamic> json) {
    return DashboardVendorModel(
      vendorId: json['vendor_id'] as int? ?? 0,
      vendorName: json['vendor_name'] as String? ?? '-',
      totalTickets: json['total_tickets'] as int? ?? 0,
      resolvedTickets: json['resolved_tickets'] as int? ?? 0,
      avgResolutionHours:
          (json['avg_resolution_hours'] as num?)?.toDouble() ?? 0.0,
      slaCompliancePercentage:
          (json['sla_compliance_percentage'] as num?)?.toDouble() ?? 100.0,
    );
  }
}
