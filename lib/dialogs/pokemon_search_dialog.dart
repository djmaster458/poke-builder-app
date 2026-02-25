import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pokemon.dart';
import '../providers/team_provider.dart';
import '../widgets/pokemon_slot.dart';

class PokemonSearchDialog extends ConsumerStatefulWidget {
  const PokemonSearchDialog({super.key});

  @override
  ConsumerState<PokemonSearchDialog> createState() =>
      _PokemonSearchDialogState();
}

class _PokemonSearchDialogState extends ConsumerState<PokemonSearchDialog> {
  final _controller = TextEditingController();
  Pokemon? _searchedPokemon;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _searchPokemon() async {
    final searchTerm = _controller.text.trim();
    if (searchTerm.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _searchedPokemon = null;
    });

    try {
      final service = ref.read(pokeApiServiceProvider);
      final pokemon = await service.getPokemon(searchTerm);

      if (mounted) {
        setState(() {
          if (pokemon != null) {
            _searchedPokemon = pokemon;
          } else {
            _errorMessage = 'Pokemon not found';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _addToTeam() {
    if (_searchedPokemon == null) return;

    final teamNotifier = ref.read(teamProvider.notifier);
    final team = ref.read(teamProvider);

    if (team.length >= 6) {
      _showMessage('Team is full! Remove a Pokemon first.');
      return;
    }

    if (teamNotifier.hasPokemon(_searchedPokemon!.name)) {
      _showMessage('${_searchedPokemon!.displayName} is already on your team!');
      return;
    }

    teamNotifier.addPokemon(_searchedPokemon!);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_searchedPokemon!.displayName} added to team!'),
        duration: const Duration(seconds: 2),
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
    final team = ref.watch(teamProvider);
    final canAdd = team.length < 6;

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Search Pokemon',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Pokemon name or ID',
                hintText: 'e.g., pikachu or 25',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchPokemon,
                ),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _searchPokemon(),
            ),

            const SizedBox(height: 16),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),

            if (_errorMessage != null && !_isLoading)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red[700], fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),

            if (_searchedPokemon != null && !_isLoading)
              Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: PokemonSlot(
                      pokemon: _searchedPokemon,
                      stackFit: StackFit.loose,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    onPressed: canAdd ? _addToTeam : null,
                    icon: const Icon(Icons.add),
                    label: Text(canAdd ? 'Add to Team' : 'Team is Full'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 8),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
