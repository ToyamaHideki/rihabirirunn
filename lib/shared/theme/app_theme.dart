import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_font_scale.dart';

/// デザインテーマ種別
/// DB の UserSettings.designTheme に対応
enum DesignTheme {
  soft,   // ソフト系: 淡い色使い、優しい雰囲気
  simple, // シンプル系: 高コントラスト、すっきり
}

extension DesignThemeExtension on DesignTheme {
  /// DB / UserSettings に保存する文字列キー
  String get key {
    switch (this) {
      case DesignTheme.soft:
        return 'soft';
      case DesignTheme.simple:
        return 'simple';
    }
  }

  /// 設定画面に表示するラベル
  String get label {
    switch (this) {
      case DesignTheme.soft:
        return 'ソフト';
      case DesignTheme.simple:
        return 'シンプル';
    }
  }

  /// DB の文字列から復元
  static DesignTheme fromKey(String key) {
    return DesignTheme.values.firstWhere(
      (e) => e.key == key,
      orElse: () => DesignTheme.soft,
    );
  }
}

// ---- Riverpod プロバイダ ----

/// 選択中のデザインテーマ
/// T-0.5.4 でオンボーディング、T-4.1.4 でリアルタイム変更対応予定
final designThemeProvider = StateProvider<DesignTheme>((ref) => DesignTheme.soft);

/// 選択中のフォントスケール
final fontScaleProvider = StateProvider<FontScale>((ref) => FontScale.medium);

/// 現在の設定に基づいて ThemeData を組み立てるプロバイダ
final appThemeProvider = Provider<ThemeData>((ref) {
  final design = ref.watch(designThemeProvider);
  final scale = ref.watch(fontScaleProvider);
  return AppTheme.build(design, scale);
});

// ---- テーマ組み立てロジック ----

abstract class AppTheme {
  /// [design] と [fontScale] から ThemeData を生成する
  static ThemeData build(DesignTheme design, FontScale fontScale) {
    final colorScheme = design == DesignTheme.soft
        ? _softColorScheme()
        : _simpleColorScheme();
    final textTheme = _buildTextTheme(fontScale.factor);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),

      // 主ボタン（FilledButton）
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // テキストボタン
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(44, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),

      // アウトラインボタン
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),

      // カード
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        color: colorScheme.surface,
        margin: EdgeInsets.zero,
      ),

      // 下部ナビゲーション
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.onPrimaryContainer);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final base = textTheme.labelSmall ?? const TextStyle();
          if (states.contains(WidgetState.selected)) {
            return base.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            );
          }
          return base.copyWith(color: colorScheme.onSurfaceVariant);
        }),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),

      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        thumbColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.primaryContainer,
        overlayColor: colorScheme.primary.withValues(alpha: 0.15),
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // ---- ColorScheme 組み立て ----

  static ColorScheme _softColorScheme() {
    return ColorScheme(
      brightness: Brightness.light,
      primary: SoftPalette.primary,
      onPrimary: SoftPalette.onPrimary,
      primaryContainer: SoftPalette.primaryContainer,
      onPrimaryContainer: SoftPalette.onPrimaryContainer,
      secondary: SoftPalette.secondary,
      onSecondary: SoftPalette.onSecondary,
      secondaryContainer: SoftPalette.secondaryContainer,
      onSecondaryContainer: SoftPalette.onSecondaryContainer,
      error: SoftPalette.error,
      onError: SoftPalette.onError,
      errorContainer: SoftPalette.errorContainer,
      onErrorContainer: SoftPalette.onErrorContainer,
      surface: SoftPalette.surface,
      onSurface: SoftPalette.onSurface,
      surfaceContainerHighest: SoftPalette.surfaceVariant,
      onSurfaceVariant: SoftPalette.onSurfaceVariant,
      outline: SoftPalette.outline,
      outlineVariant: SoftPalette.outlineVariant,
    );
  }

  static ColorScheme _simpleColorScheme() {
    return ColorScheme(
      brightness: Brightness.light,
      primary: SimplePalette.primary,
      onPrimary: SimplePalette.onPrimary,
      primaryContainer: SimplePalette.primaryContainer,
      onPrimaryContainer: SimplePalette.onPrimaryContainer,
      secondary: SimplePalette.secondary,
      onSecondary: SimplePalette.onSecondary,
      secondaryContainer: SimplePalette.secondaryContainer,
      onSecondaryContainer: SimplePalette.onSecondaryContainer,
      error: SimplePalette.error,
      onError: SimplePalette.onError,
      errorContainer: SimplePalette.errorContainer,
      onErrorContainer: SimplePalette.onErrorContainer,
      surface: SimplePalette.surface,
      onSurface: SimplePalette.onSurface,
      surfaceContainerHighest: SimplePalette.surfaceVariant,
      onSurfaceVariant: SimplePalette.onSurfaceVariant,
      outline: SimplePalette.outline,
      outlineVariant: SimplePalette.outlineVariant,
    );
  }

  // ---- TextTheme 組み立て ----

  /// M PLUS Rounded 1c（丸ゴシック系）をベースに fontScale 倍率を適用
  static TextTheme _buildTextTheme(double scale) {
    // google_fonts の M PLUS Rounded 1c ファミリーを使用
    final base = GoogleFonts.mPlusRounded1cTextTheme();

    // 各スタイルに倍率を適用して返す
    return base.copyWith(
      displayLarge: base.displayLarge?.apply(fontSizeFactor: scale),
      displayMedium: base.displayMedium?.apply(fontSizeFactor: scale),
      displaySmall: base.displaySmall?.apply(fontSizeFactor: scale),
      headlineLarge: base.headlineLarge?.apply(fontSizeFactor: scale),
      headlineMedium: base.headlineMedium?.apply(fontSizeFactor: scale),
      headlineSmall: base.headlineSmall?.apply(fontSizeFactor: scale),
      titleLarge: base.titleLarge?.apply(fontSizeFactor: scale),
      titleMedium: base.titleMedium?.apply(fontSizeFactor: scale),
      titleSmall: base.titleSmall?.apply(fontSizeFactor: scale),
      bodyLarge: base.bodyLarge?.apply(fontSizeFactor: scale),
      bodyMedium: base.bodyMedium?.apply(fontSizeFactor: scale),
      bodySmall: base.bodySmall?.apply(fontSizeFactor: scale),
      labelLarge: base.labelLarge?.apply(fontSizeFactor: scale),
      labelMedium: base.labelMedium?.apply(fontSizeFactor: scale),
      labelSmall: base.labelSmall?.apply(fontSizeFactor: scale),
    );
  }
}
