import 'package:json_annotation/json_annotation.dart';

part 'pokemon_type.g.dart';

@JsonSerializable()
class PokemonType {
  final String name;
  final String url;

  PokemonType({required this.name, required this.url});

  factory PokemonType.fromJson(Map<String, dynamic> json) =>
      _$PokemonTypeFromJson(json);

  Map<String, dynamic> toJson() => _$PokemonTypeToJson(this);
}

@JsonSerializable()
class PokemonTypeSlot {
  final int slot;
  final PokemonType type;

  PokemonTypeSlot({required this.slot, required this.type});

  factory PokemonTypeSlot.fromJson(Map<String, dynamic> json) =>
      _$PokemonTypeSlotFromJson(json);

  Map<String, dynamic> toJson() => _$PokemonTypeSlotToJson(this);
}
