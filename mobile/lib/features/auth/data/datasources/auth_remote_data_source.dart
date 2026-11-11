import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/error_mapper.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<({String token, UserModel user})> login({
    required String email,
    required String password,
  });

  Future<UserModel> getMe();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<({String token, UserModel user})> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dioClient.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData['success'] == true &&
          responseData['data'] != null) {
        final data = responseData['data'] as Map<String, dynamic>;
        final token = data['token'] as String;
        final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
        return (token: token, user: user);
      } else {
        throw const ServerException(message: 'Format respons tidak valid');
      }
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
  Future<UserModel> getMe() async {
    try {
      final response = await dioClient.dio.get('/auth/me');

      final responseData = response.data;
      if (responseData is Map<String, dynamic> &&
          responseData['success'] == true &&
          responseData['data'] != null) {
        return UserModel.fromJson(responseData['data'] as Map<String, dynamic>);
      } else {
        throw const ServerException(message: 'Format respons tidak valid');
      }
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
