import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poke_builder/providers/full_pokemon_list_provider.dart';
import 'router/app_router.dart';

void main() {
  runApp(const ProviderScope(child: _EagerInitialization(child: MyApp())));
}

/// Wraps the app with a provider that eagerly loads the full Pokémon list on startup.
/// Allows us to use requireValue and the full pokemon list synchronously in the search screen 
/// without needing to handle loading states there.
class _EagerInitialization extends ConsumerWidget {
  const _EagerInitialization({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(fullPokemonListProvider);

    if (result.isLoading) {
      return const CircularProgressIndicator();
    } else if (result.hasError) {
      return Center(child: Text('Error loading Pokémon: ${result.error}'));
    }

    return child;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Poke Builder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      routerConfig: goRouter,
    );
  }
}
