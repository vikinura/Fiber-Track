import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/login.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../network/dio_client.dart';
import '../network/token_storage.dart';
import '../theme/theme_cubit.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // Shared Preferences & ThemeCubit
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  getIt.registerFactory<ThemeCubit>(
    () => ThemeCubit(getIt<SharedPreferences>()),
  );

  // Token Storage & Network
  getIt.registerLazySingleton<TokenStorage>(() => TokenStorage());
  getIt.registerLazySingleton<DioClient>(
    () => DioClient(tokenStorage: getIt<TokenStorage>()),
  );

  // Auth Data Sources
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(tokenStorage: getIt<TokenStorage>()),
  );
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dioClient: getIt<DioClient>()),
  );

  // Auth Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );

  // Auth Use Cases
  getIt.registerLazySingleton<Login>(() => Login(getIt<AuthRepository>()));
  getIt.registerLazySingleton<GetCurrentUser>(
    () => GetCurrentUser(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<Logout>(() => Logout(getIt<AuthRepository>()));

  // Auth Bloc
  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      login: getIt<Login>(),
      getCurrentUser: getIt<GetCurrentUser>(),
      logout: getIt<Logout>(),
    ),
  );
}
