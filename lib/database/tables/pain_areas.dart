import 'package:drift/drift.dart';

import 'condition_logs.dart';

/// 痛み部位テーブル
/// ConditionLog に対して複数部位を記録できる（多対1）
class PainAreas extends Table {
  TextColumn get id => text()();

  /// ConditionLogs FK
  TextColumn get conditionLogId =>
      text().references(ConditionLogs, #id, onDelete: KeyAction.cascade)();

  /// 部位コード（仕様書 2.6 参照）
  /// 例: right_knee / left_ankle / lower_back / neck 等
  TextColumn get bodyPart => text()();

  /// 人体図の面: front / back
  TextColumn get side => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
