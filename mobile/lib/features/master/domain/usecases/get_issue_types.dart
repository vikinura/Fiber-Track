import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/issue_type.dart';
import '../repositories/master_lookup_repository.dart';

class GetIssueTypes {
  final MasterLookupRepository repository;

  GetIssueTypes(this.repository);

  Future<Either<Failure, List<IssueType>>> call() {
    return repository.getIssueTypes();
  }
}
