import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter tempRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('Fiber Track Mobile'))),
    ),
  ],
);
