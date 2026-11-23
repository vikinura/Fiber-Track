import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/models/paginated_result.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/error_mapper.dart';
import '../models/ticket_history_model.dart';
import '../models/ticket_model.dart';
import '../models/ticket_photo_model.dart';

abstract class TicketRemoteDataSource {
  Future<PaginatedResult<TicketModel>> getTickets({
    int page = 1,
    int limit = 10,
    String? status,
    int? areaId,
    int? vendorId,
    String? sla,
    String? q,
  });

  Future<TicketModel> getTicketDetail(int id);

  Future<List<TicketHistoryModel>> getTicketHistories(int ticketId);

  Future<TicketModel> createTicket({
    required int customerId,
    required int areaId,
    int? odpId,
    required int issueTypeId,
    required int priorityId,
    required String description,
    double? latitude,
    double? longitude,
  });

  Future<TicketModel> updateTicket({
    required int id,
    required int customerId,
    required int areaId,
    int? odpId,
    required int issueTypeId,
    required int priorityId,
    required String description,
    double? latitude,
    double? longitude,
  });

  Future<TicketModel> forwardTicket(int ticketId, int vendorId);

  Future<TicketModel> assignTicket(int ticketId, int technicianId);

  Future<TicketModel> updateTicketStatus({
    required int ticketId,
    required String toStatus,
    String? note,
  });

  Future<TicketPhotoModel> uploadPhoto({
    required int ticketId,
    required String filePath,
    String? caption,
  });
}

class TicketRemoteDataSourceImpl implements TicketRemoteDataSource {
  final DioClient dioClient;

  TicketRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<PaginatedResult<TicketModel>> getTickets({
    int page = 1,
    int limit = 10,
    String? status,
    int? areaId,
    int? vendorId,
    String? sla,
    String? q,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (areaId != null) queryParams['area_id'] = areaId;
      if (vendorId != null) queryParams['vendor_id'] = vendorId;
      if (sla != null && sla.isNotEmpty) queryParams['sla'] = sla;
      if (q != null && q.trim().isNotEmpty) queryParams['q'] = q.trim();

      final response = await dioClient.dio.get(
        '/tickets',
        queryParameters: queryParams,
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData['success'] == true &&
          responseData['data'] is List) {
        final data = (responseData['data'] as List)
            .map((item) => TicketModel.fromJson(item as Map<String, dynamic>))
            .toList();
        final meta = responseData['meta'] as Map<String, dynamic>? ?? {};
        final total = meta['total'] is int
            ? meta['total'] as int
            : int.tryParse(meta['total']?.toString() ?? '0') ?? data.length;

        return PaginatedResult<TicketModel>(
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
  Future<TicketModel> getTicketDetail(int id) async {
    try {
      final response = await dioClient.dio.get('/tickets/$id');
      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData['success'] == true &&
          responseData['data'] is Map<String, dynamic>) {
        return TicketModel.fromJson(
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
  Future<List<TicketHistoryModel>> getTicketHistories(int ticketId) async {
    try {
      final response = await dioClient.dio.get('/tickets/$ticketId/histories');
      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData['success'] == true &&
          responseData['data'] is List) {
        return (responseData['data'] as List)
            .map(
              (item) =>
                  TicketHistoryModel.fromJson(item as Map<String, dynamic>),
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
  Future<TicketModel> createTicket({
    required int customerId,
    required int areaId,
    int? odpId,
    required int issueTypeId,
    required int priorityId,
    required String description,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final payload = <String, dynamic>{
        'customer_id': customerId,
        'area_id': areaId,
        'odp_id': odpId,
        'issue_type_id': issueTypeId,
        'priority_id': priorityId,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
      };

      final response = await dioClient.dio.post('/tickets', data: payload);

      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData['success'] == true &&
          responseData['data'] is Map<String, dynamic>) {
        return TicketModel.fromJson(
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
  Future<TicketModel> updateTicket({
    required int id,
    required int customerId,
    required int areaId,
    int? odpId,
    required int issueTypeId,
    required int priorityId,
    required String description,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final payload = <String, dynamic>{
        'customer_id': customerId,
        'area_id': areaId,
        'odp_id': odpId,
        'issue_type_id': issueTypeId,
        'priority_id': priorityId,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
      };

      final response = await dioClient.dio.put('/tickets/$id', data: payload);

      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData['success'] == true &&
          responseData['data'] is Map<String, dynamic>) {
        return TicketModel.fromJson(
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
  Future<TicketModel> forwardTicket(int ticketId, int vendorId) async {
    try {
      final response = await dioClient.dio.patch(
        '/tickets/$ticketId/forward',
        data: {'vendor_id': vendorId},
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData['success'] == true &&
          responseData['data'] is Map<String, dynamic>) {
        return TicketModel.fromJson(
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
  Future<TicketModel> assignTicket(int ticketId, int technicianId) async {
    try {
      final response = await dioClient.dio.patch(
        '/tickets/$ticketId/assign',
        data: {'technician_id': technicianId},
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData['success'] == true &&
          responseData['data'] is Map<String, dynamic>) {
        return TicketModel.fromJson(
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
  Future<TicketModel> updateTicketStatus({
    required int ticketId,
    required String toStatus,
    String? note,
  }) async {
    try {
      final payload = <String, dynamic>{'to_status': toStatus};
      if (note != null && note.trim().isNotEmpty) {
        payload['note'] = note.trim();
      }

      final response = await dioClient.dio.patch(
        '/tickets/$ticketId/status',
        data: payload,
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData['success'] == true &&
          responseData['data'] is Map<String, dynamic>) {
        return TicketModel.fromJson(
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
  Future<TicketPhotoModel> uploadPhoto({
    required int ticketId,
    required String filePath,
    String? caption,
  }) async {
    try {
      final fileName = filePath.split(RegExp(r'[/\\]')).last;
      final MultipartFile multipartFile;

      if (kIsWeb) {
        final xFile = XFile(filePath);
        final bytes = await xFile.readAsBytes();
        multipartFile = MultipartFile.fromBytes(
          bytes,
          filename: fileName.isNotEmpty ? fileName : 'upload.jpg',
        );
      } else {
        multipartFile = await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        );
      }

      final formData = FormData.fromMap({
        'photo': multipartFile,
        if (caption != null && caption.trim().isNotEmpty)
          'caption': caption.trim(),
      });

      final response = await dioClient.dio.post(
        '/tickets/$ticketId/photos',
        data: formData,
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData['success'] == true &&
          responseData['data'] is Map<String, dynamic>) {
        return TicketPhotoModel.fromJson(
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
}
