import 'package:flutter/material.dart';

/// S42: 統計サマリ - TODO: 実装予定
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('S42: 統計サマリ')),
      body: const Center(
        child: Text('S42: 統計サマリ\n（実装予定）', textAlign: TextAlign.center),
      ),
    );
  }
}
