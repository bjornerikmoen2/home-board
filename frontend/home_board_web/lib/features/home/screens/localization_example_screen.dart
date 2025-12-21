import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../widgets/language_selector.dart';

/// Example screen showing how to use localization
class LocalizationExampleScreen extends ConsumerWidget {
  const LocalizationExampleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.appTitle),
        actions: const [
          LanguageSelector(), // Language switcher in app bar
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simple translation
            Text(
              context.l10n.welcome,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            
            // Translation with placeholder
            Text(context.l10n.markAsComplete('Example Task')),
            const SizedBox(height: 16),
            
            // Buttons with translations
            ElevatedButton(
              onPressed: () {},
              child: Text(context.l10n.save),
            ),
            const SizedBox(height: 8),
            
            ElevatedButton(
              onPressed: () {},
              child: Text(context.l10n.cancel),
            ),
            const SizedBox(height: 16),
            
            // List of translated items
            Text(
              context.l10n.tasks,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            
            ListTile(
              title: Text(context.l10n.todayTasks),
              subtitle: Text(context.l10n.myTasksForToday),
            ),
            ListTile(
              title: Text(context.l10n.leaderboard),
              subtitle: Text(context.l10n.points),
            ),
          ],
        ),
      ),
    );
  }
}
