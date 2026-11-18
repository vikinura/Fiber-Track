import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotificationsEvent extends NotificationEvent {
  final bool isSilent;

  const LoadNotificationsEvent({this.isSilent = false});

  @override
  List<Object?> get props => [isSilent];
}

class MarkAsReadEvent extends NotificationEvent {
  final int id;

  const MarkAsReadEvent(this.id);

  @override
  List<Object?> get props => [id];
}
