import 'package:json_annotation/json_annotation.dart';

part 'pokemon_sprites.g.dart';

@JsonSerializable()
class PokemonSprites {
  @JsonKey(name: 'front_default')
  final String? frontDefault;

  PokemonSprites({this.frontDefault});

  factory PokemonSprites.fromJson(Map<String, dynamic> json) =>
      _$PokemonSpritesFromJson(json);

  Map<String, dynamic> toJson() => _$PokemonSpritesToJson(this);
}
