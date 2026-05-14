import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: RihabiriRunApp(),
    ),
  );
}

class RihabiriRunApp extends StatelessWidget {
  const RihabiriRunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'リハビリラン',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF82)),
        useMaterial3: true,
      ),
      // TODO(T-0.3): GoRouter に差し替える
      home: const Scaffold(
        body: Center(
          child: Text('リハビリラン', style: TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
}
