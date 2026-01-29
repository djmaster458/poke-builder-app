import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/pokemon_team.dart';

class TeamPersistenceService {
  static const String _teamsDirectory = 'teams';

  /// Gets the directory where teams are stored
  Future<Directory> _getTeamsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final teamsDir = Directory('${appDir.path}/$_teamsDirectory');
    if (!await teamsDir.exists()) {
      await teamsDir.create(recursive: true);
    }
    return teamsDir;
  }

  /// Saves a team to a file
  /// Throws an exception if saving fails
  Future<void> saveTeam(PokemonTeam team) async {
    try {
      final dir = await _getTeamsDirectory();
      final file = File('${dir.path}/${_sanitizeFileName(team.name)}.json');
      final jsonString = jsonEncode(team.toJson());
      await file.writeAsString(jsonString);
    } catch (e) {
      throw Exception('Failed to save team: $e');
    }
  }

  /// Loads a team from a file by name
  /// Throws an exception if loading fails
  Future<PokemonTeam?> loadTeam(String teamName) async {
    try {
      final dir = await _getTeamsDirectory();
      final file = File('${dir.path}/${_sanitizeFileName(teamName)}.json');
      if (!await file.exists()) {
        return null;
      }
      final jsonString = await file.readAsString();
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return PokemonTeam.fromJson(json);
    } catch (e) {
      throw Exception('Failed to load team: $e');
    }
  }

  /// Lists all saved teams
  /// Throws an exception if listing fails
  Future<List<String>> listTeams() async {
    try {
      final dir = await _getTeamsDirectory();
      final files = await dir.list().toList();
      return files
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .map((file) {
            final fileName = file.path.split('/').last;
            return fileName.substring(0, fileName.length - 5); // Remove .json
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to list teams: $e');
    }
  }

  /// Deletes a team file
  /// Throws an exception if deleting fails
  Future<void> deleteTeam(String teamName) async {
    try {
      final dir = await _getTeamsDirectory();
      final file = File('${dir.path}/${_sanitizeFileName(teamName)}.json');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete team: $e');
    }
  }

  /// Sanitizes a file name by removing invalid characters
  String _sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
  }
}
