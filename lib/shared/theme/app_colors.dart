import 'package:flutter/material.dart';

/// ソフト系テーマのカラー定数
/// ベース: 白/淡いベージュ, アクセント: 優しい緑・水色
abstract class SoftPalette {
  static const primary = Color(0xFF4CAF82);           // 優しい緑
  static const primaryContainer = Color(0xFFB8E6D2);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onPrimaryContainer = Color(0xFF0A3D26);

  static const secondary = Color(0xFF7EC8C8);          // 優しい水色
  static const secondaryContainer = Color(0xFFCAEEEE);
  static const onSecondary = Color(0xFFFFFFFF);
  static const onSecondaryContainer = Color(0xFF0A3535);

  static const error = Color(0xFFE57373);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF410002);

  static const background = Color(0xFFFAFAF7);         // 淡いベージュ白
  static const onBackground = Color(0xFF2D2D2D);
  static const surface = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF2D2D2D);
  static const surfaceVariant = Color(0xFFF0F0EC);
  static const onSurfaceVariant = Color(0xFF555550);
  static const outline = Color(0xFFCCCBC5);
  static const outlineVariant = Color(0xFFE0DFD9);
}

/// シンプル系テーマのカラー定数
/// ベース: 純白, アクセント: クリアな緑・青
abstract class SimplePalette {
  static const primary = Color(0xFF2E7D52);            // クリアな緑
  static const primaryContainer = Color(0xFF9DE8C0);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onPrimaryContainer = Color(0xFF002116);

  static const secondary = Color(0xFF0277BD);          // 清潔な青
  static const secondaryContainer = Color(0xFFB3E5FC);
  static const onSecondary = Color(0xFFFFFFFF);
  static const onSecondaryContainer = Color(0xFF001C2E);

  static const error = Color(0xFFD32F2F);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF410002);

  static const background = Color(0xFFFFFFFF);         // 純白
  static const onBackground = Color(0xFF1A1A1A);
  static const surface = Color(0xFFF8F8F8);
  static const onSurface = Color(0xFF1A1A1A);
  static const surfaceVariant = Color(0xFFEEEEEE);
  static const onSurfaceVariant = Color(0xFF444444);
  static const outline = Color(0xFFCCCCCC);
  static const outlineVariant = Color(0xFFE5E5E5);
}
