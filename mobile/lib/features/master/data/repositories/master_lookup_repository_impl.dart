import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/error_mapper.dart';
import '../../domain/entities/area.dart';
import '../../domain/entities/issue_type.dart';
import '../../domain/entities/odp.dart';
import '../../domain/entities/priority.dart';
import '../../domain/repositories/master_lookup_repository.dart';
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
}
