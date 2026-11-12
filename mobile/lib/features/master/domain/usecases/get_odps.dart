import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/odp.dart';
import '../repositories/master_lookup_repository.dart';

class GetOdps {
  final MasterLookupRepository repository;

  GetOdps(this.repository);

  Future<Either<Failure, List<Odp>>> call({int? areaId}) {
    return repository.getOdps(areaId: areaId);
  }
}
