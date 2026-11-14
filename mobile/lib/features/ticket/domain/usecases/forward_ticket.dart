import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/ticket.dart';
import '../repositories/ticket_repository.dart';

class ForwardTicket {
  final TicketRepository repository;

  ForwardTicket(this.repository);

  Future<Either<Failure, Ticket>> call(int ticketId, int vendorId) {
    return repository.forwardTicket(ticketId, vendorId);
  }
}
