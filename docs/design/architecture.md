# Poke Builder Architecture

## Overview

Poke Builder is a Flutter application that allows users to build and manage Pokemon teams. The app uses a clean architecture approach with separation of concerns across different layers.

## Technology Stack

- **Framework**: Flutter
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **HTTP Client**: http package
- **Persistence**: path_provider
- **JSON Serialization**: json_serializable + build_runner
- **API**: PokeAPI v2 REST API

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   ├── pokemon.dart
│   ├── pokemon_sprites.dart
│   ├── pokemon_team.dart
│   └── pokemon_type.dart
├── providers/                   # Riverpod state providers
│   └── team_provider.dart
├── services/                    # Business logic & external services
│   ├── pokeapi_service.dart
│   ├── team_persistence_service.dart
│   └── intent_service.dart
├── screens/                     # Main app screens
│   └── team_builder_screen.dart
├── widgets/                     # Reusable UI components
│   └── pokemon_slot.dart
├── dialogs/                     # Dialog widgets
│   ├── pokemon_search_dialog.dart
│   ├── save_team_dialog.dart
│   └── load_team_dialog.dart
└── router/                      # Navigation configuration
    └── app_router.dart
```

## Architecture Layers

### 1. Models Layer

Data models representing Pokemon and teams with JSON serialization support:

- **Pokemon**: Represents a Pokemon with id, name, types, and sprites
- **PokemonType**: Type information (fire, water, etc.)
- **PokemonSprites**: Sprite URLs for Pokemon images
- **PokemonTeam**: Collection of Pokemon with metadata

All models use `json_serializable` for automatic JSON encoding/decoding.

### 2. Services Layer

Business logic and external integrations:

- **PokeApiService**: Handles HTTP requests to PokeAPI v2
  - Fetches Pokemon by name or ID
  - Returns null for not found Pokemon
  - Throws exceptions on errors

- **TeamPersistenceService**: Manages local storage of teams
  - Saves/loads teams as JSON files
  - Lists all saved teams
  - Deletes teams

- **IntentService**: Handles Android platform channel communication
  - Processes incoming intents from ADB/other apps
  - Manages team operations via method channels

### 3. Providers Layer (State Management)

Riverpod providers for state management:

- **pokeApiServiceProvider**: Singleton service provider
- **teamPersistenceServiceProvider**: Singleton service provider
- **teamProvider**: State notifier for current team (List<Pokemon>)
- **currentTeamNameProvider**: State for current team name
- **savedTeamsProvider**: Async provider for list of saved teams

The `TeamNotifier` class manages team state with methods:
- `addPokemon()`: Add to team (max 6)
- `removePokemon()`: Remove by index
- `removePokemonByName()`: Remove by name
- `setTeam()`: Replace entire team
- `clearTeam()`: Remove all Pokemon
- `isFull()`: Check if team has 6 Pokemon
- `hasPokemon()`: Check if Pokemon exists on team

### 4. UI Layer

#### Screens
- **TeamBuilderScreen**: Main screen with 3x2 grid of Pokemon slots
  - Shows team composition
  - Save/load/clear team actions
  - Search for Pokemon

#### Widgets
- **PokemonSlot**: Reusable widget for displaying Pokemon
  - Shows sprite, number, name, types
  - Color-coded type badges
  - Delete button
  - Empty state for adding

#### Dialogs
- **PokemonSearchDialog**: Search and add Pokemon to team
  - Text input for name/ID search
  - Preview before adding
  - Validates team capacity

- **SaveTeamDialog**: Save current team
  - Input team name
  - Handles save errors

- **LoadTeamDialog**: Load or delete saved teams
  - Lists all saved teams
  - Load team action
  - Delete team action with confirmation

### 5. Navigation Layer

Uses GoRouter for declarative routing:
- Single route (`/`) to TeamBuilderScreen
- Error handling for invalid routes
- Material page transitions

## Data Flow

### Adding a Pokemon
1. User searches via PokemonSearchDialog
2. Dialog calls PokeApiService to fetch Pokemon
3. On success, Pokemon added to teamProvider
4. TeamNotifier updates state
5. UI rebuilds with ConsumerWidget watching teamProvider

### Saving a Team
1. User clicks save button
2. SaveTeamDialog captures team name
3. Creates PokemonTeam with current date/time
4. TeamPersistenceService saves to local JSON file
5. savedTeamsProvider invalidated to refresh list

### Loading a Team
1. User opens LoadTeamDialog
2. Dialog shows savedTeamsProvider data
3. User selects team
4. TeamPersistenceService loads JSON file
5. teamProvider updated with loaded Pokemon
6. UI rebuilds with new team

### Intent Handling (Android)
1. External app/ADB sends broadcast
2. PokemonBroadcastReceiver receives broadcast (only if app is running)
3. Broadcast action mapped to method channel call
4. IntentService receives method call
5. Operates on teamProvider via ref
6. Returns success/error response

## Android Integration

### Platform Channel
- Channel name: `com.example.poke_builder/intents`
- Bidirectional communication between Kotlin and Dart
- Method calls: `addPokemon`, `removePokemon`, `saveTeam`, `clearTeam`

### Broadcast Receiver
- Registered in MainActivity when app starts
- Unregistered when app is destroyed
- Only receives broadcasts while app is running
- Actions:
  - `com.example.poke_builder.ADD_POKEMON`
  - `com.example.poke_builder.REMOVE_POKEMON`
  - `com.example.poke_builder.SAVE_TEAM`
  - `com.example.poke_builder.CLEAR_TEAM`

See [INTENT_API.md](../INTENT_API.md) for detailed usage.

## State Management Philosophy

Using Riverpod for:
- **Dependency Injection**: Services provided via providers
- **State Observation**: UI rebuilds on state changes
- **Testing**: Easy to mock providers
- **Compile Safety**: Type-safe state access

## Design Patterns

- **Repository Pattern**: Services abstract data sources
- **Provider Pattern**: Riverpod for dependency injection
- **Observer Pattern**: Widgets watch provider state
- **Command Pattern**: Intent handling maps actions to operations

## Error Handling

- Network errors: Try-catch in service layer, return null or throw
- File I/O errors: Exceptions with descriptive messages
- UI errors: SnackBars and error dialogs
- Intent errors: Return error response maps

## Future Enhancements

Potential improvements:
- Add team battle simulator
- Pokemon move/ability details
- Advanced search filters
- Team sharing via QR codes
- Statistics and type coverage analysis
- iOS support for intents (URL schemes)
