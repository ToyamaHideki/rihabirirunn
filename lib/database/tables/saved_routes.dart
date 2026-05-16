import 'package:drift/drift.dart';

import 'user_profiles.dart';

/// 保存済みルートテーブル
///
/// ルート生成成功時に自動保存され、ユーザーが「前回のルート」「お気に入り」から
/// 再利用できる。GPS 軌跡ではなく Mapbox から取得した計画ルート（polyline）を持つ。
class SavedRoutes extends Table {
  TextColumn get id => text()();

  /// UserProfiles FK
  TextColumn get userId =>
      text().references(UserProfiles, #id, onDelete: KeyAction.cascade)();

  /// 任意のルート名（ユーザーが付ける）。未設定時は出発地点座標等から生成される。
  TextColumn get name => text().withDefault(const Constant(''))();

  /// 目標距離（m）— ユーザーがスライダーで指定した値
  RealColumn get targetDistanceM => real()();

  /// 実際の距離（m）— Mapbox から取得した実ルート距離
  RealColumn get actualDistanceM => real()();

  /// 推定所要時間（秒）
  IntColumn get durationSeconds => integer()();

  /// ルート種別: circular / oneWay
  TextColumn get routeType => text()();

  /// ルートの座標列を JSON 文字列で保存
  ///
  /// 形式: `[[lat, lng], [lat, lng], ...]`
  TextColumn get polylineJson => text()();

  /// 出発地点緯度
  RealColumn get departureLat => real()();

  /// 出発地点経度
  RealColumn get departureLng => real()();

  /// 目的地点緯度（片道で指定された場合のみ）
  RealColumn get destinationLat => real().nullable()();

  /// 目的地点経度（片道で指定された場合のみ）
  RealColumn get destinationLng => real().nullable()();

  /// お気に入りフラグ
  BoolColumn get isFavorite =>
      boolean().withDefault(const Constant(false))();

  /// 作成日時
  DateTimeColumn get createdAt => dateTime()();

  /// 最終使用日時（走行開始時に更新）
  DateTimeColumn get lastUsedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
