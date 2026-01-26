import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/team_provider.dart';

class LoadTeamDialog extends ConsumerWidget {
  const LoadTeamDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedTeamsAsync = ref.watch(savedTeamsProvider);

    return AlertDialog(
      title: const Text('Load Team'),
      content: SizedBox(
        width: double.maxFinite,
        child: savedTeamsAsync.when(
          data: (teams) {
            if (teams.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No saved teams found',
                  textAlign: TextAlign.center,
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: teams.length,
              itemBuilder: (context, index) {
                final teamName = teams[index];
                return ListTile(
                  leading: const Icon(Icons.group),
                  title: Text(teamName),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteTeam(context, ref, teamName),
                  ),
                  onTap: () => _loadTeam(context, ref, teamName),
                );
              },
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Error loading teams: $error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Future<void> _loadTeam(
    BuildContext context,
    WidgetRef ref,
    String teamName,
  ) async {
    try {
      final service = ref.read(teamPersistenceServiceProvider);
      final team = await service.loadTeam(teamName);

      if (team != null) {
        ref.read(teamProvider.notifier).setTeam(team.pokemon);
        ref.read(currentTeamNameProvider.notifier).state = team.name;

        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Team "${team.name}" loaded!'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to load team'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading team: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _deleteTeam(
    BuildContext context,
    WidgetRef ref,
    String teamName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Team'),
        content: Text('Are you sure you want to delete "$teamName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final service = ref.read(teamPersistenceServiceProvider);
        await service.deleteTeam(teamName);

        // Refresh the teams list
        ref.invalidate(savedTeamsProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Team "$teamName" deleted'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting team: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }
}
