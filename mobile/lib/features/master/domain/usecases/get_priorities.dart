import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/priority.dart';
import '../repositories/master_lookup_repository.dart';

class GetPriorities {
  final MasterLookupRepository repository;

  GetPriorities(this.repository);

  Future<Either<Failure, List<Priority>>> call() {
    return repository.getPriorities();
  }
}
