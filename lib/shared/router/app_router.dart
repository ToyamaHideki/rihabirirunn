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

      // ---- オンボーディング ----
      GoRoute(
        path: AppRoutes.disclaimer,
        builder: (_, _) => const DisclaimerScreen(),
      ),
      GoRoute(
        path: AppRoutes.setup,
        builder: (_, _) => const SetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.design,
        builder: (_, _) => const DesignScreen(),
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
                builder: (_, state) => RunDetailScreen(
                  sessionId: state.pathParameters['sessionId']!,
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
                builder: (_, _) => const ModeSettingsScreen(),
              ),
              GoRoute(
                path: 'body-info',
                builder: (_, _) => const BodyInfoScreen(),
              ),
              GoRoute(
                path: 'display',
                builder: (_, _) => const DisplaySettingsScreen(),
              ),
              GoRoute(
                path: 'data',
                builder: (_, _) => const DataManagementScreen(),
              ),
              GoRoute(
                path: 'notifications',
                builder: (_, _) => const NotificationSettingsScreen(),
              ),
              GoRoute(
                path: 'terms',
                builder: (_, _) => const TermsScreen(),
              ),
              GoRoute(
                path: 'privacy',
                builder: (_, _) => const PrivacyScreen(),
              ),
              GoRoute(
                path: 'app-info',
                builder: (_, _) => const AppInfoScreen(),
              ),
            ],
          ),
        ],
      ),

      // ---- 走行フロー（フルスクリーン、シェル外） ----
      GoRoute(
        path: AppRoutes.routeSetting,
        builder: (_, _) => const RouteSettingScreen(),
      ),
      GoRoute(
        path: AppRoutes.routePreview,
        builder: (_, _) => const RoutePreviewScreen(),
      ),
      GoRoute(
        path: AppRoutes.conditionPre,
        builder: (_, _) => const ConditionScreen(timing: 'before'),
      ),
      GoRoute(
        path: AppRoutes.activeRun,
        builder: (_, _) => const ActiveRunScreen(),
      ),
      GoRoute(
        path: AppRoutes.runSummary,
        builder: (_, state) => RunSummaryScreen(
          sessionId: state.pathParameters['sessionId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.conditionPost,
        builder: (_, _) => const ConditionScreen(timing: 'after'),
      ),
    ],

    // 存在しないパスへの遷移時はホームへリダイレクト
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('画面が見つかりません: ${state.error}')),
    ),
  );
});
