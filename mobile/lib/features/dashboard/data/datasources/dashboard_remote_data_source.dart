import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/error_mapper.dart';
import '../models/dashboard_models.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardSummaryModel> getSummary();
  Future<List<DashboardAreaModel>> getByArea();
  Future<List<DashboardVendorModel>> getByVendor();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final DioClient dioClient;

  DashboardRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<DashboardSummaryModel> getSummary() async {
    try {
      final response = await dioClient.dio.get('/dashboard/summary');
      final responseData = response.data;

      if (responseData is Map<String, dynamic> &&
          responseData['success'] == true &&
          responseData['data'] is Map<String, dynamic>) {
        return DashboardSummaryModel.fromJson(
          responseData['data'] as Map<String, dynamic>,
        );
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
  Future<List<DashboardAreaModel>> getByArea() async {
    try {
      final response = await dioClient.dio.get('/dashboard/by-area');
      final responseData = response.data;

      if (responseData is Map<String, dynamic> &&
          responseData['success'] == true &&
          responseData['data'] is List) {
        return (responseData['data'] as List)
            .map(
              (item) =>
                  DashboardAreaModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
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
  Future<List<DashboardVendorModel>> getByVendor() async {
    try {
      final response = await dioClient.dio.get('/dashboard/by-vendor');
      final responseData = response.data;

      if (responseData is Map<String, dynamic> &&
          responseData['success'] == true &&
          responseData['data'] is List) {
        return (responseData['data'] as List)
            .map(
              (item) =>
                  DashboardVendorModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
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
}
