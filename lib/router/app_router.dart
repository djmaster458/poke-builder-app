import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/team_builder_screen.dart';
import '../screens/pokemon_search_screen.dart';

/// Main app router
final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const TeamBuilderScreen()),
    GoRoute(
      path: '/search',
      builder: (context, state) => const PokemonSearchScreen(),
    ),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
);
