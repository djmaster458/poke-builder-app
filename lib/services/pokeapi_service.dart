import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

/// Response model for Pokemon list endpoint
class PokemonListResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<PokemonListItem> results;

  PokemonListResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PokemonListResponse.fromJson(Map<String, dynamic> json) {
    return PokemonListResponse(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List)
          .map((e) => PokemonListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Individual Pokemon item in list response
class PokemonListItem {
  final String name;
  final String url;

  PokemonListItem({
    required this.name,
    required this.url,
  });

  factory PokemonListItem.fromJson(Map<String, dynamic> json) {
    return PokemonListItem(
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }

  /// Extract Pokemon ID from the URL
  int get id {
    final segments = url.split('/');
    return int.parse(segments[segments.length - 2]);
  }
}

class PokeApiService {
  static const String baseUrl = 'https://pokeapi.co/api/v2';
  static const int defaultLimit = 20;

  /// Fetches a Pokemon by [nameOrId], which can be either the Pokemon's name or its ID.
  /// Returns a [Pokemon] object if found
  /// Returns null if the Pokemon is not found
  /// Throws an exception for other errors
  Future<Pokemon?> getPokemon(String nameOrId) async {
    try {
      final uri = Uri.parse('$baseUrl/pokemon/${nameOrId.toLowerCase()}');
      final response = await http.get(uri);

      if (response.statusCode == HttpStatus.ok) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return Pokemon.fromJson(json);
      } else if (response.statusCode == HttpStatus.notFound) {
        return null; // Pokemon not found
      } else {
        throw Exception('Failed to load Pokemon: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching Pokemon: $e');
    }
  }

  /// Fetches a Pokemon by [id]
  /// See [getPokemon] for details
  Future<Pokemon?> getPokemonById(int id) async {
    return getPokemon(id.toString());
  }

  /// Fetches a Pokemon by [name]
  /// See [getPokemon] for details
  Future<Pokemon?> getPokemonByName(String name) async {
    return getPokemon(name);
  }

  /// Fetches a paginated list of Pokemon
  /// [offset] - the starting point in the list (default: 0)
  /// [limit] - number of Pokemon to fetch (default: 20)
  /// Returns a [PokemonListResponse] with pagination information
  Future<PokemonListResponse> getPokemonList({
    int offset = 0,
    int limit = defaultLimit,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/pokemon?offset=$offset&limit=$limit');
      final response = await http.get(uri);

      if (response.statusCode == HttpStatus.ok) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return PokemonListResponse.fromJson(json);
      } else {
        throw Exception('Failed to load Pokemon list: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching Pokemon list: $e');
    }
  }

  /// Fetches all Pokemon (up to 10000)
  /// Returns a list of [PokemonListItem]
  Future<List<PokemonListItem>> fetchAllPokemon() async {
    try {
      final uri = Uri.parse('$baseUrl/pokemon?limit=10000');
      final response = await http.get(uri);

      if (response.statusCode == HttpStatus.ok) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final listResponse = PokemonListResponse.fromJson(json);
        return listResponse.results;
      } else {
        throw Exception('Failed to load all Pokemon: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching all Pokemon: $e');
    }
  }

  /// Searches for Pokemon by name prefix or other [query]
  /// This fetches all Pokemon and filters by name on the client side
  /// For a production app, consider using a dedicated search endpoint
  /// Returns a list of [PokemonListItem] matching the query
  Future<List<PokemonListItem>> searchPokemonByName(String query) async {
    try {
      // Fetch a large list (PokeAPI has ~1000 Pokemon)
      final uri = Uri.parse('$baseUrl/pokemon?limit=10000');
      final response = await http.get(uri);

      if (response.statusCode == HttpStatus.ok) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final listResponse = PokemonListResponse.fromJson(json);

        // Filter by name
        final lowerQuery = query.toLowerCase();
        return listResponse.results
            .where((item) => item.name.contains(lowerQuery))
            .toList();
      } else {
        throw Exception('Failed to search Pokemon: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching Pokemon: $e');
    }
  }
}
