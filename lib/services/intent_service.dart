import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pokemon_team.dart';
import '../providers/team_provider.dart';

class IntentService {
  static const platform = MethodChannel('com.example.poke_builder/intents');
  final WidgetRef ref;

  IntentService(this.ref) {
    _setupMethodCallHandler();
  }

  void _setupMethodCallHandler() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'addPokemon':
          return await _handleAddPokemon(call.arguments);
        case 'removePokemon':
          return await _handleRemovePokemon(call.arguments);
        case 'saveTeam':
          return await _handleSaveTeam(call.arguments);
        case 'clearTeam':
          return await _handleClearTeam();
        default:
          throw PlatformException(
            code: 'UNKNOWN_METHOD',
            message: 'Unknown method: ${call.method}',
          );
      }
    });
  }

  Future<Map<String, dynamic>> _handleAddPokemon(dynamic arguments) async {
    try {
      final name = arguments['name'] as String?;
      if (name == null || name.isEmpty) {
        return {'success': false, 'error': 'Pokemon name is required'};
      }

      final teamNotifier = ref.read(teamProvider.notifier);
      final team = ref.read(teamProvider);

      // Check if team is full
      if (team.length >= 6) {
        return {'success': false, 'error': 'Team is full (6/6 Pokemon)'};
      }

      // Check if Pokemon already exists
      if (teamNotifier.hasPokemon(name)) {
        return {
          'success': false,
          'error': 'Pokemon "$name" is already on the team',
        };
      }

      // Fetch Pokemon from API
      final service = ref.read(pokeApiServiceProvider);
      final pokemon = await service.getPokemon(name);

      if (pokemon == null) {
        return {'success': false, 'error': 'Pokemon "$name" not found'};
      }

      // Add to team
      teamNotifier.addPokemon(pokemon);

      return {
        'success': true,
        'message': 'Pokemon "${pokemon.displayName}" added to team',
        'team_size': team.length + 1,
      };
    } catch (e) {
      return {'success': false, 'error': 'Error adding Pokemon: $e'};
    }
  }

  Future<Map<String, dynamic>> _handleRemovePokemon(dynamic arguments) async {
    try {
      final name = arguments['name'] as String?;
      if (name == null || name.isEmpty) {
        return {'success': false, 'error': 'Pokemon name is required'};
      }

      final teamNotifier = ref.read(teamProvider.notifier);
      final team = ref.read(teamProvider);

      // Check if Pokemon exists on team
      if (!teamNotifier.hasPokemon(name)) {
        return {
          'success': false,
          'error': 'Pokemon "$name" is not on the team',
        };
      }

      // Remove from team
      teamNotifier.removePokemonByName(name);

      return {
        'success': true,
        'message': 'Pokemon "$name" removed from team',
        'team_size': team.length - 1,
      };
    } catch (e) {
      return {'success': false, 'error': 'Error removing Pokemon: $e'};
    }
  }

  Future<Map<String, dynamic>> _handleSaveTeam(dynamic arguments) async {
    try {
      final team = ref.read(teamProvider);

      if (team.isEmpty) {
        return {'success': false, 'error': 'Cannot save empty team'};
      }

      String teamName;
      if (arguments != null && arguments['name'] != null) {
        teamName = arguments['name'] as String;
      } else {
        teamName = ref.read(currentTeamNameProvider);
      }

      final service = ref.read(teamPersistenceServiceProvider);
      final pokemonTeam = PokemonTeam(
        name: teamName,
        pokemon: team,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await service.saveTeam(pokemonTeam);

      // Update current team name
      ref.read(currentTeamNameProvider.notifier).state = teamName;

      return {
        'success': true,
        'message': 'Team "$teamName" saved successfully',
        'team_name': teamName,
        'team_size': team.length,
      };
    } catch (e) {
      return {'success': false, 'error': 'Error saving team: $e'};
    }
  }

  Future<Map<String, dynamic>> _handleClearTeam() async {
    try {
      final team = ref.read(teamProvider);
      final teamSize = team.length;

      ref.read(teamProvider.notifier).clearTeam();

      return {
        'success': true,
        'message': 'Team cleared (removed $teamSize Pokemon)',
        'team_size': 0,
      };
    } catch (e) {
      return {'success': false, 'error': 'Error clearing team: $e'};
    }
  }
}
