package com.example.poke_builder

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.poke_builder/intents"
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        )
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        intent?.let {
            when (it.action) {
                "com.example.poke_builder.ADD_POKEMON" -> {
                    val pokemonName = it.getStringExtra("pokemon_name")
                    pokemonName?.let { name ->
                        methodChannel?.invokeMethod(
                            "addPokemon",
                            mapOf("name" to name)
                        )
                    }
                }
                "com.example.poke_builder.REMOVE_POKEMON" -> {
                    val pokemonName = it.getStringExtra("pokemon_name")
                    pokemonName?.let { name ->
                        methodChannel?.invokeMethod(
                            "removePokemon",
                            mapOf("name" to name)
                        )
                    }
                }
                "com.example.poke_builder.SAVE_TEAM" -> {
                    val teamName = it.getStringExtra("team_name")
                    methodChannel?.invokeMethod(
                        "saveTeam",
                        if (teamName != null) mapOf("name" to teamName) else null
                    )
                }
                "com.example.poke_builder.CLEAR_TEAM" -> {
                    methodChannel?.invokeMethod("clearTeam", null)
                }
            }
        }
    }
}

