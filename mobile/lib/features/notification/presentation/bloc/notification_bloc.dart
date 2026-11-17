import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/notification.dart';
import '../../domain/usecases/get_notifications.dart';
import '../../domain/usecases/mark_notification_as_read.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotifications getNotifications;
  final MarkNotificationAsRead markNotificationAsRead;

  NotificationBloc({
    required this.getNotifications,
    required this.markNotificationAsRead,
  }) : super(const NotificationInitial()) {
    on<LoadNotificationsEvent>(_onLoadNotifications);
    on<MarkAsReadEvent>(_onMarkAsRead);
  }

  Future<void> _onLoadNotifications(
    LoadNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (!event.isSilent || state is! NotificationLoaded) {
      emit(const NotificationLoading());
    }

    final result = await getNotifications();

    result.fold(
      (failure) {
        if (!event.isSilent || state is! NotificationLoaded) {
          emit(NotificationError(failure.message));
        }
      },
      (notifications) {
        final unreadCount = notifications.where((n) => !n.isRead).length;
        emit(
          NotificationLoaded(
            notifications: notifications,
            unreadCount: unreadCount,
          ),
        );
      },
    );
  }

  Future<void> _onMarkAsRead(
    MarkAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is! NotificationLoaded) return;

    // Optimistic update
    final updatedList = currentState.notifications.map((n) {
      if (n.id == event.id) {
        return AppNotification(
          id: n.id,
          userId: n.userId,
          ticketId: n.ticketId,
          ticketNo: n.ticketNo,
          message: n.message,
          isRead: true,
          createdAt: n.createdAt,
        );
      }
      return n;
    }).toList();

    final unreadCount = updatedList.where((n) => !n.isRead).length;
    emit(
      NotificationLoaded(notifications: updatedList, unreadCount: unreadCount),
    );

    // Kirim patch ke backend
    await markNotificationAsRead(event.id);
  }
}
