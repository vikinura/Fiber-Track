import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/dashboard_data.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardSummary>> getSummary();
  Future<Either<Failure, List<DashboardArea>>> getByArea();
  Future<Either<Failure, List<DashboardVendor>>> getByVendor();
}
