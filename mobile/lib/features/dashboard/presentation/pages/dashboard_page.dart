import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/area_bar_chart_section.dart';
import '../widgets/summary_cards_section.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<DashboardBloc>()..add(const LoadDashboardEvent()),
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.dashboardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan',
            onPressed: () {
              context.read<DashboardBloc>().add(
                const LoadDashboardEvent(isRefresh: true),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const LoadingView(message: AppStrings.loading);
          }

          if (state is DashboardError) {
            return ErrorView(
              message: state.message,
              onRetry: () {
                context.read<DashboardBloc>().add(const LoadDashboardEvent());
              },
            );
          }

          if (state is DashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(
                  const LoadDashboardEvent(isRefresh: true),
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SummaryCardsSection(summary: state.summary),
                    const SizedBox(height: AppSizes.p24),
                    AreaBarChartSection(areas: state.areas),
                    const SizedBox(height: AppSizes.p24),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
