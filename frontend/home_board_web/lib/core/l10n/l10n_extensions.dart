import 'package:flutter/material.dart';
import 'package:home_board_web/l10n/gen/app_localizations.dart';

/// Extension to easily access localized strings from BuildContext
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
