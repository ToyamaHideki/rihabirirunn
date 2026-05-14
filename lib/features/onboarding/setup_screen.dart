import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/repositories/user_profile_repository.dart';
import '../../shared/router/app_routes.dart';
import '../../shared/widgets/primary_button.dart';

/// S02: 初期設定ウィザード
///
/// 年齢・リハビリ対象部位（任意）・最終目標距離を入力し、
/// UserProfile を更新してから DesignScreen へ遷移する。
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _rehabTargetController = TextEditingController();

  /// 最終目標距離（km 単位スライダー、1.0〜21.0km）
  double _finalGoalKm = 3.0;

  bool _isLoading = false;

  @override
  void dispose() {
    _ageController.dispose();
    _rehabTargetController.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final repo = ref.read(userProfileRepositoryProvider);
      final profile = await repo.getProfile();
      if (profile == null) {
        // 通常は来ないが安全策
        if (!mounted) return;
        context.go(AppRoutes.disclaimer);
        return;
      }

      final ageText = _ageController.text.trim();
      final age = ageText.isNotEmpty ? int.tryParse(ageText) : null;
      final rehabTarget = _rehabTargetController.text.trim();

      await repo.updateProfile(
        profile.id,
        age: age,
        rehabTarget: rehabTarget.isNotEmpty ? rehabTarget : null,
        finalGoalDistance: _finalGoalKm * 1000, // m 単位に変換
      );

      if (!mounted) return;
      context.go(AppRoutes.design);
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
        title: const Text('基本情報の入力'),
        centerTitle: true,
        // 戻るボタンを非表示（オンボーディング中は戻れない）
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ヘッダー
                      Text(
                        'あなたについて教えてください',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '入力した情報はアプリの目標距離設定に使われます。\nすべて後から変更できます。',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ---- 年齢 ----
                      Text('年齢（任意）', style: textTheme.titleSmall),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        decoration: const InputDecoration(
                          hintText: '例: 55',
                          suffixText: '歳',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return null;
                          final age = int.tryParse(value);
                          if (age == null || age < 1 || age > 120) {
                            return '1〜120 の数値を入力してください';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // ---- リハビリ対象部位 ----
                      Row(
                        children: [
                          Text('リハビリ中の部位', style: textTheme.titleSmall),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '任意',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _rehabTargetController,
                        textInputAction: TextInputAction.next,
                        maxLength: 50,
                        decoration: const InputDecoration(
                          hintText: '例: 右膝、腰、左足首など',
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ---- 最終目標距離スライダー ----
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('最終的に歩きたい距離', style: textTheme.titleSmall),
                          Text(
                            _finalGoalKm >= 1
                                ? '${_finalGoalKm.toStringAsFixed(1)} km'
                                : '${(_finalGoalKm * 1000).toInt()} m',
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '今は無理のない距離からスタートします。この目標は後で変更できます。',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _finalGoalKm,
                        min: 0.5,
                        max: 21.0,
                        divisions: 41,
                        onChanged: (v) =>
                            setState(() => _finalGoalKm = v),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '500m',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '21km（ハーフ）',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // ---- 最初の目標距離説明 ----
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.directions_walk,
                              color: colorScheme.secondary,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '最初の目標距離は 500m からスタートします。'
                                '達成を重ねることで少しずつ伸びていきます。',
                                style: textTheme.bodySmall?.copyWith(
                                  height: 1.5,
                                ),
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
            ),

            // ---- フッターボタン ----
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(color: colorScheme.outlineVariant),
                ),
              ),
              child: PrimaryButton(
                label: '次へ',
                onPressed: _onNext,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
