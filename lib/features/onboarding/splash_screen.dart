import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/repositories/user_profile_repository.dart';
import '../../shared/router/app_routes.dart';

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
    } else {
      // 2回目以降 → ホームへ
      context.go(AppRoutes.home);
    }
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
              'リハビリラン',
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
