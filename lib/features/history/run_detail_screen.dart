import 'package:flutter/material.dart';

/// S41: 走行詳細 - TODO: 実装予定
class RunDetailScreen extends StatelessWidget {
  const RunDetailScreen({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('S41: 走行詳細')),
      body: const Center(
        child: Text('S41: 走行詳細\n（実装予定）', textAlign: TextAlign.center),
      ),
    );
  }
}
