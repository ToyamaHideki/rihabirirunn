import 'package:drift/drift.dart';

import 'user_profiles.dart';

/// ユーザー設定テーブル
/// UserProfile と 1:1 関係
class UserSettings extends Table {
  TextColumn get id => text()();

  /// UserProfiles FK
  TextColumn get userId =>
      text().references(UserProfiles, #id, onDelete: KeyAction.cascade)();

  /// デザインテーマ: soft / simple
  TextColumn get designTheme =>
      text().withDefault(const Constant('soft'))();

  /// 文字サイズ: small / medium / large / xlarge
  TextColumn get fontSize =>
      text().withDefault(const Constant('medium'))();

  /// プッシュ通知全体 ON/OFF
  BoolColumn get notificationEnabled =>
      boolean().withDefault(const Constant(true))();

  /// ストリーク警告通知
  BoolColumn get streakAlertEnabled =>
      boolean().withDefault(const Constant(true))();

  /// 天気警告通知（フェーズ2機能）
  BoolColumn get weatherAlertEnabled =>
      boolean().withDefault(const Constant(false))();

  /// GPS 軌跡を Mapbox Map Matching API で道路にスナップするか
  ///
  /// true: 走行終了時に GPS 列を Map Matching に投げ、道路上に補正してから保存。
  /// false: 生 GPS 座標をそのまま保存。
  BoolColumn get gpsCorrectionEnabled =>
      boolean().withDefault(const Constant(true))();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
