import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_result.dart';
import '../../domain/entities/ticket.dart';
import '../../domain/entities/ticket_history.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../datasources/ticket_remote_data_source.dart';

class TicketRepositoryImpl implements TicketRepository {
  final TicketRemoteDataSource remoteDataSource;

  TicketRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PaginatedResult<Ticket>>> getTickets({
    int page = 1,
    int limit = 10,
    String? status,
    int? areaId,
    int? vendorId,
    String? sla,
    String? q,
  }) async {
    try {
      final result = await remoteDataSource.getTickets(
        page: page,
        limit: limit,
        status: status,
        areaId: areaId,
        vendorId: vendorId,
        sla: sla,
        q: q,
      );
      return Right(result);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Ticket>> getTicketDetail(int id) async {
    try {
      final result = await remoteDataSource.getTicketDetail(id);
      return Right(result);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TicketHistory>>> getTicketHistories(
    int ticketId,
  ) async {
    try {
      final result = await remoteDataSource.getTicketHistories(ticketId);
      return Right(result);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Ticket>> createTicket({
    required int customerId,
    required int areaId,
    int? odpId,
    required int issueTypeId,
    required int priorityId,
    required String description,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final result = await remoteDataSource.createTicket(
        customerId: customerId,
        areaId: areaId,
        odpId: odpId,
        issueTypeId: issueTypeId,
        priorityId: priorityId,
        description: description,
        latitude: latitude,
        longitude: longitude,
      );
      return Right(result);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final result = await remoteDataSource.updateTicket(
        id: id,
        customerId: customerId,
        areaId: areaId,
        odpId: odpId,
        issueTypeId: issueTypeId,
        priorityId: priorityId,
        description: description,
        latitude: latitude,
        longitude: longitude,
      );
      return Right(result);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message, errors: e.errors));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
