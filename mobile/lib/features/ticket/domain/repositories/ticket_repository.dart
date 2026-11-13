import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_result.dart';
import '../entities/ticket.dart';
import '../entities/ticket_history.dart';

abstract class TicketRepository {
  Future<Either<Failure, PaginatedResult<Ticket>>> getTickets({
    int page = 1,
    int limit = 10,
    String? status,
    int? areaId,
    int? vendorId,
    String? sla,
    String? q,
  });

  Future<Either<Failure, Ticket>> getTicketDetail(int id);

  Future<Either<Failure, List<TicketHistory>>> getTicketHistories(int ticketId);

  Future<Either<Failure, Ticket>> createTicket({
    required int customerId,
    required int areaId,
    int? odpId,
    required int issueTypeId,
    required int priorityId,
    required String description,
    double? latitude,
    double? longitude,
  });

  Future<Either<Failure, Ticket>> updateTicket({
    required int id,
    required int customerId,
    required int areaId,
    int? odpId,
    required int issueTypeId,
    required int priorityId,
    required String description,
    double? latitude,
    double? longitude,
  });
}
