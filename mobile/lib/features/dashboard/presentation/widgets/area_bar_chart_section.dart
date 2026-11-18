import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/dashboard_data.dart';

class AreaBarChartSection extends StatelessWidget {
  final List<DashboardArea> areas;

  const AreaBarChartSection({super.key, required this.areas});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (areas.isEmpty) {
      return Card(
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
              'Belum ada data area jaringan',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    // Hitung maxY untuk chart
    double maxCount = 0;
    for (final area in areas) {
      if (area.totalTickets > maxCount) {
        maxCount = area.totalTickets.toDouble();
      }
    }
    final maxY = maxCount < 5 ? 5.0 : (maxCount + 2);

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
            Row(
              children: [
                Icon(
                  Icons.bar_chart_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: AppSizes.p8),
                Text(
                  AppStrings.ticketDistributionByArea,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p12),

            // Legend
            Row(
              children: [
                _buildLegendItem(
                  color: theme.colorScheme.primary,
                  label: 'Total Tiket',
                  textStyle: theme.textTheme.bodySmall,
                ),
                const SizedBox(width: AppSizes.p16),
                _buildLegendItem(
                  color: Colors.teal,
                  label: 'Selesai',
                  textStyle: theme.textTheme.bodySmall,
                ),
                const SizedBox(width: AppSizes.p16),
                _buildLegendItem(
                  color: theme.colorScheme.tertiary,
                  label: 'Aktif',
                  textStyle: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p20),

            // Bar Chart
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final area = areas[groupIndex];
                        String label = '';
                        int value = 0;
                        if (rodIndex == 0) {
                          label = 'Total';
                          value = area.totalTickets;
                        } else if (rodIndex == 1) {
                          label = 'Selesai';
                          value = area.resolvedTickets;
                        } else {
                          label = 'Aktif';
                          value = area.activeTickets;
                        }
                        return BarTooltipItem(
                          '${area.areaName}\n$label: $value',
                          TextStyle(
                            color: theme.colorScheme.onInverseSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: (maxY / 4).ceilToDouble(),
                        getTitlesWidget: (value, meta) {
                          if (value == meta.max || value % 1 != 0) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            value.toInt().toString(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= areas.length) {
                            return const SizedBox.shrink();
                          }
                          final name = areas[index].areaName;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              name.length > 8
                                  ? '${name.substring(0, 7)}…'
                                  : name,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (maxY / 4).ceilToDouble(),
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.3,
                      ),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: areas.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final area = entry.value;

                    return BarChartGroupData(
                      x: idx,
                      barsSpace: 4,
                      barRods: [
                        BarChartRodData(
                          toY: area.totalTickets.toDouble(),
                          color: theme.colorScheme.primary,
                          width: 10,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppSizes.r4),
                          ),
                        ),
                        BarChartRodData(
                          toY: area.resolvedTickets.toDouble(),
                          color: Colors.teal,
                          width: 10,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppSizes.r4),
                          ),
                        ),
                        BarChartRodData(
                          toY: area.activeTickets.toDouble(),
                          color: theme.colorScheme.tertiary,
                          width: 10,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppSizes.r4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    TextStyle? textStyle,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSizes.p4),
        Text(label, style: textStyle),
      ],
    );
  }
}
