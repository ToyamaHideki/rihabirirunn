import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shared/router/app_router.dart';
import 'shared/theme/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: RihabiriRunApp(),
    ),
  );
}

class RihabiriRunApp extends ConsumerWidget {
  const RihabiriRunApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final theme = ref.watch(appThemeProvider);
    return MaterialApp.router(
      title: 'リハビリラン',
      theme: theme,
      routerConfig: router,
    );
  }
}
