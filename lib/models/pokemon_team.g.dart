// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pokemon_team.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PokemonTeam _$PokemonTeamFromJson(Map<String, dynamic> json) => PokemonTeam(
  name: json['name'] as String,
  pokemon: (json['pokemon'] as List<dynamic>)
      .map((e) => Pokemon.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PokemonTeamToJson(PokemonTeam instance) =>
    <String, dynamic>{
      'name': instance.name,
      'pokemon': instance.pokemon,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
