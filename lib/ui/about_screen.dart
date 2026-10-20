import 'package:flutter/material.dart';

final class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('About Moodist')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Moodist (offline)', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text(
            'Ambient sounds for focus and calm. This build bundles all '
            '84 sounds inside the app, so it works with no internet '
            'connection at all — no account, no streaming, no downloads.',
          ),
          const SizedBox(height: 24),
          Text('Credits', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text(
            'A Flutter port of the open-source Moodist web app by MAZE '
            '(github.com/remvze/moodist). The original code is licensed '
            'under the MIT License, Copyright (c) 2023 MAZE.\n\n'
            'Sounds are sourced from third-party providers and are '
            'subject to their own licenses: the Pixabay Content License '
            'and Creative Commons Zero (CC0), as documented in the '
            'upstream project README.',
          ),
          const SizedBox(height: 24),
          Text('Privacy', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text(
            'The app requests no internet permission. Presets, '
            'favorites, and your last mix are stored only on this '
            'device.',
          ),
        ],
      ),
    );
  }
}
