import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardEvent extends DashboardEvent {
  final bool isRefresh;

  const LoadDashboardEvent({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}
