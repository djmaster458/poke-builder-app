import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pokemon_team.dart';
import '../providers/team_provider.dart';

class SaveTeamDialog extends ConsumerStatefulWidget {
  const SaveTeamDialog({super.key});

  @override
  ConsumerState<SaveTeamDialog> createState() => _SaveTeamDialogState();
}

class _SaveTeamDialogState extends ConsumerState<SaveTeamDialog> {
  final _controller = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller.text = ref.read(currentTeamNameProvider);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveTeam() async {
    final teamName = _controller.text.trim();
    if (teamName.isEmpty) {
      _showError('Please enter a team name');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final team = ref.read(teamProvider);
      final service = ref.read(teamPersistenceServiceProvider);

      final pokemonTeam = PokemonTeam(
        name: teamName,
        pokemon: team,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await service.saveTeam(pokemonTeam);

      ref.read(currentTeamNameProvider.notifier).setTeamName(teamName);

      // Refresh saved teams list
      ref.invalidate(savedTeamsProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Team "$teamName" saved successfully!'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      _showError('Failed to save team: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save Team'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Team Name',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _saveTeam(),
            enabled: !_isSaving,
          ),
          if (_isSaving) ...[
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveTeam,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
