import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_result.dart';
import '../../../../core/network/error_mapper.dart';
import '../../domain/entities/area.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/issue_type.dart';
import '../../domain/entities/odp.dart';
import '../../domain/entities/priority.dart';
import '../../domain/entities/vendor.dart';
import '../../domain/repositories/master_lookup_repository.dart';
import '../../../auth/domain/entities/user.dart';
import '../datasources/master_remote_data_source.dart';

class MasterLookupRepositoryImpl implements MasterLookupRepository {
  final MasterRemoteDataSource remoteDataSource;

  MasterLookupRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Area>>> getAreas() async {
    try {
      final models = await remoteDataSource.getAreas();
      return Right(models.map((m) => m.toEntity()).toList());
    } on Exception catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<Odp>>> getOdps({int? areaId}) async {
    try {
      final models = await remoteDataSource.getOdps(areaId: areaId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on Exception catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<IssueType>>> getIssueTypes() async {
    try {
      final models = await remoteDataSource.getIssueTypes();
      return Right(models.map((m) => m.toEntity()).toList());
    } on Exception catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<Priority>>> getPriorities() async {
    try {
      final models = await remoteDataSource.getPriorities();
      return Right(models.map((m) => m.toEntity()).toList());
    } on Exception catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<Vendor>>> getVendors() async {
    try {
      final models = await remoteDataSource.getVendors();
      return Right(models.map((m) => m.toEntity()).toList());
    } on Exception catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getTechnicians() async {
    try {
      final models = await remoteDataSource.getTechnicians();
      return Right(models.map((m) => m.toEntity()).toList());
    } on Exception catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, PaginatedResult<Customer>>> getCustomers({
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final result = await remoteDataSource.getCustomers(
        search: search,
        page: page,
        limit: limit,
      );
      return Right(
        PaginatedResult<Customer>(
          data: result.data.map((m) => m.toEntity()).toList(),
          page: result.page,
          limit: result.limit,
          total: result.total,
        ),
      );
    } on Exception catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Area>> createArea({
    required String name,
    String? description,
  }) async {
    try {
      final model = await remoteDataSource.createArea(
        name: name,
        description: description,
      );
      return Right(model.toEntity());
    } on Exception catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Area>> updateArea({
    required int id,
    required String name,
    String? description,
  }) async {
    try {
      final model = await remoteDataSource.updateArea(
        id: id,
        name: name,
        description: description,
      );
      return Right(model.toEntity());
    } on Exception catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteArea(int id) async {
    try {
      await remoteDataSource.deleteArea(id);
      return const Right(null);
    } on Exception catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Customer>> createCustomer({
    required String name,
    String? phone,
    String? address,
    int? areaId,
    int? odpId,
  }) async {
    try {
      final model = await remoteDataSource.createCustomer(
        name: name,
        phone: phone,
        address: address,
        areaId: areaId,
        odpId: odpId,
      );
      return Right(model.toEntity());
    } on Exception catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, Customer>> updateCustomer({
    required int id,
    required String name,
    String? phone,
    String? address,
    int? areaId,
    int? odpId,
  }) async {
    try {
      final model = await remoteDataSource.updateCustomer(
        id: id,
        name: name,
        phone: phone,
        address: address,
        areaId: areaId,
        odpId: odpId,
      );
      return Right(model.toEntity());
    } on Exception catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCustomer(int id) async {
    try {
      await remoteDataSource.deleteCustomer(id);
      return const Right(null);
    } on Exception catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
