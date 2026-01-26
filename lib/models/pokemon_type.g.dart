// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pokemon_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PokemonType _$PokemonTypeFromJson(Map<String, dynamic> json) =>
    PokemonType(name: json['name'] as String, url: json['url'] as String);

Map<String, dynamic> _$PokemonTypeToJson(PokemonType instance) =>
    <String, dynamic>{'name': instance.name, 'url': instance.url};

PokemonTypeSlot _$PokemonTypeSlotFromJson(Map<String, dynamic> json) =>
    PokemonTypeSlot(
      slot: (json['slot'] as num).toInt(),
      type: PokemonType.fromJson(json['type'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PokemonTypeSlotToJson(PokemonTypeSlot instance) =>
    <String, dynamic>{'slot': instance.slot, 'type': instance.type};
