import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/ticket_history.dart';
import '../repositories/ticket_repository.dart';

class GetTicketHistories {
  final TicketRepository repository;

  GetTicketHistories(this.repository);

  Future<Either<Failure, List<TicketHistory>>> call(int ticketId) {
    return repository.getTicketHistories(ticketId);
  }
}
