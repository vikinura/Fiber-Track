import '../../../../core/network/token_storage.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
  Future<bool> hasToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final TokenStorage tokenStorage;

  AuthLocalDataSourceImpl({required this.tokenStorage});

  @override
  Future<void> saveToken(String token) => tokenStorage.saveToken(token);

  @override
  Future<String?> getToken() => tokenStorage.getToken();

  @override
  Future<void> clearToken() => tokenStorage.clearToken();

  @override
  Future<bool> hasToken() => tokenStorage.hasToken();
}
