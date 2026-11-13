import '../../domain/entities/ticket_photo.dart';

class TicketPhotoModel extends TicketPhoto {
  const TicketPhotoModel({
    required super.id,
    required super.ticketId,
    required super.uploadedBy,
    required super.filePath,
    super.caption,
    required super.createdAt,
  });

  factory TicketPhotoModel.fromJson(Map<String, dynamic> json) {
    return TicketPhotoModel(
      id: json['id'] as int,
      ticketId: json['ticket_id'] as int,
      uploadedBy: json['uploaded_by'] as int,
      filePath: json['file_path'] as String,
      caption: json['caption'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_id': ticketId,
      'uploaded_by': uploadedBy,
      'file_path': filePath,
      'caption': caption,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
