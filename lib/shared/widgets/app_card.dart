import 'package:flutter/material.dart';

/// アプリ共通カードウィジェット（T-0.4.4）
///
/// ThemeData.cardTheme の設定を継承しつつ、
/// アプリ全体で一貫した余白・角丸を提供する。
///
/// 使い方:
/// ```dart
/// AppCard(child: Text('内容'));
/// AppCard(padding: EdgeInsets.all(20), child: Column(...));
/// AppCard.elevated(child: Text('影付き'));
/// ```
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    super.key,
  }) : _elevated = false;

  /// 軽い影付きカード（重要な情報のハイライトに使用）
  const AppCard.elevated({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    super.key,
  }) : _elevated = true;

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool _elevated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 影のレベル: 通常=0、elevated=2
    final elevation = _elevated ? 2.0 : 0.0;

    final cardWidget = Card(
      elevation: elevation,
      shadowColor: _elevated
          ? theme.colorScheme.shadow.withValues(alpha: 0.12)
          : Colors.transparent,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: cardWidget,
      );
    }

    return cardWidget;
  }
}
