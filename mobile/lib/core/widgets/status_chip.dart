import 'package:flutter/material.dart';

import '../theme/status_colors.dart';
import '../../features/ticket/domain/entities/ticket_status.dart';

class StatusChip extends StatelessWidget {
  final TicketStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final statusColors = Theme.of(context).extension<StatusColors>();

    Color color;
    switch (status) {
      case TicketStatus.newStatus:
        color = statusColors?.statusNew ?? Colors.blue;
        break;
      case TicketStatus.forwarded:
        color = statusColors?.statusForwarded ?? Colors.purple;
        break;
      case TicketStatus.assigned:
        color = statusColors?.statusAssigned ?? Colors.amber;
        break;
      case TicketStatus.inProgress:
        color = statusColors?.statusInProgress ?? Colors.orange;
        break;
      case TicketStatus.resolved:
        color = statusColors?.statusResolved ?? Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
