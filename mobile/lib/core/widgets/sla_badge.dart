import 'package:flutter/material.dart';

import '../theme/status_colors.dart';
import '../../features/ticket/domain/entities/sla_status.dart';

class SlaBadge extends StatelessWidget {
  final SlaStatus slaStatus;
  final int? remainingSeconds;

  const SlaBadge({super.key, required this.slaStatus, this.remainingSeconds});

  String _formatRemaining(int seconds) {
    final absSec = seconds.abs();
    final hours = absSec ~/ 3600;
    final minutes = (absSec % 3600) ~/ 60;

    String timeStr;
    if (hours > 0) {
      timeStr = '${hours}j ${minutes}m';
    } else {
      timeStr = '${minutes}m';
    }

    if (seconds < 0) {
      return '-$timeStr';
    }
    return timeStr;
  }

  @override
  Widget build(BuildContext context) {
    final statusColors = Theme.of(context).extension<StatusColors>();

    Color color;
    switch (slaStatus) {
      case SlaStatus.onTrack:
        color = statusColors?.slaSafe ?? Colors.green;
        break;
      case SlaStatus.atRisk:
        color = statusColors?.slaAtRisk ?? Colors.orange;
        break;
      case SlaStatus.overdue:
        color = statusColors?.slaOverdue ?? Colors.red;
        break;
      case SlaStatus.met:
        color = statusColors?.slaSafe ?? Colors.green;
        break;
      case SlaStatus.breached:
        color = statusColors?.slaBreached ?? Colors.redAccent;
        break;
    }

    String labelText = slaStatus.label;
    if (remainingSeconds != null && remainingSeconds != 0) {
      if (slaStatus == SlaStatus.onTrack ||
          slaStatus == SlaStatus.atRisk ||
          slaStatus == SlaStatus.overdue) {
        final prefix = slaStatus == SlaStatus.overdue ? 'Telat ' : 'Sisa ';
        labelText =
            '$labelText ($prefix${_formatRemaining(remainingSeconds!)})';
      } else if (slaStatus == SlaStatus.breached) {
        labelText = '$labelText (Telat ${_formatRemaining(remainingSeconds!)})';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        labelText,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
