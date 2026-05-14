import 'package:flutter/material.dart';

/// アプリ共通の主要アクションボタン（T-0.4.4）
///
/// 使い方:
/// ```dart
/// PrimaryButton(label: 'スタート', onPressed: () { ... });
/// PrimaryButton(label: '読み込み中', onPressed: null); // disabled
/// PrimaryButton.outlined(label: '別ルートを作成', onPressed: () { ... });
/// ```
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    super.key,
  }) : _outlined = false;

  /// アウトラインスタイルのボタン
  const PrimaryButton.outlined({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    super.key,
  }) : _outlined = true;

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final bool _outlined;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon!,
                  const SizedBox(width: 8),
                  Text(label),
                ],
              )
            : Text(label);

    if (_outlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: child,
      );
    }

    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: child,
    );
  }
}
