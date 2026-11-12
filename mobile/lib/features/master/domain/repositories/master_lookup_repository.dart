import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/area.dart';
import '../entities/odp.dart';

abstract class MasterLookupRepository {
  Future<Either<Failure, List<Area>>> getAreas();
  Future<Either<Failure, List<Odp>>> getOdps({int? areaId});
}
