import 'package:drift/drift.dart';

import 'user_profiles.dart';
import 'run_sessions.dart';

/// 体調・コンディション記録テーブル
/// 走行前(before)・走行後(after)・単独記録(standalone) の3パターン
class ConditionLogs extends Table {
  TextColumn get id => text()();

  /// UserProfiles FK
  TextColumn get userId =>
      text().references(UserProfiles, #id, onDelete: KeyAction.cascade)();

  /// RunSessions FK（nullable: standalone 記録の場合は null）
  TextColumn get sessionId =>
      text().nullable().references(RunSessions, #id, onDelete: KeyAction.setNull)();

  /// 記録タイミング: before / after / standalone
  TextColumn get timing => text()();

  /// 痛みスコア 0（無痛）〜 10（最大痛）
  IntColumn get painScore => integer().withDefault(const Constant(0))();

  /// 自由記述メモ（最大 500 文字）
  TextColumn get memo => text().nullable()();

  DateTimeColumn get recordedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
