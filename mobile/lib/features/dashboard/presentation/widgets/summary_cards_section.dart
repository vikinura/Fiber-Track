import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/status_colors.dart';
import '../../domain/entities/dashboard_data.dart';
import 'summary_metric_card.dart';

class SummaryCardsSection extends StatelessWidget {
  final DashboardSummary summary;

  const SummaryCardsSection({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColors = theme.extension<StatusColors>();
    final activeCount =
        (summary.byStatus['forwarded'] ?? 0) +
        (summary.byStatus['assigned'] ?? 0) +
        (summary.byStatus['in_progress'] ?? 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grid 2x2 Kartu Metrik Utama
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSizes.p12,
          crossAxisSpacing: AppSizes.p12,
          childAspectRatio: 1.3,
          children: [
            SummaryMetricCard(
              title: AppStrings.totalTickets,
              value: '${summary.totalTickets}',
              subtitle: 'Semua tiket tenant',
              icon: Icons.confirmation_number_outlined,
              color: theme.colorScheme.primary,
            ),
            SummaryMetricCard(
              title: AppStrings.activeTickets,
              value: '$activeCount',
              subtitle: 'Sedang berjalan',
              icon: Icons.pending_actions_outlined,
              color: theme.colorScheme.tertiary,
            ),
            SummaryMetricCard(
              title: AppStrings.overdueTickets,
              value: '${summary.overdueCount}',
              subtitle: 'Melewati batas SLA',
              icon: Icons.warning_amber_rounded,
              color: theme.colorScheme.error,
            ),
            SummaryMetricCard(
              title: AppStrings.slaCompliance,
              value: '${summary.slaCompliancePercentage.toStringAsFixed(1)}%',
              subtitle: 'Kepatuhan target',
              icon: Icons.verified_outlined,
              color: summary.slaCompliancePercentage >= 80
                  ? (statusColors?.slaSafe ?? theme.colorScheme.primary)
                  : theme.colorScheme.error,
            ),
          ],
        ),
        const SizedBox(height: AppSizes.p12),

        // Kartu Rata-rata Durasi Penyelesaian
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.r12),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.p16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.p12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(AppSizes.r12),
                  ),
                  child: Icon(
                    Icons.timer_outlined,
                    color: theme.colorScheme.onSecondaryContainer,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSizes.p16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.avgResolutionTime,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSizes.p4),
                      Text(
                        '${summary.avgResolutionHours.toStringAsFixed(1)} Jam',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSizes.p16),

        // Rincian Status Tiket (Horizontal Chips / Breakdown)
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.r12),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.statusBreakdown,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.p12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatusItem(
                      context,
                      label: 'Baru',
                      count: summary.byStatus['new'] ?? 0,
                      color:
                          statusColors?.statusNew ?? theme.colorScheme.primary,
                    ),
                    _buildStatusItem(
                      context,
                      label: 'Diteruskan',
                      count: summary.byStatus['forwarded'] ?? 0,
                      color:
                          statusColors?.statusForwarded ??
                          theme.colorScheme.secondary,
                    ),
                    _buildStatusItem(
                      context,
                      label: 'Ditugaskan',
                      count: summary.byStatus['assigned'] ?? 0,
                      color:
                          statusColors?.statusAssigned ??
                          theme.colorScheme.tertiary,
                    ),
                    _buildStatusItem(
                      context,
                      label: 'Dikerjakan',
                      count: summary.byStatus['in_progress'] ?? 0,
                      color:
                          statusColors?.statusInProgress ??
                          theme.colorScheme.primary,
                    ),
                    _buildStatusItem(
                      context,
                      label: 'Selesai',
                      count: summary.byStatus['resolved'] ?? 0,
                      color:
                          statusColors?.statusResolved ??
                          theme.colorScheme.secondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusItem(
    BuildContext context, {
    required String label,
    required int count,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.p12,
            vertical: AppSizes.p4,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppSizes.r16),
          ),
          child: Text(
            '$count',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.p4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
