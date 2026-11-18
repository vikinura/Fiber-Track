import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/models/paginated_result.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/error_mapper.dart';
import '../models/area_model.dart';
import '../models/customer_model.dart';
import '../models/issue_type_model.dart';
import '../models/odp_model.dart';
import '../models/priority_model.dart';
import '../models/vendor_model.dart';
import '../../../auth/data/models/user_model.dart';

abstract class MasterRemoteDataSource {
  Future<List<AreaModel>> getAreas();
  Future<List<OdpModel>> getOdps({int? areaId});
  Future<List<IssueTypeModel>> getIssueTypes();
  Future<List<PriorityModel>> getPriorities();
  Future<List<VendorModel>> getVendors();
  Future<List<UserModel>> getTechnicians();
  Future<PaginatedResult<CustomerModel>> getCustomers({
    String? search,
    int page = 1,
    int limit = 10,
  });

  // Area write operations
  Future<AreaModel> createArea({required String name, String? description});
  Future<AreaModel> updateArea({
    required int id,
    required String name,
    String? description,
  });
  Future<void> deleteArea(int id);

  // Customer write operations
  Future<CustomerModel> createCustomer({
    required String name,
    String? phone,
    String? address,
    int? areaId,
    int? odpId,
  });
  Future<CustomerModel> updateCustomer({
    required int id,
    required String name,
    String? phone,
    String? address,
    int? areaId,
    int? odpId,
  });
  Future<void> deleteCustomer(int id);
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

  @override
  Future<List<VendorModel>> getVendors() async {
    try {
      final response = await dioClient.dio.get('/vendors');
      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData['success'] == true &&
          responseData['data'] is List) {
        return (responseData['data'] as List)
            .map((item) => VendorModel.fromJson(item as Map<String, dynamic>))
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
  Future<List<UserModel>> getTechnicians() async {
    try {
      final response = await dioClient.dio.get(
        '/users',
        queryParameters: {'role': 'technician'},
      );
      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData['success'] == true &&
          responseData['data'] is List) {
        return (responseData['data'] as List)
            .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
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
  Future<PaginatedResult<CustomerModel>> getCustomers({
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final response = await dioClient.dio.get(
        '/customers',
        queryParameters: queryParams,
      );
      final responseData = response.data;

      if (responseData is Map<String, dynamic> &&
          responseData['success'] == true &&
          responseData['data'] is List) {
        final data = (responseData['data'] as List)
            .map((item) => CustomerModel.fromJson(item as Map<String, dynamic>))
            .toList();
        final meta = responseData['meta'] as Map<String, dynamic>? ?? {};
        final total = meta['total'] is int
            ? meta['total'] as int
            : int.tryParse(meta['total']?.toString() ?? '0') ?? data.length;

        return PaginatedResult<CustomerModel>(
          data: data,
          page: page,
          limit: limit,
          total: total,
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
  Future<AreaModel> createArea({
    required String name,
    String? description,
  }) async {
    try {
      final response = await dioClient.dio.post(
        '/areas',
        data: {
          'name': name,
          ...?description != null ? {'description': description} : null,
        },
      );
      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData['success'] == true &&
          responseData['data'] is Map<String, dynamic>) {
        return AreaModel.fromJson(responseData['data'] as Map<String, dynamic>);
      }
      throw const ServerException(message: 'Format respons tidak valid');
    } on DioException catch (e) {
      throw mapDioErrorToException(e);
    }
  }

  @override
  Future<AreaModel> updateArea({
    required int id,
    required String name,
    String? description,
  }) async {
    try {
      final response = await dioClient.dio.put(
        '/areas/$id',
        data: {
          'name': name,
          ...?description != null ? {'description': description} : null,
        },
      );
      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData['success'] == true &&
          responseData['data'] is Map<String, dynamic>) {
        return AreaModel.fromJson(responseData['data'] as Map<String, dynamic>);
      }
      throw const ServerException(message: 'Format respons tidak valid');
    } on DioException catch (e) {
      throw mapDioErrorToException(e);
    }
  }

  @override
  Future<void> deleteArea(int id) async {
    try {
      await dioClient.dio.delete('/areas/$id');
    } on DioException catch (e) {
      throw mapDioErrorToException(e);
    }
  }

  @override
  Future<CustomerModel> createCustomer({
    required String name,
    String? phone,
    String? address,
    int? areaId,
    int? odpId,
  }) async {
    try {
      final response = await dioClient.dio.post(
        '/customers',
        data: {
          'name': name,
          ...?phone != null ? {'phone': phone} : null,
          ...?address != null ? {'address': address} : null,
          ...?areaId != null ? {'area_id': areaId} : null,
          ...?odpId != null ? {'odp_id': odpId} : null,
        },
      );
      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData['success'] == true &&
          responseData['data'] is Map<String, dynamic>) {
        return CustomerModel.fromJson(
          responseData['data'] as Map<String, dynamic>,
        );
      }
      throw const ServerException(message: 'Format respons tidak valid');
    } on DioException catch (e) {
      throw mapDioErrorToException(e);
    }
  }

  @override
  Future<CustomerModel> updateCustomer({
    required int id,
    required String name,
    String? phone,
    String? address,
    int? areaId,
    int? odpId,
  }) async {
    try {
      final response = await dioClient.dio.put(
        '/customers/$id',
        data: {
          'name': name,
          ...?phone != null ? {'phone': phone} : null,
          ...?address != null ? {'address': address} : null,
          ...?areaId != null ? {'area_id': areaId} : null,
          ...?odpId != null ? {'odp_id': odpId} : null,
        },
      );
      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData['success'] == true &&
          responseData['data'] is Map<String, dynamic>) {
        return CustomerModel.fromJson(
          responseData['data'] as Map<String, dynamic>,
        );
      }
      throw const ServerException(message: 'Format respons tidak valid');
    } on DioException catch (e) {
      throw mapDioErrorToException(e);
    }
  }

  @override
  Future<void> deleteCustomer(int id) async {
    try {
      await dioClient.dio.delete('/customers/$id');
    } on DioException catch (e) {
      throw mapDioErrorToException(e);
    }
  }
}
