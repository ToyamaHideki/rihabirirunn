import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_routes.dart';

/// メイン画面共通シェル（T-0.3.2）
/// ホーム / 統計 / 履歴 / 設定 の4タブ下部ナビゲーションを提供する
class MainShell extends StatelessWidget {
  const MainShell({required this.child, super.key});

  final Widget child;

  static const _tabs = [
    _TabItem(icon: Icons.home_outlined,      activeIcon: Icons.home,           label: 'ホーム',  route: AppRoutes.home),
    _TabItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart,      label: '統計',    route: AppRoutes.statistics),
    _TabItem(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month, label: '履歴', route: AppRoutes.history),
    _TabItem(icon: Icons.settings_outlined,  activeIcon: Icons.settings,       label: '設定',    route: AppRoutes.settings),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(AppRoutes.statistics)) return 1;
    if (location.startsWith(AppRoutes.history))    return 2;
    if (location.startsWith(AppRoutes.settings))   return 3;
    return 0; // ホームをデフォルト
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          context.go(_tabs[index].route);
        },
        destinations: _tabs
            .map(
              (tab) => NavigationDestination(
                icon: Icon(tab.icon),
                selectedIcon: Icon(tab.activeIcon),
                label: tab.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _TabItem {
  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
}
