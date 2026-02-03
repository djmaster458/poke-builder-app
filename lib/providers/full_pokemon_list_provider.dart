import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poke_builder/providers/team_provider.dart';
import 'package:poke_builder/services/pokeapi_service.dart';

final fullPokemonListProvider =
    FutureProvider<List<PokemonListItem>>((ref) async {
  final service = ref.watch(pokeApiServiceProvider);
  return service.fetchAllPokemon();
});
