import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// T-4.1.5: プライバシーポリシー画面
// ---------------------------------------------------------------------------

/// プライバシーポリシーの静的テキストを表示する画面
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('プライバシーポリシー'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Text(
            '最終更新日：2026年5月15日',
            style: textTheme.bodySmall
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          ..._kSections.map(
            (s) => _Section(title: s.title, body: s.body),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurface, height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// プライバシーポリシー本文
// ---------------------------------------------------------------------------

class _SectionData {
  const _SectionData({required this.title, required this.body});
  final String title;
  final String body;
}

const _kSections = <_SectionData>[
  _SectionData(
    title: '1. 収集する情報',
    body: '本アプリは以下の情報をデバイス内に保存します。\n\n・位置情報（走行中の GPS 軌跡）\n・走行記録（距離、時間、ペース、カロリー）\n・体調記録（痛みスコア、対象部位、メモ）\n・ユーザー設定（年齢、目標距離、テーマ設定等）\n\nこれらの情報は外部サーバーへ送信されることはありません。',
  ),
  _SectionData(
    title: '2. 情報の利用目的',
    body: '収集した情報は以下の目的のみに使用します。\n\n・走行履歴の記録・表示\n・目標距離の自動調整\n・ストリーク（連続走行日数）の計算\n・月間統計の表示',
  ),
  _SectionData(
    title: '3. 第三者への提供',
    body: '本アプリは収集したいかなる情報も第三者に提供・販売することはありません。',
  ),
  _SectionData(
    title: '4. 位置情報について',
    body: '本アプリは走行中のみ位置情報を取得します。バックグラウンドでの常時追跡は、走行セッションが有効な場合のみ行われます。\n\nアプリの設定からいつでも位置情報の権限を変更できます。',
  ),
  _SectionData(
    title: '5. データの管理・削除',
    body: 'ユーザーはアプリ内の「データ管理」からすべてのデータをエクスポートまたは削除できます。アプリをアンインストールするとデバイス内のすべてのデータが削除されます。',
  ),
  _SectionData(
    title: '6. お問い合わせ',
    body: 'プライバシーに関するご質問・ご要望は、アプリ情報画面に記載のメールアドレスまでご連絡ください。',
  ),
];
