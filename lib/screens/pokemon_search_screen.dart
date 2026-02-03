import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pokemon.dart';
import '../providers/team_provider.dart';
import '../providers/pokemon_search_provider.dart';
import '../services/pokeapi_service.dart';
import '../widgets/pokemon_slot.dart';

class PokemonSearchScreen extends ConsumerStatefulWidget {
  const PokemonSearchScreen({super.key});

  @override
  ConsumerState<PokemonSearchScreen> createState() =>
      _PokemonSearchScreenState();
}

class _PokemonSearchScreenState extends ConsumerState<PokemonSearchScreen> {
  late final TextEditingController _searchController;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final searchStateAsync = ref.read(pokemonSearchProvider);
    final searchState = searchStateAsync.valueOrNull;
    _searchController = TextEditingController(text: searchState?.searchQuery ?? '');

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
            _scrollController.position.maxScrollExtent - 200) {
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
    final teamNotifier = ref.read(teamProvider.notifier);
    final team = ref.read(teamProvider);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                pokemon.displayName,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),

              // Pokemon preview using PokemonSlot widget
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.25,
                child: PokemonSlot(
                  pokemon: pokemon,
                  // stackFit: StackFit.loose,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),

              // Add to Team button
              ElevatedButton.icon(
                onPressed: teamNotifier.isFull() || teamNotifier.hasPokemon(pokemon.name)
                    ? null
                    : () {
                        teamNotifier.addPokemon(pokemon);
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Go back to team builder
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${pokemon.displayName} added to team!'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                icon: const Icon(Icons.add),
                label: Text(
                  team.length >= 6
                      ? 'Team is Full'
                      : teamNotifier.hasPokemon(pokemon.name)
                          ? 'Already in Team'
                          : 'Add to Team',
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.06,
                    vertical: MediaQuery.of(context).size.height * 0.015,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),

              // Close button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
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
                          ref.read(pokemonSearchProvider.notifier).clearSearch();
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
            color: Colors.blue.withOpacity(0.1),
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
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
