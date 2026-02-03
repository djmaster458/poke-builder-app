import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/pokeapi_service.dart';
import 'team_provider.dart';

class PokemonSearchState {
  final List<PokemonListItem> pokemonList;
  final List<PokemonListItem> filteredList;
  final String searchQuery;
  final bool isSearching;
  final int currentOffset;
  final bool hasMore;

  PokemonSearchState({
    this.pokemonList = const [],
    this.filteredList = const [],
    this.searchQuery = '',
    this.isSearching = false,
    this.currentOffset = 0,
    this.hasMore = true,
  });

  PokemonSearchState copyWith({
    List<PokemonListItem>? pokemonList,
    List<PokemonListItem>? filteredList,
    String? searchQuery,
    bool? isSearching,
    int? currentOffset,
    bool? hasMore,
  }) {
    return PokemonSearchState(
      pokemonList: pokemonList ?? this.pokemonList,
      filteredList: filteredList ?? this.filteredList,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
      currentOffset: currentOffset ?? this.currentOffset,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class PokemonSearchNotifier extends AsyncNotifier<PokemonSearchState> {
  static const int _limit = 20;

  @override
  Future<PokemonSearchState> build() async {
    // Initialize with empty state
    final initialState = PokemonSearchState();

    // Load initial data
    try {
      final service = ref.read(pokeApiServiceProvider);
      final response = await service.getPokemonList(
        offset: 0,
        limit: _limit,
      );

      return PokemonSearchState(
        pokemonList: response.results,
        filteredList: response.results,
        currentOffset: _limit,
        hasMore: response.next != null,
      );
    } catch (e) {
      // Return empty state on error, error will be handled by AsyncValue
      return initialState;
    }
  }

  Future<void> loadMorePokemon() async {
    final currentState = state.valueOrNull;
    if (currentState == null || currentState.isSearching || !currentState.hasMore) {
      return;
    }

    try {
      final service = ref.read(pokeApiServiceProvider);
      final response = await service.getPokemonList(
        offset: currentState.currentOffset,
        limit: _limit,
      );

      final updatedList = [...currentState.pokemonList, ...response.results];
      state = AsyncValue.data(currentState.copyWith(
        pokemonList: updatedList,
        filteredList: updatedList,
        currentOffset: currentState.currentOffset + _limit,
        hasMore: response.next != null,
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> searchPokemon(String query) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    if (query.isEmpty) {
      state = AsyncValue.data(currentState.copyWith(
        isSearching: false,
        filteredList: currentState.pokemonList,
        searchQuery: '',
      ));
      return;
    }

    // Immediately update state to show we're searching
    state = AsyncValue.data(currentState.copyWith(
      isSearching: true,
      searchQuery: query,
    ));

    try {
      final service = ref.read(pokeApiServiceProvider);
      final results = await service.searchPokemonByName(query);

      state = AsyncValue.data(currentState.copyWith(
        filteredList: results,
        searchQuery: query,
        isSearching: true,
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void clearSearch() {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(
      isSearching: false,
      filteredList: currentState.pokemonList,
      searchQuery: '',
    ));
  }
}

final pokemonSearchProvider =
    AsyncNotifierProvider<PokemonSearchNotifier, PokemonSearchState>(() {
  return PokemonSearchNotifier();
});
