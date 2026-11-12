import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_result.dart';
import '../entities/customer.dart';
import '../repositories/master_lookup_repository.dart';

class GetCustomers {
  final MasterLookupRepository repository;

  GetCustomers(this.repository);

  Future<Either<Failure, PaginatedResult<Customer>>> call({
    String? search,
    int page = 1,
    int limit = 10,
  }) {
    return repository.getCustomers(search: search, page: page, limit: limit);
  }
}
