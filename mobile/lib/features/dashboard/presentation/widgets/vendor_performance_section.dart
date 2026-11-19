import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/status_colors.dart';
import '../../domain/entities/dashboard_data.dart';

class VendorPerformanceSection extends StatelessWidget {
  final List<DashboardVendor> vendors;

  const VendorPerformanceSection({super.key, required this.vendors});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.business_center_outlined,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: AppSizes.p8),
            Text(
              AppStrings.vendorPerformance,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.p12),
        if (vendors.isEmpty)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.r12),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p24),
              child: Center(
                child: Text(
                  'Belum ada data performa mitra vendor',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: vendors.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSizes.p12),
            itemBuilder: (context, index) {
              final vendor = vendors[index];
              return _buildVendorCard(context, vendor);
            },
          ),
      ],
    );
  }

  Widget _buildVendorCard(BuildContext context, DashboardVendor vendor) {
    final theme = Theme.of(context);
    final statusColors = theme.extension<StatusColors>();
    final resolvedColor =
        statusColors?.statusResolved ?? theme.colorScheme.secondary;
    final isGoodSla = vendor.slaCompliancePercentage >= 80.0;
    final slaColor = isGoodSla
        ? (statusColors?.slaSafe ?? theme.colorScheme.primary)
        : theme.colorScheme.error;

    return Card(
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
            // Vendor Header
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.business_rounded,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSizes.p12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendor.vendorName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Total Tiket Ditangani: ${vendor.totalTickets}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.p8,
                    vertical: AppSizes.p4,
                  ),
                  decoration: BoxDecoration(
                    color: slaColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSizes.r8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isGoodSla
                            ? Icons.check_circle_outline
                            : Icons.warning_amber_rounded,
                        size: 14,
                        color: slaColor,
                      ),
                      const SizedBox(width: AppSizes.p4),
                      Text(
                        '${vendor.slaCompliancePercentage.toStringAsFixed(1)}% SLA',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: slaColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p16),
            const Divider(height: 1),
            const SizedBox(height: AppSizes.p12),

            // Performance Metrics Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricColumn(
                  context,
                  label: AppStrings.resolvedTickets,
                  value: '${vendor.resolvedTickets}',
                  icon: Icons.task_alt_rounded,
                  iconColor: resolvedColor,
                ),
                Container(
                  height: 30,
                  width: 1,
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
                _buildMetricColumn(
                  context,
                  label: 'Tiket Berjalan',
                  value: '${vendor.activeTickets}',
                  icon: Icons.pending_actions_rounded,
                  iconColor: theme.colorScheme.tertiary,
                ),
                Container(
                  height: 30,
                  width: 1,
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
                _buildMetricColumn(
                  context,
                  label: AppStrings.avgResolutionTime,
                  value: '${vendor.avgResolutionHours.toStringAsFixed(1)} Jam',
                  icon: Icons.timer_outlined,
                  iconColor: theme.colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumn(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: AppSizes.p4),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.p4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
