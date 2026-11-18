import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/paginated_result.dart';
import '../entities/area.dart';
import '../entities/customer.dart';
import '../entities/issue_type.dart';
import '../entities/odp.dart';
import '../entities/priority.dart';
import '../entities/vendor.dart';
import '../../../auth/domain/entities/user.dart';

abstract class MasterLookupRepository {
  Future<Either<Failure, List<Area>>> getAreas();
  Future<Either<Failure, List<Odp>>> getOdps({int? areaId});
  Future<Either<Failure, List<IssueType>>> getIssueTypes();
  Future<Either<Failure, List<Priority>>> getPriorities();
  Future<Either<Failure, List<Vendor>>> getVendors();
  Future<Either<Failure, List<User>>> getTechnicians();
  Future<Either<Failure, PaginatedResult<Customer>>> getCustomers({
    String? search,
    int page = 1,
    int limit = 10,
  });

  // Write operations for Area
  Future<Either<Failure, Area>> createArea({
    required String name,
    String? description,
  });
  Future<Either<Failure, Area>> updateArea({
    required int id,
    required String name,
    String? description,
  });
  Future<Either<Failure, void>> deleteArea(int id);

  // Write operations for Customer
  Future<Either<Failure, Customer>> createCustomer({
    required String name,
    String? phone,
    String? address,
    int? areaId,
    int? odpId,
  });
  Future<Either<Failure, Customer>> updateCustomer({
    required int id,
    required String name,
    String? phone,
    String? address,
    int? areaId,
    int? odpId,
  });
  Future<Either<Failure, void>> deleteCustomer(int id);
}
