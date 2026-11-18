import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/notification.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<AppNotification>>> getNotifications();
  Future<Either<Failure, int>> getUnreadCount();
  Future<Either<Failure, void>> markAsRead(int id);
}
