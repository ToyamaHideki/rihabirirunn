import 'package:flutter/material.dart';

/// S10: ホーム - TODO: 実装予定
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('S10: ホーム')),
      body: const Center(
        child: Text('S10: ホーム\n（実装予定）', textAlign: TextAlign.center),
      ),
    );
  }
}
