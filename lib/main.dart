import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shared/router/app_router.dart';

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
    return MaterialApp.router(
      title: 'リハビリラン',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF82)),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
