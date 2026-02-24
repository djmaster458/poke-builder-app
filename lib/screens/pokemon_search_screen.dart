import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poke_builder/dialogs/pokemon_details_dialog.dart';
import '../models/pokemon.dart';
import '../providers/team_provider.dart';
import '../providers/pokemon_search_provider.dart';
import '../services/pokeapi_service.dart';

class PokemonSearchScreen extends ConsumerStatefulWidget {
  const PokemonSearchScreen({super.key});

  @override
  ConsumerState<PokemonSearchScreen> createState() =>
      _PokemonSearchScreenState();
}

class _PokemonSearchScreenState extends ConsumerState<PokemonSearchScreen> {
  late final TextEditingController _searchController;
  final _scrollController = ScrollController();

  /// Threshold in pixels to trigger loading more Pokemon when scrolling
  static const double _scrollThreshold = 200.0;

  @override
  void initState() {
    super.initState();
    final searchStateAsync = ref.read(pokemonSearchProvider);
    final searchState = searchStateAsync.valueOrNull;

    _searchController = TextEditingController(
      text: searchState?.searchQuery ?? '',
    );

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final searchStateAsync = ref.read(pokemonSearchProvider);
    final searchState = searchStateAsync.valueOrNull;

    if (searchState != null &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - _scrollThreshold) {
      if (searchState.hasMore && !searchState.isSearching) {
        ref.read(pokemonSearchProvider.notifier).loadMorePokemon();
      }
    }
  }

  Future<void> _selectPokemon(PokemonListItem item) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final service = ref.read(pokeApiServiceProvider);
      final pokemon = await service.getPokemon(item.name);

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (pokemon == null) {
        _showMessage('Pokemon not found');
        return;
      }

      _showPokemonDetailsDialog(pokemon);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      _showMessage('Error loading Pokemon: $e');
    }
  }

  void _showPokemonDetailsDialog(Pokemon pokemon) {
    showDialog(
      context: context,
      builder: (context) => PokemonDetailsDialog(pokemon: pokemon),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchStateAsync = ref.watch(pokemonSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Pokemon'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.02,
              vertical: 8.0,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(pokemonSearchProvider.notifier)
                              .clearSearch();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                ref.read(pokemonSearchProvider.notifier).searchPokemon(value);
              },
            ),
          ),
        ),
      ),
      body: searchStateAsync.when(
        data: (searchState) => _buildBody(searchState),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorBody(error.toString()),
      ),
    );
  }

  Widget _buildErrorBody(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(pokemonSearchProvider);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(PokemonSearchState searchState) {
    return Column(
      children: [
        if (searchState.isSearching)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.04,
              vertical: 8,
            ),
            color: Colors.blue.withValues(alpha: 0.1),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16),
                SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                Expanded(
                  child: Text(
                    'Showing ${searchState.filteredList.length} result(s)',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: searchState.filteredList.length,
            itemBuilder: (context, index) {
              final item = searchState.filteredList[index];
              return Card(
                margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.02,
                  vertical: 4,
                ),
                elevation: 2,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.04,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    child: Text(
                      '#${item.id}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  title: Text(
                    item.name[0].toUpperCase() + item.name.substring(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onTap: () => _selectPokemon(item),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
