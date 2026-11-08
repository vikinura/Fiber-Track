import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
}
