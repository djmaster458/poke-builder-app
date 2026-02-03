import 'package:flutter/material.dart';

/// Returns a color associated with the given Pokémon type name.
/// If the type name is not recognized, a default grey color is returned.
Color getPokemonTypeColor(String typeName) {
  switch (typeName.toLowerCase()) {
    case 'normal':
      return Colors.brown;
    case 'fire':
      return Colors.red;
    case 'water':
      return Colors.blue;
    case 'electric':
      return Colors.yellow;
    case 'grass':
      return Colors.green;
    case 'ice':
      return Colors.cyan;
    case 'fighting':
      return Colors.orange;
    case 'poison':
      return Colors.purple;
    case 'ground':
      return Colors.brown.shade300;
    case 'flying':
      return Colors.indigo;
    case 'psychic':
      return Colors.pink;
    case 'bug':
      return Colors.lightGreen;
    case 'rock':
      return Colors.grey;
    case 'ghost':
      return Colors.deepPurple;
    case 'dragon':
      return Colors.indigo.shade700;
    case 'dark':
      return Colors.black54;
    case 'steel':
      return Colors.blueGrey;
    case 'fairy':
      return Colors.pinkAccent;
    default:
      return Colors.grey;
  }
}
