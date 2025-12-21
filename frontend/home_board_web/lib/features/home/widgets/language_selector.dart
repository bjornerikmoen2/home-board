import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/locale_provider.dart';

/// Widget to select and change the app's language
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      tooltip: 'Change Language',
      onSelected: (String languageCode) {
        ref.read(localeProvider.notifier).setLocale(Locale(languageCode));
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'en',
          child: Row(
            children: [
              if (currentLocale.languageCode == 'en')
                const Icon(Icons.check, size: 20)
              else
                const SizedBox(width: 20),
              const SizedBox(width: 8),
              const Text('English'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'nb',
          child: Row(
            children: [
              if (currentLocale.languageCode == 'nb')
                const Icon(Icons.check, size: 20)
              else
                const SizedBox(width: 20),
              const SizedBox(width: 8),
              const Text('Norsk'),
            ],
          ),
        ),
      ],
    );
  }
}
