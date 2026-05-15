import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../database/database.dart';
import '../../shared/repositories/user_profile_repository.dart';
import '../../shared/router/app_routes.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/primary_button.dart';

/// ホーム画面用プロファイル取得プロバイダ
final _homeProfileProvider = FutureProvider<UserProfile?>((ref) {
  return ref.watch(userProfileRepositoryProvider).getProfile();
});

/// S10: ホーム画面
///
/// - 今日の目標距離カード
/// - リハビリ目標メモ
/// - ルート設定へのスタートボタン
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final profileAsync = ref.watch(_homeProfileProvider);

    final profile = profileAsync.valueOrNull;
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
            Text('リハビリラン', style: textTheme.titleLarge),
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
