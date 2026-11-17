import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  final int id;
  final int userId;
  final int? ticketId;
  final String? ticketNo;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    this.ticketId,
    this.ticketNo,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    ticketId,
    ticketNo,
    message,
    isRead,
    createdAt,
  ];
}
