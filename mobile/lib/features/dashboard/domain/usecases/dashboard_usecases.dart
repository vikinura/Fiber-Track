import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/dashboard_data.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardSummary {
  final DashboardRepository repository;

  GetDashboardSummary(this.repository);

  Future<Either<Failure, DashboardSummary>> call() async {
    return await repository.getSummary();
  }
}

class GetDashboardByArea {
  final DashboardRepository repository;

  GetDashboardByArea(this.repository);

  Future<Either<Failure, List<DashboardArea>>> call() async {
    return await repository.getByArea();
  }
}

class GetDashboardByVendor {
  final DashboardRepository repository;

  GetDashboardByVendor(this.repository);

  Future<Either<Failure, List<DashboardVendor>>> call() async {
    return await repository.getByVendor();
  }
}
