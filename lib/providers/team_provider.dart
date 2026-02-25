import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poke_builder/utils/constants.dart';
import '../models/pokemon.dart';
import '../services/pokeapi_service.dart';
import '../services/team_persistence_service.dart';

/// Provider to PokeAPI endpoint
final pokeApiServiceProvider = Provider<PokeApiService>((ref) {
  return PokeApiService();
});

/// Provider to manage saved teams
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

/// Provider to manage the current team state
final teamProvider = NotifierProvider<TeamNotifier, List<Pokemon>>(TeamNotifier.new);

class CurrentTeamNameNotifier extends Notifier<String> {
  @override
  String build() {
    return 'My Team';
  }

  void setTeamName(String name) {
    state = name;
  }
}

/// Provider to manage the current team name being edited/saved
final currentTeamNameProvider = NotifierProvider<CurrentTeamNameNotifier, String>(CurrentTeamNameNotifier.new);

/// Provider to fetch the list of saved team names from persistence
final savedTeamsProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.watch(teamPersistenceServiceProvider);
  return service.listTeams();
});
