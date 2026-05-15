import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// T-4.1.5: 利用規約画面
// ---------------------------------------------------------------------------

/// 利用規約の静的テキストを表示する画面
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('利用規約'),
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
            (s) => _TermsSection(title: s.title, body: s.body),
          ),
        ],
      ),
    );
  }
}

class _TermsSection extends StatelessWidget {
  const _TermsSection({required this.title, required this.body});
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
// 利用規約本文
// ---------------------------------------------------------------------------

class _Section {
  const _Section({required this.title, required this.body});
  final String title;
  final String body;
}

const _kSections = <_Section>[
  _Section(
    title: '第1条（本規約の適用）',
    body: '本利用規約（以下「本規約」）は、リハビリラン（以下「本アプリ」）の利用に関する条件を定めるものです。ユーザーは本規約に同意の上で本アプリをご利用ください。',
  ),
  _Section(
    title: '第2条（免責事項）',
    body: '本アプリはリハビリ支援を目的とした歩行記録ツールです。医療行為・医学的診断・治療の代替となるものではありません。\n\n運動を行う前には必ず主治医または理学療法士の指示に従ってください。本アプリの使用により生じたいかなる損害についても、開発者は一切の責任を負いません。',
  ),
  _Section(
    title: '第3条（データの取扱い）',
    body: '本アプリで記録されたデータはすべてお客様のデバイス内にローカル保存されます。開発者がサーバーに収集・送信することはありません。',
  ),
  _Section(
    title: '第4条（位置情報の利用）',
    body: '本アプリは走行中の経路記録のために位置情報を取得します。取得した位置情報はデバイス内にのみ保存され、外部へ送信されることはありません。',
  ),
  _Section(
    title: '第5条（禁止事項）',
    body: '以下の行為を禁止します。\n・本アプリのリバースエンジニアリング、逆コンパイル\n・本アプリを医療診断の根拠として使用すること\n・その他、法令または公序良俗に反する行為',
  ),
  _Section(
    title: '第6条（規約の変更）',
    body: 'アプリのアップデートに伴い、本規約を変更する場合があります。変更後もアプリを継続使用された場合、改定後の規約に同意したものとみなします。',
  ),
  _Section(
    title: '第7条（準拠法）',
    body: '本規約は日本法に準拠し、解釈されるものとします。',
  ),
];
