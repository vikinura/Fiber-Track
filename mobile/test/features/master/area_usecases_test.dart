import 'package:fibertrack/core/error/failures.dart';
import 'package:fibertrack/core/models/paginated_result.dart';
import 'package:fibertrack/features/auth/domain/entities/user.dart';
import 'package:fibertrack/features/master/domain/entities/area.dart';
import 'package:fibertrack/features/master/domain/entities/customer.dart';
import 'package:fibertrack/features/master/domain/entities/issue_type.dart';
import 'package:fibertrack/features/master/domain/entities/odp.dart';
import 'package:fibertrack/features/master/domain/entities/priority.dart';
import 'package:fibertrack/features/master/domain/entities/vendor.dart';
import 'package:fibertrack/features/master/domain/repositories/master_lookup_repository.dart';
import 'package:fibertrack/features/master/domain/usecases/area_crud_usecases.dart';
import 'package:fibertrack/features/master/domain/usecases/get_areas.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

class MockMasterLookupRepository implements MasterLookupRepository {
  List<Area> areas = [
    const Area(
      id: 1,
      tenantId: 1,
      name: 'Surabaya Pusat',
      description: 'Area pusat kota',
    ),
  ];

  @override
  Future<Either<Failure, List<Area>>> getAreas() async {
    return Right(areas);
  }

  @override
  Future<Either<Failure, Area>> createArea({
    required String name,
    String? description,
  }) async {
    final newArea = Area(
      id: areas.length + 1,
      tenantId: 1,
      name: name,
      description: description,
    );
    areas.add(newArea);
    return Right(newArea);
  }

  @override
  Future<Either<Failure, Area>> updateArea({
    required int id,
    required String name,
    String? description,
  }) async {
    final index = areas.indexWhere((a) => a.id == id);
    if (index == -1) {
      return const Left(ServerFailure(message: 'Area tidak ditemukan'));
    }
    final updated = Area(
      id: id,
      tenantId: 1,
      name: name,
      description: description,
    );
    areas[index] = updated;
    return Right(updated);
  }

  @override
  Future<Either<Failure, void>> deleteArea(int id) async {
    final index = areas.indexWhere((a) => a.id == id);
    if (index == -1) {
      return const Left(ServerFailure(message: 'Area tidak ditemukan'));
    }
    areas.removeAt(index);
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<Odp>>> getOdps({int? areaId}) async =>
      const Right([]);

  @override
  Future<Either<Failure, List<IssueType>>> getIssueTypes() async =>
      const Right([]);

  @override
  Future<Either<Failure, List<Priority>>> getPriorities() async =>
      const Right([]);

  @override
  Future<Either<Failure, List<Vendor>>> getVendors() async => const Right([]);

  @override
  Future<Either<Failure, List<User>>> getTechnicians() async => const Right([]);

  @override
  Future<Either<Failure, PaginatedResult<Customer>>> getCustomers({
    String? search,
    int page = 1,
    int limit = 10,
  }) async =>
      const Right(PaginatedResult(data: [], page: 1, limit: 10, total: 0));

  @override
  Future<Either<Failure, Customer>> createCustomer({
    required String name,
    String? phone,
    String? address,
    int? areaId,
    int? odpId,
  }) async => const Left(ServerFailure(message: 'not implemented'));

  @override
  Future<Either<Failure, Customer>> updateCustomer({
    required int id,
    required String name,
    String? phone,
    String? address,
    int? areaId,
    int? odpId,
  }) async => const Left(ServerFailure(message: 'not implemented'));

  @override
  Future<Either<Failure, void>> deleteCustomer(int id) async =>
      const Right(null);
}

void main() {
  late MockMasterLookupRepository repository;
  late GetAreas getAreas;
  late CreateArea createArea;
  late UpdateArea updateArea;
  late DeleteArea deleteArea;

  setUp(() {
    repository = MockMasterLookupRepository();
    getAreas = GetAreas(repository);
    createArea = CreateArea(repository);
    updateArea = UpdateArea(repository);
    deleteArea = DeleteArea(repository);
  });

  group('Area Use Cases Tests', () {
    test('GetAreas should return list of areas', () async {
      final result = await getAreas();
      expect(result.isRight(), true);
      result.fold((_) => fail('should succeed'), (list) {
        expect(list.length, 1);
        expect(list.first.name, 'Surabaya Pusat');
      });
    });

    test('CreateArea should add new area and return it', () async {
      final result = await createArea(
        name: 'Surabaya Barat',
        description: 'Area perumahan',
      );
      expect(result.isRight(), true);
      result.fold((_) => fail('should succeed'), (area) {
        expect(area.id, 2);
        expect(area.name, 'Surabaya Barat');
      });

      final listResult = await getAreas();
      listResult.fold((_) => fail('should succeed'), (list) {
        expect(list.length, 2);
      });
    });

    test('UpdateArea should update existing area', () async {
      final result = await updateArea(
        id: 1,
        name: 'Surabaya Pusat Baru',
        description: 'Deskripsi update',
      );
      expect(result.isRight(), true);
      result.fold((_) => fail('should succeed'), (area) {
        expect(area.name, 'Surabaya Pusat Baru');
      });
    });

    test('DeleteArea should remove area from repository', () async {
      final deleteRes = await deleteArea(1);
      expect(deleteRes.isRight(), true);

      final listResult = await getAreas();
      listResult.fold((_) => fail('should succeed'), (list) {
        expect(list.isEmpty, true);
      });
    });
  });
}
