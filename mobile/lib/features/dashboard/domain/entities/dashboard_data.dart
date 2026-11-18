import 'package:equatable/equatable.dart';

class DashboardSummary extends Equatable {
  final int totalTickets;
  final Map<String, int> byStatus;
  final int overdueCount;
  final double avgResolutionHours;
  final double slaCompliancePercentage;

  const DashboardSummary({
    required this.totalTickets,
    required this.byStatus,
    required this.overdueCount,
    required this.avgResolutionHours,
    required this.slaCompliancePercentage,
  });

  @override
  List<Object?> get props => [
    totalTickets,
    byStatus,
    overdueCount,
    avgResolutionHours,
    slaCompliancePercentage,
  ];
}

class DashboardArea extends Equatable {
  final int areaId;
  final String areaName;
  final int totalTickets;
  final int resolvedTickets;
  final int activeTickets;

  const DashboardArea({
    required this.areaId,
    required this.areaName,
    required this.totalTickets,
    required this.resolvedTickets,
    required this.activeTickets,
  });

  @override
  List<Object?> get props => [
    areaId,
    areaName,
    totalTickets,
    resolvedTickets,
    activeTickets,
  ];
}

class DashboardVendor extends Equatable {
  final int vendorId;
  final String vendorName;
  final int totalTickets;
  final int resolvedTickets;
  final double avgResolutionHours;
  final double slaCompliancePercentage;

  const DashboardVendor({
    required this.vendorId,
    required this.vendorName,
    required this.totalTickets,
    required this.resolvedTickets,
    required this.avgResolutionHours,
    required this.slaCompliancePercentage,
  });

  @override
  List<Object?> get props => [
    vendorId,
    vendorName,
    totalTickets,
    resolvedTickets,
    avgResolutionHours,
    slaCompliancePercentage,
  ];
}
