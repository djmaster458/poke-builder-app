import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:poke_builder/dialogs/clear_team_dialog.dart';
import 'package:poke_builder/utils/constants.dart';
import '../providers/team_provider.dart';
import '../widgets/pokemon_slot.dart';
import '../dialogs/load_team_dialog.dart';
import '../dialogs/save_team_dialog.dart';

class TeamBuilderScreen extends ConsumerWidget {
  const TeamBuilderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(teamProvider);
    final teamName = ref.watch(currentTeamNameProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(teamName),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
            tooltip: 'Search Pokemon',
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: () => _showLoadDialog(context),
            tooltip: 'Load Team',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: team.isEmpty
                ? null
                : () => _showSaveDialog(context),
            tooltip: 'Save Team',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Team grid (3 rows x 2 columns)
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: Constants.maxTeamSize,
                  itemBuilder: (context, index) {
                    final pokemon = index < team.length ? team[index] : null;
                    return PokemonSlot(
                      pokemon: pokemon,
                      onRemove: pokemon != null
                          ? () => _removePokemon(ref, index)
                          : null,
                      onTap: pokemon == null
                          ? () => context.push('/search')
                          : null,
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Team count
              Text(
                '${team.length}/${Constants.maxTeamSize} Pokemon',
                style: Theme.of(context).textTheme.titleMedium,
              ),

              const SizedBox(height: 16),

              // Clear team button
              if (team.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () => _showClearTeamDialog(context),
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear Team'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/search'),
        tooltip: 'Add Pokemon',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showLoadDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const LoadTeamDialog());
  }

  void _showSaveDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const SaveTeamDialog());
  }

  void _removePokemon(WidgetRef ref, int index) {
    ref.read(teamProvider.notifier).removePokemonByIndex(index);
  }

  void _showClearTeamDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ClearTeamDialog(),
    );
  }
}
