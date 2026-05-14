import 'package:flutter/material.dart';

/// S22/S32: 体調入力 - TODO: 実装予定
class ConditionScreen extends StatelessWidget {
  const ConditionScreen({required this.timing, super.key});

  /// 'before' (走行前) または 'after' (走行後)
  final String timing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('S22/S32: 体調入力')),
      body: const Center(
        child: Text('S22/S32: 体調入力\n（実装予定）', textAlign: TextAlign.center),
      ),
    );
  }
}
