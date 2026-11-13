import 'package:equatable/equatable.dart';

class TicketPhoto extends Equatable {
  final int id;
  final int ticketId;
  final int uploadedBy;
  final String filePath;
  final String? caption;
  final DateTime createdAt;

  const TicketPhoto({
    required this.id,
    required this.ticketId,
    required this.uploadedBy,
    required this.filePath,
    this.caption,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    ticketId,
    uploadedBy,
    filePath,
    caption,
    createdAt,
  ];
}
