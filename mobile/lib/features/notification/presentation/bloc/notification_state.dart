import 'package:equatable/equatable.dart';

import '../../domain/entities/notification.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationLoaded extends NotificationState {
  final List<AppNotification> notifications;
  final int unreadCount;

  const NotificationLoaded({
    required this.notifications,
    required this.unreadCount,
  });

  NotificationLoaded copyWith({
    List<AppNotification>? notifications,
    int? unreadCount,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [notifications, unreadCount];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}
