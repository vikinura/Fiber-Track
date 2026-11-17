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
import '../../features/master/data/datasources/master_remote_data_source.dart';
import '../../features/master/data/repositories/master_lookup_repository_impl.dart';
import '../../features/master/domain/repositories/master_lookup_repository.dart';
import '../../features/master/domain/usecases/get_areas.dart';
import '../../features/master/domain/usecases/get_customers.dart';
import '../../features/master/domain/usecases/get_issue_types.dart';
import '../../features/master/domain/usecases/get_odps.dart';
import '../../features/master/domain/usecases/get_priorities.dart';
import '../../features/master/domain/usecases/get_technicians.dart';
import '../../features/master/domain/usecases/get_vendors.dart';
import '../../features/ticket/data/datasources/ticket_remote_data_source.dart';
import '../../features/ticket/data/repositories/ticket_repository_impl.dart';
import '../../features/ticket/domain/repositories/ticket_repository.dart';
import '../../features/ticket/domain/usecases/assign_ticket.dart';
import '../../features/ticket/domain/usecases/create_ticket.dart';
import '../../features/ticket/domain/usecases/forward_ticket.dart';
import '../../features/ticket/domain/usecases/get_ticket_detail.dart';
import '../../features/ticket/domain/usecases/get_ticket_histories.dart';
import '../../features/ticket/domain/usecases/get_tickets.dart';
import '../../features/ticket/domain/usecases/update_ticket_status.dart';
import '../../features/ticket/domain/usecases/upload_ticket_photo.dart';
import '../../features/ticket/presentation/bloc/ticket_detail_bloc.dart';
import '../../features/ticket/presentation/bloc/ticket_form_bloc.dart';
import '../../features/ticket/presentation/bloc/ticket_list_bloc.dart';
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

  // Master Data Sources & Repository
  getIt.registerLazySingleton<MasterRemoteDataSource>(
    () => MasterRemoteDataSourceImpl(dioClient: getIt<DioClient>()),
  );
  getIt.registerLazySingleton<MasterLookupRepository>(
    () => MasterLookupRepositoryImpl(
      remoteDataSource: getIt<MasterRemoteDataSource>(),
    ),
  );

  // Master Use Cases
  getIt.registerLazySingleton<GetAreas>(
    () => GetAreas(getIt<MasterLookupRepository>()),
  );
  getIt.registerLazySingleton<GetOdps>(
    () => GetOdps(getIt<MasterLookupRepository>()),
  );
  getIt.registerLazySingleton<GetIssueTypes>(
    () => GetIssueTypes(getIt<MasterLookupRepository>()),
  );
  getIt.registerLazySingleton<GetPriorities>(
    () => GetPriorities(getIt<MasterLookupRepository>()),
  );
  getIt.registerLazySingleton<GetCustomers>(
    () => GetCustomers(getIt<MasterLookupRepository>()),
  );
  getIt.registerLazySingleton<GetVendors>(
    () => GetVendors(getIt<MasterLookupRepository>()),
  );
  getIt.registerLazySingleton<GetTechnicians>(
    () => GetTechnicians(getIt<MasterLookupRepository>()),
  );

  // Ticket Data Sources & Repository
  getIt.registerLazySingleton<TicketRemoteDataSource>(
    () => TicketRemoteDataSourceImpl(dioClient: getIt<DioClient>()),
  );
  getIt.registerLazySingleton<TicketRepository>(
    () =>
        TicketRepositoryImpl(remoteDataSource: getIt<TicketRemoteDataSource>()),
  );

  // Ticket Use Cases
  getIt.registerLazySingleton<GetTickets>(
    () => GetTickets(getIt<TicketRepository>()),
  );
  getIt.registerLazySingleton<GetTicketDetail>(
    () => GetTicketDetail(getIt<TicketRepository>()),
  );
  getIt.registerLazySingleton<GetTicketHistories>(
    () => GetTicketHistories(getIt<TicketRepository>()),
  );
  getIt.registerLazySingleton<CreateTicket>(
    () => CreateTicket(getIt<TicketRepository>()),
  );
  getIt.registerLazySingleton<ForwardTicket>(
    () => ForwardTicket(getIt<TicketRepository>()),
  );
  getIt.registerLazySingleton<AssignTicket>(
    () => AssignTicket(getIt<TicketRepository>()),
  );
  getIt.registerLazySingleton<UpdateTicketStatus>(
    () => UpdateTicketStatus(getIt<TicketRepository>()),
  );
  getIt.registerLazySingleton<UploadTicketPhoto>(
    () => UploadTicketPhoto(getIt<TicketRepository>()),
  );

  // Ticket Blocs
  getIt.registerFactory<TicketListBloc>(
    () => TicketListBloc(getTickets: getIt<GetTickets>()),
  );
  getIt.registerFactory<TicketDetailBloc>(
    () => TicketDetailBloc(
      getTicketDetail: getIt<GetTicketDetail>(),
      getTicketHistories: getIt<GetTicketHistories>(),
      forwardTicket: getIt<ForwardTicket>(),
      assignTicket: getIt<AssignTicket>(),
      updateTicketStatus: getIt<UpdateTicketStatus>(),
      uploadTicketPhoto: getIt<UploadTicketPhoto>(),
    ),
  );
  getIt.registerFactory<TicketFormBloc>(
    () => TicketFormBloc(
      getAreas: getIt<GetAreas>(),
      getOdps: getIt<GetOdps>(),
      getIssueTypes: getIt<GetIssueTypes>(),
      getPriorities: getIt<GetPriorities>(),
      createTicket: getIt<CreateTicket>(),
      ticketRepository: getIt<TicketRepository>(),
    ),
  );
}
