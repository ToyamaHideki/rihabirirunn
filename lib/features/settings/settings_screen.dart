import 'package:flutter/material.dart';

/// S50: 設定 - TODO: 実装予定
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('S50: 設定')),
      body: const Center(
        child: Text('S50: 設定\n（実装予定）', textAlign: TextAlign.center),
      ),
    );
  }
}
