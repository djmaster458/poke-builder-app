package com.example.poke_builder

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.poke_builder/intents"
    private var methodChannel: MethodChannel? = null
    private var pokemonReceiver: PokemonBroadcastReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        )
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        registerPokemonReceiver()
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterPokemonReceiver()
    }

    private fun registerPokemonReceiver() {
        pokemonReceiver = PokemonBroadcastReceiver()
        val filter = IntentFilter().apply {
            addAction("com.example.poke_builder.ADD_POKEMON")
            addAction("com.example.poke_builder.REMOVE_POKEMON")
            addAction("com.example.poke_builder.SAVE_TEAM")
            addAction("com.example.poke_builder.CLEAR_TEAM")
        }
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(pokemonReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(pokemonReceiver, filter)
        }
    }

    private fun unregisterPokemonReceiver() {
        pokemonReceiver?.let {
            unregisterReceiver(it)
            pokemonReceiver = null
        }
    }

    inner class PokemonBroadcastReceiver : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
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
}

