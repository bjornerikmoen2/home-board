# Internationalization (i18n) Guide

## Overview
The Home Board app supports multiple languages using Flutter's official localization system. Currently supported languages:
- English (en) - Default
- Norwegian Bokmål (nb)

## How to Use Translations in Your Code

### 1. Using the Context Extension (Recommended)
```dart
import '../core/l10n/l10n_extensions.dart';

// In your widget build method:
Text(context.l10n.appTitle)
Text(context.l10n.todayTasks)
Text(context.l10n.markAsComplete('Clean the kitchen'))
```

### 2. Using AppLocalizations Directly
```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// In your widget build method:
final l10n = AppLocalizations.of(context)!;
Text(l10n.appTitle)
```

## Adding New Translations

### 1. Add the English String
Edit `lib/l10n/app_en.arb` and add your new key:
```json
{
  "myNewKey": "My New String",
  "@myNewKey": {
    "description": "Description of what this string is for"
  }
}
```

### 2. Add the Norwegian Translation
Edit `lib/l10n/app_nb.arb` and add the translated version:
```json
{
  "myNewKey": "Min Nye Streng"
}
```

### 3. Run Code Generation
```bash
flutter pub get
# The localization files are generated automatically
```

### 4. Use in Your Code
```dart
Text(context.l10n.myNewKey)
```

## Strings with Placeholders

### In ARB files:
```json
{
  "greeting": "Hello, {name}!",
  "@greeting": {
    "description": "Greeting message with user name",
    "placeholders": {
      "name": {
        "type": "String",
        "example": "John"
      }
    }
  }
}
```

### In code:
```dart
Text(context.l10n.greeting('Alice'))
```

## Language Switching

Users can switch languages using the `LanguageSelector` widget. Add it to your app bar:

```dart
AppBar(
  title: Text('Home Board'),
  actions: [
    LanguageSelector(),
  ],
)
```

The selected language is automatically saved to local storage and persists across app restarts.

## Adding a New Language

1. Create a new ARB file: `lib/l10n/app_[locale].arb`
2. Copy all keys from `app_en.arb` and translate them
3. Add the locale to `lib/main.dart` in the `supportedLocales` list:
```dart
supportedLocales: const [
  Locale('en', ''),
  Locale('nb', ''),
  Locale('de', ''), // German, for example
],
```
4. Update the `LanguageSelector` widget to include the new language option

## File Structure
```
lib/
├── l10n/
│   ├── app_en.arb          # English translations
│   └── app_nb.arb          # Norwegian translations
├── core/
│   └── l10n/
│       ├── l10n_extensions.dart   # Helper extension
│       └── locale_provider.dart   # Language state management
└── features/
    └── home/
        └── widgets/
            └── language_selector.dart  # UI for language switching
```

## Best Practices

1. **Always use translation keys** instead of hardcoded strings in your UI
2. **Keep keys descriptive** but concise (e.g., `todayTasks`, not `t1` or `todaysTasksScreenTitle`)
3. **Add descriptions** in the English ARB file for all keys
4. **Test both languages** when adding new features
5. **Use placeholders** for dynamic content instead of string concatenation
6. **Group related strings** with common prefixes (e.g., `error*`, `button*`)

## Troubleshooting

### Generated files not found
Run `flutter pub get` to trigger code generation.

### Changes to ARB files not reflected
1. Save all ARB files
2. Run `flutter pub get` or restart the app
3. If using hot reload, do a hot restart instead

### Language not switching
Check that:
1. The locale is added to `supportedLocales` in main.dart
2. The ARB file exists with the correct naming convention
3. The locale provider is properly integrated
