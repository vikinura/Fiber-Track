import '../../domain/entities/ticket_history.dart';

class TicketHistoryModel extends TicketHistory {
  const TicketHistoryModel({
    required super.id,
    required super.ticketId,
    super.userId,
    super.userName,
    super.userRole,
    super.fromStatus,
    required super.toStatus,
    super.note,
    required super.createdAt,
  });

  factory TicketHistoryModel.fromJson(Map<String, dynamic> json) {
    return TicketHistoryModel(
      id: json['id'] as int,
      ticketId: json['ticket_id'] as int,
      userId: json['user_id'] as int?,
      userName: json['user_name'] as String?,
      userRole: json['user_role'] as String?,
      fromStatus: json['from_status'] as String?,
      toStatus: json['to_status'] as String,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_id': ticketId,
      'user_id': userId,
      'user_name': userName,
      'user_role': userRole,
      'from_status': fromStatus,
      'to_status': toStatus,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
