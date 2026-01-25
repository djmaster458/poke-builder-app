# Poke Builder Requirements
## Overview

Poke Builder is your home to building the perfect Pokemon team.
Built upon the [PokeAPI](https://pokeapi.co/), this app allows you to customize your team to become a Pokemon Master.

## App Requirements

### Pokemon Builder
- User interface to build a Pokemon team of up to 6 Pokemon
- Save and load Pokemon teams from local persistent storage

#### Layout
- Should have up to 6 Pokemon slots in a 3 row by 2 column grid
- Each slot should fill left-to-right, top-to-bottom
- Button to save team
- Button to load a team from a list of files in a pop-up

#### Pokemon Slots
- Display the pokemon types
- Display the pokemon number
- Display the pokemon sprite (Front, non-shiny)
- Trash icon to remove from team in top right corner

### Pokemon Search
- Input to lookup a pokemon by name
- Dialog popup with the pokemon slot info
  - Button to add to the team if slot is available
  - Exit button if user declines or doesn't have room to add

## Developer API
- Should be able to use Android Device Bridge and Intents with the pokemon builder to add/remove/save/clear pokemon teams
 - Intent to add a pokemon given a name to the team
 - Intent to remove a pokemon of the given name 

- Should document the intent API and handle cases where the team may be full

## Developer Tools
- Must use the [REST PokeAPI v2](https://pokeapi.co/) for reference. Do not use any existing Flutter/Kotlin packages that use PokeAPI directly.
- May use Flutter [path_provider](https://pub.dev/packages/path_provider) or any other persistence libraries.
- Must use Riverpod or your own state management system. Do not use GetX, BLoC or other system.