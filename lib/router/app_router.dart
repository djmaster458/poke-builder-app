import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/team_builder_screen.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const TeamBuilderScreen()),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
);
