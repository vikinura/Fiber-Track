import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/customer.dart';
import '../repositories/master_lookup_repository.dart';

class CreateCustomer {
  final MasterLookupRepository repository;

  CreateCustomer(this.repository);

  Future<Either<Failure, Customer>> call({
    required String name,
    String? phone,
    String? address,
    int? areaId,
    int? odpId,
  }) {
    return repository.createCustomer(
      name: name,
      phone: phone,
      address: address,
      areaId: areaId,
      odpId: odpId,
    );
  }
}

class UpdateCustomer {
  final MasterLookupRepository repository;

  UpdateCustomer(this.repository);

  Future<Either<Failure, Customer>> call({
    required int id,
    required String name,
    String? phone,
    String? address,
    int? areaId,
    int? odpId,
  }) {
    return repository.updateCustomer(
      id: id,
      name: name,
      phone: phone,
      address: address,
      areaId: areaId,
      odpId: odpId,
    );
  }
}

class DeleteCustomer {
  final MasterLookupRepository repository;

  DeleteCustomer(this.repository);

  Future<Either<Failure, void>> call(int id) {
    return repository.deleteCustomer(id);
  }
}
