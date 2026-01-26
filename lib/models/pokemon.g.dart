// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pokemon.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pokemon _$PokemonFromJson(Map<String, dynamic> json) => Pokemon(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  types: (json['types'] as List<dynamic>)
      .map((e) => PokemonTypeSlot.fromJson(e as Map<String, dynamic>))
      .toList(),
  sprites: PokemonSprites.fromJson(json['sprites'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PokemonToJson(Pokemon instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'types': instance.types,
  'sprites': instance.sprites,
};
