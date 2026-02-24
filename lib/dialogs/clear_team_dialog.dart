import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poke_builder/providers/team_provider.dart';

class ClearTeamDialog extends ConsumerWidget {
  const ClearTeamDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Clear Team'),
      content: const Text('Are you sure you want to clear your team?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            ref.read(teamProvider.notifier).clearTeam();
            Navigator.of(context).pop();
          },
          child: const Text('Clear'),
        ),
      ],
    );
  }
}
