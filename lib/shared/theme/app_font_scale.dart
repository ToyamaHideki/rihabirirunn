/// 文字サイズスケール（T-0.4.3）
/// 設定画面で 4段階（小/中/大/特大）を選択できる
enum FontScale {
  small,
  medium,
  large,
  xlarge,
}

extension FontScaleExtension on FontScale {
  /// textScaleFactor に相当する倍率
  double get factor {
    switch (this) {
      case FontScale.small:
        return 0.85;
      case FontScale.medium:
        return 1.0;
      case FontScale.large:
        return 1.15;
      case FontScale.xlarge:
        return 1.35;
    }
  }

  /// DB / UserSettings に保存する文字列キー
  String get key {
    switch (this) {
      case FontScale.small:
        return 'small';
      case FontScale.medium:
        return 'medium';
      case FontScale.large:
        return 'large';
      case FontScale.xlarge:
        return 'xlarge';
    }
  }

  /// 設定画面に表示するラベル
  String get label {
    switch (this) {
      case FontScale.small:
        return '小';
      case FontScale.medium:
        return '中';
      case FontScale.large:
        return '大';
      case FontScale.xlarge:
        return '特大';
    }
  }

  /// DB の文字列から復元
  static FontScale fromKey(String key) {
    return FontScale.values.firstWhere(
      (e) => e.key == key,
      orElse: () => FontScale.medium,
    );
  }
}
