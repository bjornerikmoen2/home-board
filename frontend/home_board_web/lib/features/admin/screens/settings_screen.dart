import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../models/family_settings_models.dart';
import '../providers/family_settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(familySettingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(familySettingsNotifierProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: settingsAsync.when(
            data: (settings) => _buildSettingsContent(context, settings),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(context.l10n.error),
                  const SizedBox(height: 8),
                  Text(error.toString()),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref
                        .read(familySettingsNotifierProvider.notifier)
                        .refresh(),
                    child: Text(context.l10n.refresh),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsContent(
      BuildContext context, FamilySettingsModel settings) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          context.l10n.settings,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 24),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.schedule),
                title: Text(context.l10n.timezone),
                subtitle: Text(settings.timezone),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showTimezoneDialog(context, settings),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: Text(context.l10n.pointToMoneyRate),
                subtitle: Text(context.l10n.currencyPerPoint(settings.pointToMoneyRate.toStringAsFixed(2))),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showPointRateDialog(context, settings),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(context.l10n.weekStartsOn),
                subtitle: Text(_getDayName(settings.weekStartsOn)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showWeekStartsDialog(context, settings),
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.leaderboard),
                title: const Text('Enable Scoreboard'),
                subtitle: const Text('Allow public access to scoreboard page'),
                value: settings.enableScoreboard,
                onChanged: (bool value) async {
                  await ref
                      .read(familySettingsNotifierProvider.notifier)
                      .updateSettings(
                        UpdateFamilySettingsRequest(enableScoreboard: value),
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.l10n.success)),
                    );
                  }
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.admin_panel_settings),
                title: Text(context.l10n.includeAdminsInAssignments),
                subtitle: Text(context.l10n.includeAdminsInAssignmentsDescription),
                value: settings.includeAdminsInAssignments,
                onChanged: (value) async {
                  await ref
                      .read(familySettingsNotifierProvider.notifier)
                      .updateSettings(
                        UpdateFamilySettingsRequest(
                            includeAdminsInAssignments: value),
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.l10n.success)),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getDayName(int dayOfWeek) {
    switch (dayOfWeek % 7) {
      case 0:
        return context.l10n.sunday;
      case 1:
        return context.l10n.monday;
      case 2:
        return context.l10n.tuesday;
      case 3:
        return context.l10n.wednesday;
      case 4:
        return context.l10n.thursday;
      case 5:
        return context.l10n.friday;
      case 6:
        return context.l10n.saturday;
      default:
        return '';
    }
  }

  void _showTimezoneDialog(
      BuildContext context, FamilySettingsModel settings) {
    final timezoneController =
        TextEditingController(text: settings.timezone);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(context.l10n.changeTimezone),
        content: TextField(
          controller: timezoneController,
          decoration: InputDecoration(
            labelText: context.l10n.timezone,
            hintText: context.l10n.timezoneHint,
            helperText: context.l10n.timezoneHelper,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final newTimezone = timezoneController.text.trim();
              if (newTimezone.isNotEmpty) {
                await ref
                    .read(familySettingsNotifierProvider.notifier)
                    .updateSettings(
                      UpdateFamilySettingsRequest(timezone: newTimezone),
                    );
                if (context.mounted) {
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.success)),
                  );
                }
              }
            },
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );
  }

  void _showPointRateDialog(
      BuildContext context, FamilySettingsModel settings) {
    final rateController =
        TextEditingController(text: settings.pointToMoneyRate.toString());

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(context.l10n.changePointToMoneyRate),
        content: TextField(
          controller: rateController,
          decoration: InputDecoration(
            labelText: context.l10n.rate,
            hintText: context.l10n.rateHint,
            helperText: context.l10n.rateHelper,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final newRate = double.tryParse(rateController.text.trim());
              if (newRate != null && newRate >= 0) {
                await ref
                    .read(familySettingsNotifierProvider.notifier)
                    .updateSettings(
                      UpdateFamilySettingsRequest(pointToMoneyRate: newRate),
                    );
                if (context.mounted) {
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.success)),
                  );
                }
              }
            },
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );
  }

  void _showWeekStartsDialog(
      BuildContext context, FamilySettingsModel settings) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(context.l10n.weekStartsOn),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(7, (index) {
            return RadioListTile<int>(
              title: Text(_getDayName(index)),
              value: index,
              groupValue: settings.weekStartsOn,
              onChanged: (value) async {
                if (value != null) {
                  await ref
                      .read(familySettingsNotifierProvider.notifier)
                      .updateSettings(
                        UpdateFamilySettingsRequest(weekStartsOn: value),
                      );
                  if (context.mounted) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.l10n.success)),
                    );
                  }
                }
              },
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.l10n.cancel),
          ),
        ],
      ),
    );
  }
}
