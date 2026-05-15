import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/active_run/active_run_screen.dart';
import '../../features/condition/condition_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/history/run_detail_screen.dart';
import '../../features/history/statistics_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/onboarding/design_screen.dart';
import '../../features/onboarding/disclaimer_screen.dart';
import '../../features/onboarding/setup_screen.dart';
import '../../features/onboarding/splash_screen.dart';
import '../../features/result/run_summary_screen.dart';
import '../../features/route_generation/route_preview_screen.dart';
import '../../features/route_generation/route_setting_screen.dart';
import '../../features/settings/app_info_screen.dart';
import '../../features/settings/body_info_screen.dart';
import '../../features/settings/data_management_screen.dart';
import '../../features/settings/display_settings_screen.dart';
import '../../features/settings/mode_settings_screen.dart';
import '../../features/settings/notification_settings_screen.dart';
import '../../features/settings/privacy_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings/terms_screen.dart';
import '../widgets/main_shell.dart';
import 'app_routes.dart';

/// GoRouter プロバイダ（Riverpod 経由で全画面から参照可能）
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      // ---- スプラッシュ（起動判定・T-0.3.3） ----
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, _) => const SplashScreen(),
      ),

      // ---- オンボーディング（T-4.3.1: スライドトランジション） ----
      GoRoute(
        path: AppRoutes.disclaimer,
        pageBuilder: (ctx, state) =>
            _slidePage(state, const DisclaimerScreen()),
      ),
      GoRoute(
        path: AppRoutes.setup,
        pageBuilder: (ctx, state) => _slidePage(state, const SetupScreen()),
      ),
      GoRoute(
        path: AppRoutes.design,
        pageBuilder: (ctx, state) =>
            _slidePage(state, const DesignScreen()),
      ),

      // ---- メイン：ボトムナビ付きシェル（T-0.3.2） ----
      ShellRoute(
        builder: (_, _, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_, _) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.statistics,
            builder: (_, _) => const StatisticsScreen(),
          ),
          GoRoute(
            path: AppRoutes.history,
            builder: (_, _) => const HistoryScreen(),
            routes: [
              GoRoute(
                path: ':sessionId',
                pageBuilder: (ctx, state) => _slidePage(
                  state,
                  RunDetailScreen(
                    sessionId: state.pathParameters['sessionId']!,
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (_, _) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'mode',
                pageBuilder: (ctx, state) =>
                    _slidePage(state, const ModeSettingsScreen()),
              ),
              GoRoute(
                path: 'body-info',
                pageBuilder: (ctx, state) =>
                    _slidePage(state, const BodyInfoScreen()),
              ),
              GoRoute(
                path: 'display',
                pageBuilder: (ctx, state) =>
                    _slidePage(state, const DisplaySettingsScreen()),
              ),
              GoRoute(
                path: 'data',
                pageBuilder: (ctx, state) =>
                    _slidePage(state, const DataManagementScreen()),
              ),
              GoRoute(
                path: 'notifications',
                pageBuilder: (ctx, state) =>
                    _slidePage(state, const NotificationSettingsScreen()),
              ),
              GoRoute(
                path: 'terms',
                pageBuilder: (ctx, state) =>
                    _slidePage(state, const TermsScreen()),
              ),
              GoRoute(
                path: 'privacy',
                pageBuilder: (ctx, state) =>
                    _slidePage(state, const PrivacyScreen()),
              ),
              GoRoute(
                path: 'app-info',
                pageBuilder: (ctx, state) =>
                    _slidePage(state, const AppInfoScreen()),
              ),
            ],
          ),
        ],
      ),

      // ---- 走行フロー（フルスクリーン、シェル外） ----
      GoRoute(
        path: AppRoutes.routeSetting,
        pageBuilder: (ctx, state) =>
            _slidePage(state, const RouteSettingScreen()),
      ),
      GoRoute(
        path: AppRoutes.routePreview,
        pageBuilder: (ctx, state) =>
            _slidePage(state, const RoutePreviewScreen()),
      ),
      GoRoute(
        path: AppRoutes.conditionPre,
        pageBuilder: (ctx, state) =>
            _slidePage(state, const ConditionScreen(timing: 'before')),
      ),
      GoRoute(
        path: AppRoutes.activeRun,
        pageBuilder: (ctx, state) =>
            _slidePage(state, const ActiveRunScreen()),
      ),
      GoRoute(
        path: AppRoutes.runSummary,
        pageBuilder: (ctx, state) => _slidePage(
          state,
          RunSummaryScreen(
            sessionId: state.pathParameters['sessionId']!,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.conditionPost,
        pageBuilder: (ctx, state) =>
            _slidePage(state, const ConditionScreen(timing: 'after')),
      ),
    ],

    // 存在しないパスへの遷移時はホームへリダイレクト
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('画面が見つかりません: ${state.error}')),
    ),
  );
});

// ---------------------------------------------------------------------------
// T-4.3.1: スライドトランジション（右から左、250ms、easeOutCubic）
// ---------------------------------------------------------------------------

CustomTransitionPage<void> _slidePage(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeOutCubic)),
            ),
            child: child,
          ),
    );
