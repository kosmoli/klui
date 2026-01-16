import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/routes/app_router.dart';
import 'core/theme/neo_brutalist_theme.dart';
import 'core/utils/logger.dart';
import 'core/providers/chat_providers.dart';
import 'l10n/generated/app_localizations.dart';

void main() {
  // Initialize logging
  initLogging();

  // Initialize selected agent ID from localStorage
  final savedId = initSelectedAgentId();
  print('[Init] Loaded selected agent ID: $savedId');

  const app = ProviderScope(child: MyApp());
  runApp(app);
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Klui - Letta AI Assistant',
      debugShowCheckedModeBanner: false,
      theme: NeoBrutalistTheme.dark,
      darkTheme: NeoBrutalistTheme.dark,
      themeMode: ThemeMode.dark,

      // Localization
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      routerConfig: router,
    );
  }
}
