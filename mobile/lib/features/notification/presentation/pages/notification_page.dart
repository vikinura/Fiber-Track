import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  String _formatDateTime(DateTime dt) {
    try {
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dt.toLocal());
    } catch (_) {
      return DateFormat('dd MMM yyyy, HH:mm').format(dt.toLocal());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Segarkan',
            onPressed: () {
              context.read<NotificationBloc>().add(
                const LoadNotificationsEvent(),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const LoadingView(message: 'Memuat notifikasi...');
          }

          if (state is NotificationError) {
            return ErrorView(
              message: state.message,
              onRetry: () {
                context.read<NotificationBloc>().add(
                  const LoadNotificationsEvent(),
                );
              },
            );
          }

          if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return const EmptyView(
                message: 'Anda belum memiliki pemberitahuan baru saat ini.',
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationBloc>().add(
                  const LoadNotificationsEvent(),
                );
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSizes.p16),
                itemCount: state.notifications.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSizes.p8),
                itemBuilder: (context, index) {
                  final notif = state.notifications[index];
                  final isUnread = !notif.isRead;

                  return Card(
                    elevation: isUnread ? 1 : 0,
                    color: isUnread
                        ? theme.colorScheme.primaryContainer.withValues(
                            alpha: 0.25,
                          )
                        : theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.r12),
                      side: BorderSide(
                        color: isUnread
                            ? theme.colorScheme.primary.withValues(alpha: 0.3)
                            : theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppSizes.r12),
                      onTap: () {
                        if (isUnread) {
                          context.read<NotificationBloc>().add(
                            MarkAsReadEvent(notif.id),
                          );
                        }
                        if (notif.ticketId != null) {
                          context.push('/tickets/${notif.ticketId}');
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.p16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSizes.p8),
                              decoration: BoxDecoration(
                                color: isUnread
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.surfaceContainerHighest,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.notifications_outlined,
                                size: 18,
                                color: isUnread
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: AppSizes.p12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      if (notif.ticketNo != null) ...[
                                        Text(
                                          notif.ticketNo!,
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    theme.colorScheme.primary,
                                              ),
                                        ),
                                        const SizedBox(width: AppSizes.p8),
                                      ],
                                      Expanded(
                                        child: Text(
                                          _formatDateTime(notif.createdAt),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                                fontSize: 11,
                                              ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSizes.p8),
                                  Text(
                                    notif.message,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: isUnread
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
