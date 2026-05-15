import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../database/database.dart';
import '../../shared/repositories/user_profile_repository.dart';
import '../../shared/repositories/user_settings_repository.dart';
import '../../shared/router/app_routes.dart';
import '../../shared/theme/app_font_scale.dart';
import '../../shared/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Riverpod プロバイダ
// ---------------------------------------------------------------------------

final _settingsProfileProvider = FutureProvider<UserProfile?>((ref) {
  return ref.watch(userProfileRepositoryProvider).getProfile();
});

final _settingsUserSettingsProvider = FutureProvider<UserSetting?>((ref) async {
  final profile = await ref.watch(_settingsProfileProvider.future);
  if (profile == null) return null;
  return ref.read(userSettingsRepositoryProvider).getByUserId(profile.id);
});

// ---------------------------------------------------------------------------
// S50: 設定トップ画面
// ---------------------------------------------------------------------------

/// S50: 設定
///
/// T-4.1.1: 設定トップ画面
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final profile = ref.watch(_settingsProfileProvider).valueOrNull;
    final settings = ref.watch(_settingsUserSettingsProvider).valueOrNull;

    // ---- モードラベル ----
    final String modeLabel;
    switch (profile?.mode) {
      case 'conservative':
        modeLabel = '保守モード';
      case 'challenge':
        modeLabel = 'チャレンジモード';
      case 'custom':
        modeLabel = 'カスタムモード';
      default:
        modeLabel = '標準モード';
    }

    // ---- 身体情報サブタイトル ----
    String bodySubtitle = '未設定';
    if (profile != null) {
      final parts = <String>[];
      if (profile.age != null) parts.add('${profile.age}歳');
      if (profile.rehabTarget != null && profile.rehabTarget!.isNotEmpty) {
        final target = profile.rehabTarget!;
        parts.add(target.length > 12 ? '${target.substring(0, 12)}…' : target);
      }
      if (parts.isNotEmpty) bodySubtitle = parts.join(' / ');
    }

    // ---- 表示設定サブタイトル ----
    String displaySubtitle = '';
    if (settings != null) {
      final themeLabel =
          DesignThemeExtension.fromKey(settings.designTheme).label;
      final fontLabel =
          FontScaleExtension.fromKey(settings.fontSize).label;
      displaySubtitle = '$themeLabel / $fontLabel';
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('設定'),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          // ---- 機能設定 ----
          const _SectionHeader(label: '機能設定'),
          _SettingsTile(
            icon: Icons.directions_run_rounded,
            title: '距離モード',
            subtitle: modeLabel,
            onTap: () => context.push(AppRoutes.modeSettings),
          ),
          _SettingsTile(
            icon: Icons.person_rounded,
            title: '身体情報',
            subtitle: bodySubtitle,
            onTap: () => context.push(AppRoutes.bodyInfo),
          ),
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: '表示・文字サイズ',
            subtitle: displaySubtitle.isNotEmpty ? displaySubtitle : null,
            onTap: () => context.push(AppRoutes.displaySettings),
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: '通知',
            subtitle: 'Phase 2 で対応予定',
            onTap: null,
            enabled: false,
          ),
          _SettingsTile(
            icon: Icons.save_outlined,
            title: 'データ管理',
            subtitle: 'エクスポート / インポート',
            onTap: () => context.push(AppRoutes.dataManagement),
          ),
          const Divider(indent: 16, endIndent: 16, height: 8),

          // ---- サポート・情報 ----
          const _SectionHeader(label: 'サポート・情報'),
          _SettingsTile(
            icon: Icons.article_outlined,
            title: '利用規約',
            onTap: () => context.push(AppRoutes.termsOfService),
          ),
          _SettingsTile(
            icon: Icons.lock_outline_rounded,
            title: 'プライバシーポリシー',
            onTap: () => context.push(AppRoutes.privacyPolicy),
          ),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'アプリ情報',
            onTap: () => context.push(AppRoutes.appInfo),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ヘルパーウィジェット
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor =
        enabled ? colorScheme.primary : colorScheme.outlineVariant;
    final textColor =
        enabled ? colorScheme.onSurface : colorScheme.outlineVariant;

    return ListTile(
      leading: Icon(icon, color: iconColor, size: 22),
      title: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(color: textColor),
      ),
      subtitle: subtitle != null && subtitle!.isNotEmpty
          ? Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: enabled
            ? colorScheme.onSurfaceVariant
            : colorScheme.outlineVariant,
        size: 20,
      ),
      onTap: enabled ? onTap : null,
    );
  }
}
