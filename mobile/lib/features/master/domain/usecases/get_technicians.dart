import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../repositories/master_lookup_repository.dart';

class GetTechnicians {
  final MasterLookupRepository repository;

  GetTechnicians(this.repository);

  Future<Either<Failure, List<User>>> call() {
    return repository.getTechnicians();
  }
}
