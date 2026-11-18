import 'package:equatable/equatable.dart';

import '../../domain/entities/dashboard_data.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final DashboardSummary summary;
  final List<DashboardArea> areas;
  final List<DashboardVendor> vendors;

  const DashboardLoaded({
    required this.summary,
    required this.areas,
    required this.vendors,
  });

  @override
  List<Object?> get props => [summary, areas, vendors];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
