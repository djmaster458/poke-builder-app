import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poke_builder/utils/constants.dart';
import '../models/pokemon.dart';
import '../services/pokeapi_service.dart';
import '../services/team_persistence_service.dart';

final pokeApiServiceProvider = Provider<PokeApiService>((ref) {
  return PokeApiService();
});

final teamPersistenceServiceProvider = Provider<TeamPersistenceService>((ref) {
  return TeamPersistenceService();
});

class TeamNotifier extends Notifier<List<Pokemon>> {
  @override
  List<Pokemon> build() {
    return [];
  }

  void addPokemon(Pokemon pokemon) {
    if (state.length < Constants.maxTeamSize) {
      state = [...state, pokemon];
    }
  }

  void removePokemonByIndex(int index) {
    if (index >= 0 && index < state.length) {
      state = [...state.sublist(0, index), ...state.sublist(index + 1)];
    }
  }

  void removePokemonByName(String name) {
    state = state
        .where((p) => p.name.toLowerCase() != name.toLowerCase())
        .toList();
  }

  void setTeam(List<Pokemon> pokemon) {
    if (pokemon.length <= Constants.maxTeamSize) {
      state = [...pokemon];
    }
  }

  void clearTeam() {
    state = [];
  }

  bool isFull() {
    return state.length >= Constants.maxTeamSize;
  }

  bool hasPokemon(String name) {
    return state.any((p) => p.name.toLowerCase() == name.toLowerCase());
  }
}

final teamProvider = NotifierProvider<TeamNotifier, List<Pokemon>>(TeamNotifier.new);

final currentTeamNameProvider = StateProvider<String>((ref) {
  return 'My Team';
});

final savedTeamsProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.watch(teamPersistenceServiceProvider);
  return service.listTeams();
});
