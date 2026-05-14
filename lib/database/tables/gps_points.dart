import 'package:drift/drift.dart';

import 'run_sessions.dart';

/// GPS 軌跡ポイントテーブル
/// 走行中に 1〜3 秒間隔で蓄積し、走行終了時に一括 INSERT する
class GpsPoints extends Table {
  TextColumn get id => text()();

  /// RunSessions FK
  TextColumn get sessionId =>
      text().references(RunSessions, #id, onDelete: KeyAction.cascade)();

  /// 緯度
  RealColumn get lat => real()();

  /// 経度
  RealColumn get lng => real()();

  /// 標高(m)
  RealColumn get altitudeM => real().nullable()();

  /// GPS 精度(m)。20m 超はルート描画に使用しない
  RealColumn get accuracyM => real().nullable()();

  /// 瞬間速度(m/s)
  RealColumn get speedMps => real().nullable()();

  /// 記録時刻
  DateTimeColumn get recordedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
