import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/area.dart';
import '../repositories/master_lookup_repository.dart';

class GetAreas {
  final MasterLookupRepository repository;

  GetAreas(this.repository);

  Future<Either<Failure, List<Area>>> call() {
    return repository.getAreas();
  }
}
