import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/repositories/user_profile_repository.dart';
import '../../shared/repositories/user_settings_repository.dart';
import '../../shared/router/app_routes.dart';
import '../../shared/theme/app_font_scale.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/primary_button.dart';

/// S03: デザイン・文字サイズ選択画面
///
/// ユーザーが選択したテーマ・フォントスケールを:
/// - UserSettings DB に保存
/// - Riverpod の designThemeProvider / fontScaleProvider に即時反映
/// - HomeScreen へ遷移
class DesignScreen extends ConsumerStatefulWidget {
  const DesignScreen({super.key});

  @override
  ConsumerState<DesignScreen> createState() => _DesignScreenState();
}

class _DesignScreenState extends ConsumerState<DesignScreen> {
  DesignTheme _selectedTheme = DesignTheme.soft;
  FontScale _selectedScale = FontScale.medium;
  bool _isLoading = false;

  Future<void> _onStart() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final profileRepo = ref.read(userProfileRepositoryProvider);
      final settingsRepo = ref.read(userSettingsRepositoryProvider);

      final profile = await profileRepo.getProfile();
      if (profile == null) {
        if (!mounted) return;
        context.go(AppRoutes.disclaimer);
        return;
      }

      // DB に設定を保存
      await settingsRepo.createSettings(
        userId: profile.id,
        designTheme: _selectedTheme.key,
        fontSize: _selectedScale.key,
      );

      // Riverpod プロバイダに即時反映（アプリ全体のテーマが切り替わる）
      ref.read(designThemeProvider.notifier).state = _selectedTheme;
      ref.read(fontScaleProvider.notifier).state = _selectedScale;

      if (!mounted) return;
      context.go(AppRoutes.home);
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
        title: const Text('見た目の設定'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '使いやすい見た目を選んでください',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '設定画面からいつでも変更できます。',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ---- デザインテーマ選択 ----
                    Text(
                      'デザインテーマ',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ThemeCard(
                            label: 'ソフト',
                            description: '優しい緑と水色。\n目に優しい柔らかな色使い。',
                            primaryColor: const Color(0xFF4CAF82),
                            accentColor: const Color(0xFF7EC8C8),
                            bgColor: const Color(0xFFFAFAF7),
                            isSelected: _selectedTheme == DesignTheme.soft,
                            onTap: () =>
                                setState(() => _selectedTheme = DesignTheme.soft),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ThemeCard(
                            label: 'シンプル',
                            description: '白地に濃い緑と青。\nすっきり見やすい配色。',
                            primaryColor: const Color(0xFF2E7D52),
                            accentColor: const Color(0xFF0277BD),
                            bgColor: const Color(0xFFFFFFFF),
                            isSelected: _selectedTheme == DesignTheme.simple,
                            onTap: () =>
                                setState(() => _selectedTheme = DesignTheme.simple),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // ---- フォントサイズ選択 ----
                    Text(
                      '文字の大きさ',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...FontScale.values.map(
                      (scale) => _FontScaleTile(
                        scale: scale,
                        isSelected: _selectedScale == scale,
                        onTap: () => setState(() => _selectedScale = scale),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ---- プレビュー ----
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'プレビュー',
                            style: textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '今日の目標距離',
                            style: textTheme.bodySmall?.apply(
                              fontSizeFactor: _selectedScale.factor,
                            ),
                          ),
                          Text(
                            '1,200 m',
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ).apply(fontSizeFactor: _selectedScale.factor),
                          ),
                          Text(
                            '無理なく一歩ずつ進みましょう。',
                            style: textTheme.bodyMedium?.apply(
                              fontSizeFactor: _selectedScale.factor,
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
                label: 'はじめる',
                onPressed: _onStart,
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

/// デザインテーマ選択カード
class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.label,
    required this.description,
    required this.primaryColor,
    required this.accentColor,
    required this.bgColor,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String description;
  final Color primaryColor;
  final Color accentColor;
  final Color bgColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? primaryColor : colorScheme.outlineVariant,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // カラースウォッチ
            Row(
              children: [
                _Swatch(primaryColor),
                const SizedBox(width: 4),
                _Swatch(accentColor),
                const Spacer(),
                if (isSelected)
                  Icon(Icons.check_circle, color: primaryColor, size: 18),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: textTheme.labelSmall?.copyWith(
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.color);
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// フォントスケール選択行
class _FontScaleTile extends StatelessWidget {
  const _FontScaleTile({
    required this.scale,
    required this.isSelected,
    required this.onTap,
  });

  final FontScale scale;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.5)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? colorScheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // ラジオ的なインジケーター
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.outline,
                  width: isSelected ? 5 : 2,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // ラベル
            SizedBox(
              width: 28,
              child: Text(
                scale.label,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // プレビューテキスト
            Text(
              'あいうえお Aa 123',
              style: textTheme.bodyMedium?.apply(
                fontSizeFactor: scale.factor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
