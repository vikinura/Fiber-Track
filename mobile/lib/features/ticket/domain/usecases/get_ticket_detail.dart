import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/ticket.dart';
import '../repositories/ticket_repository.dart';

class GetTicketDetail {
  final TicketRepository repository;

  GetTicketDetail(this.repository);

  Future<Either<Failure, Ticket>> call(int id) {
    return repository.getTicketDetail(id);
  }
}
