import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/area.dart';
import '../entities/issue_type.dart';
import '../entities/odp.dart';
import '../entities/priority.dart';

abstract class MasterLookupRepository {
  Future<Either<Failure, List<Area>>> getAreas();
  Future<Either<Failure, List<Odp>>> getOdps({int? areaId});
  Future<Either<Failure, List<IssueType>>> getIssueTypes();
  Future<Either<Failure, List<Priority>>> getPriorities();
}
