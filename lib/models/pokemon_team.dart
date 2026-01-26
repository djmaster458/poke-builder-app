import 'package:json_annotation/json_annotation.dart';
import 'pokemon.dart';

part 'pokemon_team.g.dart';

@JsonSerializable()
class PokemonTeam {
  final String name;
  final List<Pokemon> pokemon;
  final DateTime createdAt;
  final DateTime updatedAt;

  PokemonTeam({
    required this.name,
    required this.pokemon,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PokemonTeam.fromJson(Map<String, dynamic> json) =>
      _$PokemonTeamFromJson(json);

  Map<String, dynamic> toJson() => _$PokemonTeamToJson(this);

  PokemonTeam copyWith({
    String? name,
    List<Pokemon>? pokemon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PokemonTeam(
      name: name ?? this.name,
      pokemon: pokemon ?? this.pokemon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
