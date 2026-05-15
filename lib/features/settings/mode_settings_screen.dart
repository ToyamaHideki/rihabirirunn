import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../database/database.dart';
import '../../shared/repositories/user_profile_repository.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/primary_button.dart';

// ---------------------------------------------------------------------------
// S51: モード設定画面
// ---------------------------------------------------------------------------

/// T-4.1.2: モード設定画面
///
/// 仕様 2.1 に定義された 4モードを選択し UserProfile.mode を更新する。
class ModeSettingsScreen extends ConsumerStatefulWidget {
  const ModeSettingsScreen({super.key});

  @override
  ConsumerState<ModeSettingsScreen> createState() =>
      _ModeSettingsScreenState();
}

class _ModeSettingsScreenState extends ConsumerState<ModeSettingsScreen> {
  String _selected = 'standard';
  UserProfile? _profile;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile =
        await ref.read(userProfileRepositoryProvider).getProfile();
    if (mounted) {
      setState(() {
        _profile = profile;
        _selected = profile?.mode ?? 'standard';
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    if (_isSaving || _profile == null) return;
    setState(() => _isSaving = true);
    try {
      await ref
          .read(userProfileRepositoryProvider)
          .updateProfile(_profile!.id, mode: _selected);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('モードを変更しました')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存に失敗しました。もう一度お試しください')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('距離モード')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('距離モード'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '走行後に目標距離をどのように調整するか選択してください。',
                    style: textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  ..._kModes.map(
                    (m) => _ModeTile(
                      mode: m,
                      isSelected: _selected == m.key,
                      onTap: () => setState(() => _selected = m.key),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: PrimaryButton(
              label: '保存する',
              onPressed: _isSaving ? null : _save,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// モード定義
// ---------------------------------------------------------------------------

class _ModeInfo {
  const _ModeInfo({
    required this.key,
    required this.label,
    required this.icon,
    required this.description,
    required this.adjustRule,
  });
  final String key;
  final String label;
  final IconData icon;
  final String description;
  final String adjustRule;
}

const _kModes = <_ModeInfo>[
  _ModeInfo(
    key: 'conservative',
    label: '保守モード',
    icon: Icons.spa_rounded,
    description:
        '体への負担を最小限に抑えながら少しずつ距離を伸ばします。\n痛みが強い方・リハビリ初期の方におすすめです。',
    adjustRule: '達成時 +5% ／ 2日連続未達成時 −5%',
  ),
  _ModeInfo(
    key: 'standard',
    label: '標準モード',
    icon: Icons.directions_walk_rounded,
    description:
        'バランスよく距離を調整します。\n多くの方にとって安心して使えるモードです。',
    adjustRule: '達成時 +10%',
  ),
  _ModeInfo(
    key: 'challenge',
    label: 'チャレンジモード',
    icon: Icons.fitness_center_rounded,
    description:
        '積極的に距離を伸ばしたい方向け。\n体調に十分注意しながらご使用ください。',
    adjustRule: '達成時 +15% ／ 3日連続達成時 +20%',
  ),
  _ModeInfo(
    key: 'custom',
    label: 'カスタムモード',
    icon: Icons.tune_rounded,
    description:
        '目標距離を自動調整しません。\n医師の指示に合わせて手動管理したい方向けです。',
    adjustRule: '変化なし（手動管理）',
  ),
];

// ---------------------------------------------------------------------------
// モード選択タイル
// ---------------------------------------------------------------------------

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  final _ModeInfo mode;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 選択インジケーター
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // モード名 + アイコン
                      Row(
                        children: [
                          Icon(
                            mode.icon,
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            mode.label,
                            style: textTheme.titleSmall?.copyWith(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // 説明文
                      Text(
                        mode.description,
                        style: textTheme.bodySmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 6),
                      // 調整ルールバッジ
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primaryContainer
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          mode.adjustRule,
                          style: textTheme.labelSmall?.copyWith(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
