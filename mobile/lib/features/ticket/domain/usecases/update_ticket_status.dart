import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/ticket.dart';
import '../repositories/ticket_repository.dart';

class UpdateTicketStatus {
  final TicketRepository repository;

  UpdateTicketStatus(this.repository);

  Future<Either<Failure, Ticket>> call({
    required int ticketId,
    required String toStatus,
    String? note,
  }) {
    return repository.updateTicketStatus(
      ticketId: ticketId,
      toStatus: toStatus,
      note: note,
    );
  }
}
