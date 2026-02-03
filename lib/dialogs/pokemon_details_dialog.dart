import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poke_builder/models/pokemon.dart';
import 'package:poke_builder/providers/team_provider.dart';
import 'package:poke_builder/utils/constants.dart';
import 'package:poke_builder/widgets/pokemon_slot.dart';

class PokemonDetailsDialog extends ConsumerWidget {
  const PokemonDetailsDialog({super.key, required this.pokemon});
  final Pokemon pokemon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(teamProvider);
    final teamNotifier = ref.read(teamProvider.notifier);

    return Dialog(
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
              onPressed:
                  teamNotifier.isFull() || teamNotifier.hasPokemon(pokemon.name)
                  ? null
                  : () {
                      teamNotifier.addPokemon(pokemon);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${pokemon.displayName} added to team!',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
              icon: const Icon(Icons.add),
              label: Text(
                team.length >= Constants.maxTeamSize
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
    );
  }
}
