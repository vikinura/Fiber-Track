import 'package:equatable/equatable.dart';

class TicketHistory extends Equatable {
  final int id;
  final int ticketId;
  final int? userId;
  final String? userName;
  final String? userRole;
  final String? fromStatus;
  final String toStatus;
  final String? note;
  final DateTime createdAt;

  const TicketHistory({
    required this.id,
    required this.ticketId,
    this.userId,
    this.userName,
    this.userRole,
    this.fromStatus,
    required this.toStatus,
    this.note,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    ticketId,
    userId,
    userName,
    userRole,
    fromStatus,
    toStatus,
    note,
    createdAt,
  ];
}
