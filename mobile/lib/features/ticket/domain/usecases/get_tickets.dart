import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_result.dart';
import '../entities/ticket.dart';
import '../repositories/ticket_repository.dart';

class GetTicketsParams extends Equatable {
  final int page;
  final int limit;
  final String? status;
  final int? areaId;
  final int? vendorId;
  final String? sla;
  final String? q;

  const GetTicketsParams({
    this.page = 1,
    this.limit = 10,
    this.status,
    this.areaId,
    this.vendorId,
    this.sla,
    this.q,
  });

  @override
  List<Object?> get props => [page, limit, status, areaId, vendorId, sla, q];
}

class GetTickets {
  final TicketRepository repository;

  GetTickets(this.repository);

  Future<Either<Failure, PaginatedResult<Ticket>>> call([
    GetTicketsParams params = const GetTicketsParams(),
  ]) {
    return repository.getTickets(
      page: params.page,
      limit: params.limit,
      status: params.status,
      areaId: params.areaId,
      vendorId: params.vendorId,
      sla: params.sla,
      q: params.q,
    );
  }
}
