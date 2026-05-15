import 'package:flutter/material.dart';

import '../../shared/widgets/app_card.dart';

// ---------------------------------------------------------------------------
// T-4.1.6: アプリ情報画面
// ---------------------------------------------------------------------------

/// アプリのバージョン情報・問い合わせ先を表示する画面
class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

  // アプリのバージョン（ストア申請時に更新）
  static const _kVersion = '1.0.0';
  static const _kBuildNumber = '1';
  static const _kContactEmail = 'rehabilirun.support@example.com';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('アプリ情報'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        children: [
          // ---- アプリアイコン + 名前 ----
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.directions_walk_rounded,
                    size: 44,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'リハビリラン',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'バージョン $_kVersion ($_kBuildNumber)',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ---- アプリ説明 ----
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('アプリについて', style: textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Text(
                    'リハビリランは、リハビリ中の方が無理なく歩行習慣を続けられるよう支援するアプリです。\n\n'
                    '指定した距離に合わせたウォーキングルートを自動生成し、日々の走行記録・体調管理をサポートします。',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ---- お問い合わせ ----
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('お問い合わせ', style: textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.mail_outline_rounded,
                        color: colorScheme.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      SelectableText(
                        _kContactEmail,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'バグ報告・ご意見・ご要望はメールにてお気軽にどうぞ。',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ---- 技術情報 ----
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('技術情報', style: textTheme.labelLarge),
                  const SizedBox(height: 8),
                  _InfoRow(label: 'フレームワーク', value: 'Flutter 3.x'),
                  _InfoRow(label: 'プラットフォーム', value: 'iOS / Android'),
                  _InfoRow(label: '地図', value: 'Mapbox'),
                  _InfoRow(
                      label: 'データ保存',
                      value: 'ローカル（端末内）のみ'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Center(
            child: Text(
              '© 2026 リハビリラン',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
