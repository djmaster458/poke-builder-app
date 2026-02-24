import 'package:flutter/material.dart';
import 'package:poke_builder/utils/utils.dart';
import '../models/pokemon.dart';

/// Widget that displays a Pokémon in a team slot, showing its sprite, name, types, and a remove button if applicable.
/// If no Pokémon is assigned to the slot, it shows a placeholder with an "add" icon.
/// The [onTap] callback is triggered when the slot is tapped, allowing users to select or change the Pokémon.
/// The [onRemove] callback is triggered when the remove button is tapped, allowing users to remove the Pokémon from the team.
/// The [stackFit] parameter allows customization of how the stack's children are sized, defaulting to [StackFit.expand] for full coverage of the slot area.
/// Example usage:
/// ```dart
/// PokemonSlot(
///   pokemon: myPokemon,
///   onTap: () => openPokemonSelection(),
///   onRemove: () => removePokemonFromTeam(),
/// );
/// ```
class PokemonSlot extends StatelessWidget {
  final Pokemon? pokemon;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;
  final StackFit? stackFit;

  /// Creates a [PokemonSlot] widget.
  const PokemonSlot({super.key, this.pokemon, this.onRemove, this.onTap, this.stackFit});

  @override
  Widget build(BuildContext context) {
    if (pokemon == null) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: Center(
            child: Icon(Icons.add, size: 48, color: Colors.grey[400]),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          fit: stackFit ?? StackFit.expand,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (pokemon!.spriteUrl.isNotEmpty)
                  Expanded(
                    flex: 2,
                    child: Image.network(
                      pokemon!.spriteUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error, size: 48);
                      },
                    ),
                  ),

                Text(
                  '#${pokemon!.id.toString().padLeft(3, '0')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    pokemon!.displayName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 4),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    alignment: WrapAlignment.center,
                    children: pokemon!.typeNames.map((typeName) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: getPokemonTypeColor(typeName),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          typeName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),

            // Remove button
            if (onRemove != null)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
