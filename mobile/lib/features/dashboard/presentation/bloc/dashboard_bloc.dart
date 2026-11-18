import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/dashboard_usecases.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardSummary getDashboardSummary;
  final GetDashboardByArea getDashboardByArea;
  final GetDashboardByVendor getDashboardByVendor;

  DashboardBloc({
    required this.getDashboardSummary,
    required this.getDashboardByArea,
    required this.getDashboardByVendor,
  }) : super(const DashboardInitial()) {
    on<LoadDashboardEvent>(_onLoadDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(const DashboardLoading());
    }

    final summaryResult = await getDashboardSummary();
    final areaResult = await getDashboardByArea();
    final vendorResult = await getDashboardByVendor();

    summaryResult.fold((failure) => emit(DashboardError(failure.message)), (
      summary,
    ) {
      final areas = areaResult.getOrElse((_) => []);
      final vendors = vendorResult.getOrElse((_) => []);
      emit(DashboardLoaded(summary: summary, areas: areas, vendors: vendors));
    });
  }
}
