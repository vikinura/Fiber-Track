import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/ticket_photo.dart';
import '../repositories/ticket_repository.dart';

class UploadTicketPhoto {
  final TicketRepository repository;

  UploadTicketPhoto(this.repository);

  Future<Either<Failure, TicketPhoto>> call({
    required int ticketId,
    required String filePath,
    String? caption,
  }) async {
    return await repository.uploadPhoto(
      ticketId: ticketId,
      filePath: filePath,
      caption: caption,
    );
  }
}
