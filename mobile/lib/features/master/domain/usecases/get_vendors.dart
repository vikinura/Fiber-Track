import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/vendor.dart';
import '../repositories/master_lookup_repository.dart';

class GetVendors {
  final MasterLookupRepository repository;

  GetVendors(this.repository);

  Future<Either<Failure, List<Vendor>>> call() {
    return repository.getVendors();
  }
}
