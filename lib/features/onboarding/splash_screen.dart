import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/repositories/user_profile_repository.dart';
import '../../shared/router/app_routes.dart';
import '../../shared/services/run_snapshot_service.dart';

/// S00: スプラッシュ画面
/// 起動時に2秒表示しつつ、初回起動か否かを判定して遷移先を決定する
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // スプラッシュを最低2秒表示
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // DB にプロフィールが存在するか確認（T-0.3.3: 初回起動判定）
    final profile =
        await ref.read(userProfileRepositoryProvider).getProfile();

    if (!mounted) return;

    if (profile == null) {
      // 初回起動 → オンボーディングへ
      context.go(AppRoutes.disclaimer);
      return;
    }

    // T-2.3.2: 中断走行スナップショットの確認
    final snapshot = await ref.read(runSnapshotServiceProvider).load();
    if (!mounted) return;

    if (snapshot != null) {
      await _showInterruptedRunDialog(snapshot);
      if (!mounted) return;
    }

    context.go(AppRoutes.home);
  }

  /// T-2.3.2: 中断走行ダイアログ — 破棄のみ選択可能（DB 保存は T-2.4 で対応）
  Future<void> _showInterruptedRunDialog(RunSnapshot snapshot) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('中断された走行があります'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('前回の走行データが残っています。'),
            const SizedBox(height: 12),
            _SnapshotInfoRow(
              icon: Icons.straighten_rounded,
              label: '距離',
              value: snapshot.formattedDistance,
            ),
            const SizedBox(height: 4),
            _SnapshotInfoRow(
              icon: Icons.schedule_rounded,
              label: '経過時間',
              value: snapshot.formattedElapsed,
            ),
          ],
        ),
        actions: [
          FilledButton.icon(
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('破棄する'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            onPressed: () async {
              await ref.read(runSnapshotServiceProvider).clear();
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_walk, size: 80, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'リハビリウォーク',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ダイアログ内サブウィジェット
// ---------------------------------------------------------------------------

class _SnapshotInfoRow extends StatelessWidget {
  const _SnapshotInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: textTheme.bodySmall
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        Text(
          value,
          style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
