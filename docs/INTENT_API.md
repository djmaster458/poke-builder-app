# Poke Builder Broadcast API Documentation

This document describes the Android Broadcast API for the Poke Builder app, allowing external applications to interact with Pokemon teams **while the app is running**.

## Overview

The Poke Builder app uses broadcast receivers to manage Pokemon teams programmatically. **The app must be running for broadcasts to be received**. These broadcasts can be sent using Android Debug Bridge (ADB) or from other Android applications.

## Important Note

⚠️ **The app must be running in the foreground or background for broadcasts to work.** If the app is not running, the broadcasts will be ignored. This is by design for security and performance reasons.

## Package Name

`com.example.poke_builder`

## Available Broadcasts

### 1. Add Pokemon

Adds a Pokemon to the current team by name or ID.

**Action:** `com.example.poke_builder.ADD_POKEMON`

**Extras:**
- `pokemon_name` (String, required): The name or ID of the Pokemon to add

**Response:**
- `success` (Boolean): Whether the operation succeeded
- `message` (String): Success message
- `error` (String): Error message if failed
- `team_size` (Integer): Current team size after operation

**Possible Errors:**
- Pokemon name is required
- Team is full (6/6 Pokemon)
- Pokemon already on the team
- Pokemon not found

**Example using ADB:**
```bash
adb shell am broadcast -a com.example.poke_builder.ADD_POKEMON \
  --es pokemon_name "pikachu"

adb shell am broadcast -a com.example.poke_builder.ADD_POKEMON \
  --es pokemon_name "25"
```

---

### 2. Remove Pokemon

Removes a Pokemon from the current team by name.

**Action:** `com.example.poke_builder.REMOVE_POKEMON`

**Extras:**
- `pokemon_name` (String, required): The name of the Pokemon to remove

**Response:**
- `success` (Boolean): Whether the operation succeeded
- `message` (String): Success message
- `error` (String): Error message if failed
- `team_size` (Integer): Current team size after operation

**Possible Errors:**
- Pokemon name is required
- Pokemon is not on the team

**Example using ADB:**
```bash
adb shell am broadcast -a com.example.poke_builder.REMOVE_POKEMON \
  --es pokemon_name "pikachu"
```

---

### 3. Save Team

Saves the current team to persistent storage.

**Action:** `com.example.poke_builder.SAVE_TEAM`

**Extras:**
- `team_name` (String, optional): The name to save the team as. If not provided, uses the current team name.

**Response:**
- `success` (Boolean): Whether the operation succeeded
- `message` (String): Success message
- `error` (String): Error message if failed
- `team_name` (String): The name the team was saved as
- `team_size` (Integer): Number of Pokemon in the team

**Possible Errors:**
- Cannot save empty team

**Example using ADB:**
```bash
adb shell am broadcast -a com.example.poke_builder.SAVE_TEAM \
  --es team_name "My Dream Team"

# Save with current name
adb shell am broadcast -a com.example.poke_builder.SAVE_TEAM
```

---

### 4. Clear Team

Clears all Pokemon from the current team.

**Action:** `com.example.poke_builder.CLEAR_TEAM`

**Extras:** None

**Response:**
- `success` (Boolean): Whether the operation succeeded
- `message` (String): Success message with count of removed Pokemon
- `error` (String): Error message if failed
- `team_size` (Integer): 0 (always)

**Example using ADB:**
```bash
adb shell am broadcast -a com.example.poke_builder.CLEAR_TEAM
```

---

## Using from Another Android App

Here's how to send broadcasts from another Android application:

### Kotlin Example

```kotlin
// Add Pokemon
val intent = Intent("com.example.poke_builder.ADD_POKEMON").apply {
    putExtra("pokemon_name", "charizard")
}
sendBroadcast(intent)

// Remove Pokemon
val removeIntent = Intent("com.example.poke_builder.REMOVE_POKEMON").apply {
    putExtra("pokemon_name", "charizard")
}
sendBroadcast(removeIntent)

// Save Team
val saveIntent = Intent("com.example.poke_builder.SAVE_TEAM").apply {
    putExtra("team_name", "Elite Four Team")
}
sendBroadcast(saveIntent)

// Clear Team
val clearIntent = Intent("com.example.poke_builder.CLEAR_TEAM")
sendBroadcast(clearIntent)
```

### Java Example

```java
// Add Pokemon
Intent intent = new Intent("com.example.poke_builder.ADD_POKEMON");
intent.putExtra("pokemon_name", "charizard");
sendBroadcast(intent);
```

---

## Testing with ADB

**Important:** Make sure the app is running before sending broadcasts!

### Complete Workflow Example

```bash
# 1. Start the app first
adb shell am start -n com.example.poke_builder/.MainActivity

# 2. Wait for app to load, then clear any existing team
adb shell am broadcast -a com.example.poke_builder.CLEAR_TEAM

# 3. Add multiple Pokemon
adb shell am broadcast -a com.example.poke_builder.ADD_POKEMON \
  --es pokemon_name "pikachu"

adb shell am broadcast -a com.example.poke_builder.ADD_POKEMON \
  --es pokemon_name "charizard"

adb shell am broadcast -a com.example.poke_builder.ADD_POKEMON \
  --es pokemon_name "blastoise"

# 4. Save the team
adb shell am broadcast -a com.example.poke_builder.SAVE_TEAM \
  --es team_name "Kanto Starters"

# 5. Remove a Pokemon
adb shell am broadcast -a com.example.poke_builder.REMOVE_POKEMON \
  --es pokemon_name "pikachu"
```

---

## Error Handling

All intents return a response map with the following structure:

**Success Response:**
```json
{
  "success": true,
  "message": "Operation completed successfully",
  "team_size": 3,
  // Additional fields depending on the operation
}
```

**Error Response:**
```json
{
  "success": false,
  "error": "Description of what went wrong"
}
```

---

## Notes

- **The app must be running for broadcasts to be received**
- Pokemon names are case-insensitive
- Pokemon can be specified by name (e.g., "pikachu") or ID (e.g., "25")
- The team has a maximum capacity of 6 Pokemon
- Teams are saved to the device's local storage
- The app must be installed on the device for the broadcasts to work
- If the app is not running, broadcasts will be silently ignored
