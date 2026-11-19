import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/area.dart';
import '../repositories/master_lookup_repository.dart';

class CreateArea {
  final MasterLookupRepository repository;

  CreateArea(this.repository);

  Future<Either<Failure, Area>> call({
    required String name,
    String? description,
  }) {
    return repository.createArea(name: name, description: description);
  }
}

class UpdateArea {
  final MasterLookupRepository repository;

  UpdateArea(this.repository);

  Future<Either<Failure, Area>> call({
    required int id,
    required String name,
    String? description,
  }) {
    return repository.updateArea(id: id, name: name, description: description);
  }
}

class DeleteArea {
  final MasterLookupRepository repository;

  DeleteArea(this.repository);

  Future<Either<Failure, void>> call(int id) {
    return repository.deleteArea(id);
  }
}
