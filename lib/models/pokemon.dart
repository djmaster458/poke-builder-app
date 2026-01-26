import 'package:json_annotation/json_annotation.dart';
import 'pokemon_type.dart';
import 'pokemon_sprites.dart';

part 'pokemon.g.dart';

@JsonSerializable()
class Pokemon {
  final int id;
  final String name;
  final List<PokemonTypeSlot> types;
  final PokemonSprites sprites;

  Pokemon({
    required this.id,
    required this.name,
    required this.types,
    required this.sprites,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) =>
      _$PokemonFromJson(json);

  Map<String, dynamic> toJson() => _$PokemonToJson(this);

  String get displayName =>
      name[0].toUpperCase() + name.substring(1).toLowerCase();

  String get spriteUrl => sprites.frontDefault ?? '';

  List<String> get typeNames => types.map((t) => t.type.name).toList();
}
