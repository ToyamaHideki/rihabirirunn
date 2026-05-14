import 'package:drift/drift.dart';

/// ユーザープロフィールテーブル
/// アプリ内に1レコードのみ存在する想定（シングルユーザー）
class UserProfiles extends Table {
  /// UUID v4 形式のプライマリキー
  TextColumn get id => text()();

  /// 年齢（初期設定時に入力、任意）
  IntColumn get age => integer().nullable()();

  /// リハビリ対象部位のラベル（任意テキスト）
  TextColumn get rehabTarget => text().nullable()();

  /// 最終目標距離(m)（将来達成したい距離）
  RealColumn get finalGoalDistance => real().nullable()();

  /// 目標距離更新モード: conservative / standard / challenge / custom
  TextColumn get mode => text().withDefault(const Constant('standard'))();

  /// 次回走行の目標距離(m)
  RealColumn get currentTargetDistance =>
      real().withDefault(const Constant(500.0))();

  /// 免責同意した日時（初回起動時に記録）
  DateTimeColumn get agreedDisclaimerAt => dateTime()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
