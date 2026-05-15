import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../database/database.dart';
import '../../shared/repositories/user_profile_repository.dart';
import '../../shared/repositories/user_settings_repository.dart';
import '../../shared/theme/app_font_scale.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/primary_button.dart';

// ---------------------------------------------------------------------------
// S53: 表示設定画面
// ---------------------------------------------------------------------------

/// T-4.1.4: 表示設定画面
///
/// テーマ（ソフト/シンプル）と文字サイズ（4段階）を変更する。
/// 変更は Riverpod プロバイダに即時反映され、DB にも保存される。
class DisplaySettingsScreen extends ConsumerStatefulWidget {
  const DisplaySettingsScreen({super.key});

  @override
  ConsumerState<DisplaySettingsScreen> createState() =>
      _DisplaySettingsScreenState();
}

class _DisplaySettingsScreenState
    extends ConsumerState<DisplaySettingsScreen> {
  DesignTheme _selectedTheme = DesignTheme.soft;
  FontScale _selectedScale = FontScale.medium;

  String? _profileId;
  UserSetting? _currentSettings;
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
    if (profile == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    final settings = await ref
        .read(userSettingsRepositoryProvider)
        .getByUserId(profile.id);
    if (mounted) {
      setState(() {
        _profileId = profile.id;
        _currentSettings = settings;
        if (settings != null) {
          _selectedTheme =
              DesignThemeExtension.fromKey(settings.designTheme);
          _selectedScale =
              FontScaleExtension.fromKey(settings.fontSize);
        } else {
          // Riverpod の現在値をフォールバックとして使用
          _selectedTheme = ref.read(designThemeProvider);
          _selectedScale = ref.read(fontScaleProvider);
        }
        _isLoading = false;
      });
    }
  }

  /// テーマ or フォントスケールを変更し Riverpod に即時反映
  void _onThemeChanged(DesignTheme theme) {
    setState(() => _selectedTheme = theme);
    ref.read(designThemeProvider.notifier).state = theme;
  }

  void _onScaleChanged(FontScale scale) {
    setState(() => _selectedScale = scale);
    ref.read(fontScaleProvider.notifier).state = scale;
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(userSettingsRepositoryProvider);
      if (_currentSettings != null) {
        await repo.updateSettings(
          _currentSettings!.id,
          designTheme: _selectedTheme.key,
          fontSize: _selectedScale.key,
        );
      } else if (_profileId != null) {
        await repo.createSettings(
          userId: _profileId!,
          designTheme: _selectedTheme.key,
          fontSize: _selectedScale.key,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('表示設定を保存しました')),
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
        appBar: AppBar(title: const Text('表示・文字サイズ')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('表示・文字サイズ'),
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
                  // ---- テーマ選択 ----
                  Text('テーマ', style: textTheme.labelLarge),
                  const SizedBox(height: 8),
                  _ThemeSelector(
                    selected: _selectedTheme,
                    onChanged: _onThemeChanged,
                  ),

                  const SizedBox(height: 28),

                  // ---- 文字サイズ ----
                  Text('文字サイズ', style: textTheme.labelLarge),
                  const SizedBox(height: 8),
                  _FontScaleSelector(
                    selected: _selectedScale,
                    onChanged: _onScaleChanged,
                  ),

                  const SizedBox(height: 24),

                  // ---- プレビュー ----
                  Text('プレビュー', style: textTheme.labelLarge),
                  const SizedBox(height: 8),
                  AppCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('今日の目標', style: textTheme.labelLarge),
                          const SizedBox(height: 4),
                          Text(
                            '1.2 km',
                            style: textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '右膝 リハビリ中',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
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
// テーマ選択ウィジェット
// ---------------------------------------------------------------------------

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({
    required this.selected,
    required this.onChanged,
  });

  final DesignTheme selected;
  final ValueChanged<DesignTheme> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: DesignTheme.values.map((theme) {
        final isSelected = selected == theme;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => onChanged(theme),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                      size: 20,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      theme.label,
                      style: textTheme.labelMedium?.copyWith(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// フォントスケール選択ウィジェット
// ---------------------------------------------------------------------------

class _FontScaleSelector extends StatelessWidget {
  const _FontScaleSelector({
    required this.selected,
    required this.onChanged,
  });

  final FontScale selected;
  final ValueChanged<FontScale> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: FontScale.values.map((scale) {
        final isSelected = selected == scale;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () => onChanged(scale),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'あ',
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 14 * scale.factor,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scale.label,
                      style: textTheme.labelSmall?.copyWith(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
