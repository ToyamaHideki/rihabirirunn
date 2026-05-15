import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../database/database.dart';
import '../../shared/repositories/user_profile_repository.dart';
import '../../shared/router/app_routes.dart';
import '../../shared/services/streak_service.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/primary_button.dart';

// ---------------------------------------------------------------------------
// Riverpod プロバイダ
// ---------------------------------------------------------------------------

/// ホーム画面用プロファイル取得プロバイダ
final _homeProfileProvider = FutureProvider<UserProfile?>((ref) {
  return ref.watch(userProfileRepositoryProvider).getProfile();
});

/// T-3.4: ストリーク・直近7日データプロバイダ
final _homeStreakProvider = FutureProvider<StreakData?>((ref) async {
  final profile = await ref.watch(_homeProfileProvider.future);
  if (profile == null) return null;
  return ref.read(streakServiceProvider).getStreakData(profile.id);
});

// ---------------------------------------------------------------------------
// S10: ホーム画面
// ---------------------------------------------------------------------------

/// S10: ホーム（ダッシュボード）
///
/// T-3.4.2: ストリーク表示（N日連続）
/// T-3.4.3: 直近1週間の達成ドット表示
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final profileAsync = ref.watch(_homeProfileProvider);
    final streakAsync = ref.watch(_homeStreakProvider);

    final profile = profileAsync.valueOrNull;
    final streak = streakAsync.valueOrNull;

    // 目標距離（m → km 変換）
    final targetKm = (profile?.currentTargetDistance ?? 500.0) / 1000.0;
    final rehabTarget = profile?.rehabTarget;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.directions_walk, color: colorScheme.primary, size: 24),
            const SizedBox(width: 8),
            Text('リハビリウォーク', style: textTheme.titleLarge),
          ],
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---- 今日の目標カード ----
            AppCard(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.flag_rounded,
                            color: colorScheme.primary, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          '今日の目標',
                          style: textTheme.labelLarge
                              ?.copyWith(color: colorScheme.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: targetKm.toStringAsFixed(
                                targetKm < 1.0 ? 2 : 1),
                            style: textTheme.displaySmall?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: ' km',
                            style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    if (rehabTarget != null && rehabTarget.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        rehabTarget,
                        style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ---- T-3.4.3: 直近1週間の達成ドット + T-3.4.2: ストリーク ----
            AppCard(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: streak == null
                    ? const _StreakPlaceholder()
                    : _StreakSection(data: streak),
              ),
            ),

            const SizedBox(height: 16),

            // ---- ヒントカード ----
            AppCard(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline_rounded,
                        color: colorScheme.secondary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '無理をせず、体調に合わせてペースを調整しましょう。',
                        style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ---- スタートボタン ----
            PrimaryButton(
              icon: const Icon(Icons.map_outlined),
              label: 'ルートを設定して歩く',
              onPressed: () => context.push(AppRoutes.routeSetting),
            ),

            const SizedBox(height: 12),

            // ---- 履歴確認ボタン（サブアクション）----
            OutlinedButton.icon(
              icon: const Icon(Icons.history_rounded, size: 18),
              label: const Text('過去の記録を見る'),
              onPressed: () => context.go(AppRoutes.history),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// T-3.4.2 / T-3.4.3: ストリークセクション
// ---------------------------------------------------------------------------

class _StreakSection extends StatelessWidget {
  const _StreakSection({required this.data});
  final StreakData data;

  String _fmtDist(double m) {
    if (m >= 1000) return '${(m / 1000).toStringAsFixed(1)} km';
    return '${m.round()} m';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // weeklyStatus は古い順（key = day, sorted by day）
    final days = data.weeklyStatus.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- T-3.4.3: 7日間ドット ----
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: days.map((day) {
            final status = data.weeklyStatus[day];
            final dayLabel = DateFormat('E', 'ja').format(day); // 月火水…
            final isToday = DateUtils.isSameDay(day, DateTime.now());

            return _WeekDot(
              label: dayLabel,
              status: status,
              isToday: isToday,
            );
          }).toList(),
        ),

        const SizedBox(height: 12),

        // ---- T-3.4.2: 累計距離 ／ N日連続 ----
        Row(
          children: [
            Icon(Icons.emoji_events_rounded,
                size: 18, color: colorScheme.primary),
            const SizedBox(width: 6),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: textTheme.bodyMedium,
                  children: [
                    TextSpan(
                      text: '累計 ',
                      style: TextStyle(
                          color: colorScheme.onSurfaceVariant),
                    ),
                    TextSpan(
                      text: _fmtDist(data.totalDistanceM),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (data.streak > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${data.streak}日連続 🔥',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ] else ...[
              Text(
                '今日から記録を始めよう！',
                style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 7日間ドット（1つのセル）
// ---------------------------------------------------------------------------

class _WeekDot extends StatelessWidget {
  const _WeekDot({
    required this.label,
    required this.status,
    required this.isToday,
  });

  final String label;

  /// true=達成, false=走行(未達成), null=走行なし
  final bool? status;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // ドット色
    final Color dotColor;
    final bool filled;
    if (status == null) {
      dotColor = colorScheme.outlineVariant;
      filled = false;
    } else if (status!) {
      dotColor = colorScheme.primary;
      filled = true;
    } else {
      dotColor = Colors.orange;
      filled = false; // 走行したが未達成 → 外枠のみ
    }

    // T-4.3.3: スクリーンリーダー向けラベル
    final String semanticLabel;
    if (status == null) {
      semanticLabel = '$label 走行なし';
    } else if (status!) {
      semanticLabel = '$label 目標達成';
    } else {
      semanticLabel = '$label 走行・未達成';
    }

    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ドット
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled ? dotColor : null,
              border: Border.all(
                color: dotColor,
                width: status == null ? 1.0 : 2.0,
              ),
            ),
          ),
          const SizedBox(height: 4),
          // 曜日ラベル
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: isToday
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ストリークデータ読み込み中のプレースホルダー
// ---------------------------------------------------------------------------

class _StreakPlaceholder extends StatelessWidget {
  const _StreakPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 12),
        Text(
          '記録を読み込んでいます…',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
