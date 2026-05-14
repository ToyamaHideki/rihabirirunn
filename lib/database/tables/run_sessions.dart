import 'package:drift/drift.dart';

import 'user_profiles.dart';

/// 走行セッションテーブル
/// 1走行につき1レコード
class RunSessions extends Table {
  TextColumn get id => text()();

  /// UserProfiles FK
  TextColumn get userId =>
      text().references(UserProfiles, #id, onDelete: KeyAction.cascade)();

  /// 走行開始時刻
  DateTimeColumn get startedAt => dateTime()();

  /// 走行終了時刻（中断時は null の場合あり）
  DateTimeColumn get finishedAt => dateTime().nullable()();

  /// 生成時の計画距離(m)
  RealColumn get plannedDistance => real()();

  /// GPS 累計距離(m)
  RealColumn get actualDistance =>
      real().withDefault(const Constant(0.0))();

  /// 純粋な走行時間（一時停止除く）単位: 秒
  IntColumn get durationSeconds =>
      integer().withDefault(const Constant(0))();

  /// 平均ペース(秒/km)
  RealColumn get avgPaceSecsPerKm => real().nullable()();

  /// ルート形状: loop / oneway
  TextColumn get routeType =>
      text().withDefault(const Constant('loop'))();

  /// 生成ルートの GeoJSON 文字列（地図プレビュー用）
  TextColumn get routeGeoJson => text().nullable()();

  /// 計画距離の 95% 以上を達成したか
  BoolColumn get isGoalAchieved =>
      boolean().withDefault(const Constant(false))();

  /// セッション状態: completed / abandoned / interrupted
  TextColumn get status =>
      text().withDefault(const Constant('completed'))();

  /// 出発地点座標
  RealColumn get startLat => real()();
  RealColumn get startLng => real()();

  /// 到着地点座標（片道ルートのみ）
  RealColumn get endLat => real().nullable()();
  RealColumn get endLng => real().nullable()();

  /// 推定消費カロリー(kcal)
  IntColumn get estimatedCalories => integer().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
