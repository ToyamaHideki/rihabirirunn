import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/repositories/user_profile_repository.dart';
import '../../shared/router/app_routes.dart';
import '../../shared/widgets/primary_button.dart';

/// S01: 免責同意画面（初回起動時のみ表示）
///
/// 「同意する」を押した時点で:
/// - UserProfile を DB に作成（agreedDisclaimerAt を記録）
/// - SetupScreen へ遷移
class DisclaimerScreen extends ConsumerStatefulWidget {
  const DisclaimerScreen({super.key});

  @override
  ConsumerState<DisclaimerScreen> createState() => _DisclaimerScreenState();
}

class _DisclaimerScreenState extends ConsumerState<DisclaimerScreen> {
  bool _isLoading = false;

  Future<void> _onAgree() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      await ref.read(userProfileRepositoryProvider).createProfile(
            agreedDisclaimerAt: DateTime.now(),
          );
      if (!mounted) return;
      context.go(AppRoutes.setup);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('エラーが発生しました。もう一度お試しください。')),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('利用規約・免責事項'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ---- スクロール可能な本文 ----
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Icon(
                        Icons.health_and_safety_outlined,
                        size: 56,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'ご利用の前にお読みください',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 28),

                    _SectionTitle('1. 医療行為ではありません'),
                    _Body(
                      '本アプリ「リハビリウォーク」は健康増進を目的とした歩行サポートアプリです。'
                      '医療機器ではなく、医師・理学療法士等の医療行為の代替ではありません。'
                      '症状の診断・治療を目的とするものではありません。',
                    ),
                    const SizedBox(height: 20),

                    _SectionTitle('2. 医師への相談をおすすめします'),
                    _Body(
                      '術後・骨折・靭帯損傷などの回復中の方、持病のある方、'
                      '高齢でフレイルのリスクがある方は、本アプリの利用前に'
                      '必ず主治医または理学療法士にご相談ください。',
                    ),
                    const SizedBox(height: 20),

                    _SectionTitle('3. 自己責任での使用'),
                    _Body(
                      '歩行中・走行中の転倒・事故・体調悪化・その他の損害について、'
                      '開発者は一切の責任を負いません。'
                      '体調が優れない場合や痛みが増した場合は、直ちに運動を中止し'
                      '医療機関を受診してください。',
                    ),
                    const SizedBox(height: 20),

                    _SectionTitle('4. 緊急時の対応'),
                    _Body(
                      '胸痛・強い息切れ・激しいめまいなどの症状が現れた場合は'
                      '直ちに運動を中止し、必要に応じて救急（119番）に連絡してください。',
                    ),
                    const SizedBox(height: 20),

                    _SectionTitle('5. データについて'),
                    _Body(
                      '記録したデータ（位置情報・走行ログ・体調記録）は'
                      '端末内にのみ保存されます。インターネットへの送信は行いません。',
                    ),
                    const SizedBox(height: 32),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer
                            .withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '「同意してはじめる」を押すことで、上記の内容に同意したものとみなします。',
                              style: textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ---- 固定フッターボタン ----
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(color: colorScheme.outlineVariant),
                ),
              ),
              child: PrimaryButton(
                label: '同意してはじめる',
                onPressed: _onAgree,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- プライベートウィジェット ----

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.7),
    );
  }
}
