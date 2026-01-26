import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pokemon.dart';
import '../services/pokeapi_service.dart';
import '../services/team_persistence_service.dart';

// Service providers
final pokeApiServiceProvider = Provider<PokeApiService>((ref) {
  return PokeApiService();
});

final teamPersistenceServiceProvider = Provider<TeamPersistenceService>((ref) {
  return TeamPersistenceService();
});

// Team state provider
class TeamNotifier extends StateNotifier<List<Pokemon>> {
  TeamNotifier() : super([]);

  void addPokemon(Pokemon pokemon) {
    if (state.length < 6) {
      state = [...state, pokemon];
    }
  }

  void removePokemon(int index) {
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
    if (pokemon.length <= 6) {
      state = [...pokemon];
    }
  }

  void clearTeam() {
    state = [];
  }

  bool isFull() {
    return state.length >= 6;
  }

  bool hasPokemon(String name) {
    return state.any((p) => p.name.toLowerCase() == name.toLowerCase());
  }
}

final teamProvider = StateNotifierProvider<TeamNotifier, List<Pokemon>>((ref) {
  return TeamNotifier();
});

// Current team name provider
final currentTeamNameProvider = StateProvider<String>((ref) {
  return 'My Team';
});

// Saved teams list provider
final savedTeamsProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.watch(teamPersistenceServiceProvider);
  return service.listTeams();
});
