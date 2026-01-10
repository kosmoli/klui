import 'package:flutter/material.dart';
import 'package:klui/l10n/generated/app_localizations.dart';

/// Extension on BuildContext for easy localization access
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
