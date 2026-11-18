import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

class GetNotifications {
  final NotificationRepository repository;

  GetNotifications(this.repository);

  Future<Either<Failure, List<AppNotification>>> call() async {
    return await repository.getNotifications();
  }
}
