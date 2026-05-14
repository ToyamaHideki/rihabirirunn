import 'package:flutter/material.dart';

/// S31: 走行サマリ - TODO: 実装予定
class RunSummaryScreen extends StatelessWidget {
  const RunSummaryScreen({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('S31: 走行サマリ')),
      body: const Center(
        child: Text('S31: 走行サマリ\n（実装予定）', textAlign: TextAlign.center),
      ),
    );
  }
}
