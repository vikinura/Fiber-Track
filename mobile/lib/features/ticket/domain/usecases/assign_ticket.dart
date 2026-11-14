import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/ticket.dart';
import '../repositories/ticket_repository.dart';

class AssignTicket {
  final TicketRepository repository;

  AssignTicket(this.repository);

  Future<Either<Failure, Ticket>> call(int ticketId, int technicianId) {
    return repository.assignTicket(ticketId, technicianId);
  }
}
