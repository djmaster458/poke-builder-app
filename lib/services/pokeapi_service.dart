import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokeApiService {
  static const String baseUrl = 'https://pokeapi.co/api/v2';

  /// Fetches a Pokemon by name or ID
  Future<Pokemon?> getPokemon(String nameOrId) async {
    try {
      final uri = Uri.parse('$baseUrl/pokemon/${nameOrId.toLowerCase()}');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return Pokemon.fromJson(json);
      } else if (response.statusCode == 404) {
        return null; // Pokemon not found
      } else {
        throw Exception('Failed to load Pokemon: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching Pokemon: $e');
    }
  }

  /// Fetches a Pokemon by ID
  Future<Pokemon?> getPokemonById(int id) async {
    return getPokemon(id.toString());
  }

  /// Fetches a Pokemon by name
  Future<Pokemon?> getPokemonByName(String name) async {
    return getPokemon(name);
  }
}
