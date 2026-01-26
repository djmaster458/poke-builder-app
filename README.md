# Poke Builder

Your home to building the perfect Pokemon team! Built with Flutter and powered by [PokeAPI](https://pokeapi.co/).

## Features

- 🎮 Build Pokemon teams of up to 6 Pokemon
- 🔍 Search for Pokemon by name or ID
- 💾 Save and load teams locally
- 📱 Android intent support for external integrations
- 🎨 Beautiful UI with type-colored badges
- 🖼️ Official Pokemon sprites from PokeAPI

## Screenshots

The app features a 3x2 grid layout for your Pokemon team, with each slot displaying:
- Pokemon sprite (front, non-shiny)
- Pokemon number
- Pokemon name
- Type badges with color coding
- Remove button

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.10.7 or higher)
- Android Studio or Xcode (for running on emulators/devices)
- An internet connection (for fetching Pokemon data)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/poke_builder.git
cd poke_builder
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate JSON serialization code:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Running the App

#### On Android/iOS
```bash
flutter run
```

#### On Web
```bash
flutter run -d chrome
```

#### On specific device
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

## Usage

### Building a Team

1. Tap on any empty slot or the floating action button to search for Pokemon
2. Enter a Pokemon name (e.g., "pikachu") or ID (e.g., "25")
3. Click "Add to Team" to add the Pokemon
4. Repeat until you have your dream team (max 6)

### Saving a Team

1. Click the save icon in the app bar
2. Enter a team name
3. Click "Save"

### Loading a Team

1. Click the folder icon in the app bar
2. Select a saved team from the list
3. Your current team will be replaced with the loaded team

### Clearing a Team

Click the "Clear Team" button and confirm to remove all Pokemon.

## Android Intent API

Poke Builder can be controlled externally via Android intents! This allows you to integrate with ADB or other Android applications.

See [Intent API Documentation](docs/INTENT_API.md) for detailed information.

### Quick Examples

```bash
# Add Pikachu to the team
adb shell am start -n com.example.poke_builder/.MainActivity \
  -a com.example.poke_builder.ADD_POKEMON \
  --es pokemon_name "pikachu"

# Save the current team
adb shell am start -n com.example.poke_builder/.MainActivity \
  -a com.example.poke_builder.SAVE_TEAM \
  --es team_name "My Dream Team"

# Clear the team
adb shell am start -n com.example.poke_builder/.MainActivity \
  -a com.example.poke_builder.CLEAR_TEAM
```

## Architecture

The app follows a clean architecture pattern with clear separation of concerns:

- **Models**: Pokemon data structures with JSON serialization
- **Services**: PokeAPI client and local persistence
- **Providers**: Riverpod state management
- **UI**: Screens, widgets, and dialogs

For detailed architecture information, see [Architecture Documentation](docs/design/architecture.md).

## Technology Stack

- **Framework**: Flutter
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **HTTP Client**: http package
- **Persistence**: path_provider
- **JSON Serialization**: json_serializable
- **API**: PokeAPI v2

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
├── providers/                   # State management
├── services/                    # Business logic
├── screens/                     # Main screens
├── widgets/                     # Reusable components
├── dialogs/                     # Dialog widgets
└── router/                      # Navigation
```

## Development

### Code Generation

After modifying model classes with `@JsonSerializable()`, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Or for continuous generation during development:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

### Testing

Run tests:
```bash
flutter test
```

### Building for Production

#### Android APK
```bash
flutter build apk --release
```

#### Android App Bundle
```bash
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

## API Reference

This app uses the [PokeAPI v2](https://pokeapi.co/docs/v2) for Pokemon data. No API key is required.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the [MIT License](LICENSE).

## Acknowledgments

- [PokeAPI](https://pokeapi.co/) for providing the Pokemon data
- The Flutter team for the amazing framework
- The Pokemon Company for creating Pokemon

## Support

If you encounter any issues or have questions, please file an issue on GitHub.

