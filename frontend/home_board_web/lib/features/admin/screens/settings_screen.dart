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
                title: const Text('Timezone'),
                subtitle: Text(settings.timezone),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showTimezoneDialog(context, settings),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('Point to Money Rate'),
                subtitle: Text('${settings.pointToMoneyRate.toStringAsFixed(2)} currency per point'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showPointRateDialog(context, settings),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Week Starts On'),
                subtitle: Text(_getDayName(settings.weekStartsOn)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showWeekStartsDialog(context, settings),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getDayName(int dayOfWeek) {
    const days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    return days[dayOfWeek % 7];
  }

  void _showTimezoneDialog(
      BuildContext context, FamilySettingsModel settings) {
    final timezoneController =
        TextEditingController(text: settings.timezone);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Change Timezone'),
        content: TextField(
          controller: timezoneController,
          decoration: const InputDecoration(
            labelText: 'Timezone',
            hintText: 'e.g., Europe/Oslo, America/New_York',
            helperText: 'IANA timezone identifier',
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
        title: const Text('Change Point to Money Rate'),
        content: TextField(
          controller: rateController,
          decoration: const InputDecoration(
            labelText: 'Rate',
            hintText: 'e.g., 1.0, 0.5, 0.10',
            helperText: 'Currency value per point',
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
        title: const Text('Week Starts On'),
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
