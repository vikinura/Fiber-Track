import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/error_mapper.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<Map<String, dynamic>> getNotifications();
  Future<void> markAsRead(int id);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final DioClient dioClient;

  NotificationRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<Map<String, dynamic>> getNotifications() async {
    try {
      final response = await dioClient.dio.get('/notifications');
      final responseData = response.data;

      if (responseData is Map<String, dynamic> &&
          responseData['success'] == true &&
          responseData['data'] is Map<String, dynamic>) {
        final data = responseData['data'] as Map<String, dynamic>;
        final rawList = data['notifications'] as List<dynamic>? ?? [];
        final notifications = rawList
            .map(
              (item) =>
                  NotificationModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
        final unreadCount = data['unread_count'] as int? ?? 0;

        return {'notifications': notifications, 'unread_count': unreadCount};
      }
      throw const ServerException(message: 'Format respons tidak valid');
    } on DioException catch (e) {
      throw mapDioErrorToException(e);
    } catch (e) {
      if (e is ServerException ||
          e is UnauthorizedException ||
          e is ValidationException ||
          e is NetworkException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> markAsRead(int id) async {
    try {
      final response = await dioClient.dio.patch('/notifications/$id/read');
      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        return;
      }
      throw const ServerException(message: 'Gagal menandai notifikasi');
    } on DioException catch (e) {
      throw mapDioErrorToException(e);
    } catch (e) {
      if (e is ServerException ||
          e is UnauthorizedException ||
          e is ValidationException ||
          e is NetworkException) {
        rethrow;
      }
      throw ServerException(message: e.toString());
    }
  }
}
