import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/error_mapper.dart';
import '../models/area_model.dart';
import '../models/issue_type_model.dart';
import '../models/odp_model.dart';
import '../models/priority_model.dart';

abstract class MasterRemoteDataSource {
  Future<List<AreaModel>> getAreas();
  Future<List<OdpModel>> getOdps({int? areaId});
  Future<List<IssueTypeModel>> getIssueTypes();
  Future<List<PriorityModel>> getPriorities();
}

class MasterRemoteDataSourceImpl implements MasterRemoteDataSource {
  final DioClient dioClient;

  MasterRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<AreaModel>> getAreas() async {
    try {
      final response = await dioClient.dio.get('/areas');
      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData['success'] == true &&
          responseData['data'] is List) {
        return (responseData['data'] as List)
            .map((item) => AreaModel.fromJson(item as Map<String, dynamic>))
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
  Future<List<OdpModel>> getOdps({int? areaId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (areaId != null) {
        queryParams['area_id'] = areaId;
      }

      final response = await dioClient.dio.get(
        '/odps',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData['success'] == true &&
          responseData['data'] is List) {
        return (responseData['data'] as List)
            .map((item) => OdpModel.fromJson(item as Map<String, dynamic>))
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
  Future<List<IssueTypeModel>> getIssueTypes() async {
    try {
      final response = await dioClient.dio.get('/issue-types');
      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData['success'] == true &&
          responseData['data'] is List) {
        return (responseData['data'] as List)
            .map(
              (item) => IssueTypeModel.fromJson(item as Map<String, dynamic>),
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
  Future<List<PriorityModel>> getPriorities() async {
    try {
      final response = await dioClient.dio.get('/priorities');
      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData['success'] == true &&
          responseData['data'] is List) {
        return (responseData['data'] as List)
            .map((item) => PriorityModel.fromJson(item as Map<String, dynamic>))
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
