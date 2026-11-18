import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/main_navigation_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/master/presentation/pages/area_list_page.dart';
import '../../features/master/presentation/pages/customer_list_page.dart';
import '../../features/notification/presentation/pages/notification_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/ticket/domain/entities/ticket.dart';
import '../../features/ticket/presentation/pages/ticket_detail_page.dart';
import '../../features/ticket/presentation/pages/ticket_form_page.dart';
import '../../features/ticket/presentation/pages/ticket_list_page.dart';

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isAuthenticated) {
        return isLoggingIn ? null : '/login';
      }

      // Check if user is authenticated but super_admin
      if (authState.user?.role == 'super_admin') {
        return '/login';
      }

      if (isLoggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/',
        builder: (context, state) {
          final authState = authBloc.state;
          return MainNavigationPage(user: authState.user);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationPage(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/master/areas',
        builder: (context, state) => const AreaListPage(),
      ),
      GoRoute(
        path: '/master/customers',
        builder: (context, state) => const CustomerListPage(),
      ),
      GoRoute(
        path: '/tickets',
        builder: (context, state) => const TicketListPage(),
      ),
      GoRoute(
        path: '/tickets/create',
        builder: (context, state) => const TicketFormPage(),
      ),
      GoRoute(
        path: '/tickets/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return TicketDetailPage(ticketId: id);
        },
      ),
      GoRoute(
        path: '/tickets/:id/edit',
        builder: (context, state) {
          final ticket = state.extra as Ticket?;
          return TicketFormPage(ticket: ticket);
        },
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
