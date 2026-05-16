import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

import '../../database/database.dart';
import '../models/route_result.dart';

/// 保存済みルートの CRUD を担当するリポジトリ
class SavedRouteRepository {
  SavedRouteRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// 同一ユーザーで保持する最大件数
  static const _maxRoutesPerUser = 20;

  /// ルートを保存する
  ///
  /// 保存後、同一ユーザーのルートが [_maxRoutesPerUser] を超える場合、
  /// お気に入り以外を古い順に削除する。
  Future<String> saveRoute({
    required String userId,
    required RouteResult route,
    required double targetDistanceMeters,
    required LatLng departure,
    LatLng? destination,
    String? name,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    final polylineJson = jsonEncode(
      route.points
          .map((p) => [p.latitude, p.longitude])
          .toList(growable: false),
    );

    await _db.into(_db.savedRoutes).insert(
          SavedRoutesCompanion.insert(
            id: id,
            userId: userId,
            name: Value(name ?? ''),
            targetDistanceM: targetDistanceMeters,
            actualDistanceM: route.distanceMeters,
            durationSeconds: route.durationSeconds,
            routeType: route.routeType.name,
            polylineJson: polylineJson,
            departureLat: departure.latitude,
            departureLng: departure.longitude,
            destinationLat: destination != null
                ? Value(destination.latitude)
                : const Value.absent(),
            destinationLng: destination != null
                ? Value(destination.longitude)
                : const Value.absent(),
            createdAt: now,
          ),
        );

    await _pruneOldRoutes(userId);
    return id;
  }

  /// ユーザーの最新ルート（最終使用 or 作成日が新しい順）
  ///
  /// limit 件取得する。お気に入りを優先的に上位に配置。
  Future<List<SavedRoute>> listRecent(String userId, {int limit = 10}) {
    final query = _db.select(_db.savedRoutes)
      ..where((t) => t.userId.equals(userId))
      ..orderBy([
        (t) => OrderingTerm.desc(t.isFavorite),
        (t) => OrderingTerm.desc(
              coalesce<DateTime>([t.lastUsedAt, t.createdAt]),
            ),
      ])
      ..limit(limit);
    return query.get();
  }

  /// ユーザーの最新 1 件（前回ルート）を取得
  Future<SavedRoute?> getMostRecent(String userId) {
    final query = _db.select(_db.savedRoutes)
      ..where((t) => t.userId.equals(userId))
      ..orderBy([
        (t) => OrderingTerm.desc(
              coalesce<DateTime>([t.lastUsedAt, t.createdAt]),
            ),
      ])
      ..limit(1);
    return query.getSingleOrNull();
  }

  /// 最終使用日時を更新（走行開始時等に呼び出す）
  Future<void> markUsed(String id) async {
    await (_db.update(_db.savedRoutes)..where((t) => t.id.equals(id))).write(
      SavedRoutesCompanion(lastUsedAt: Value(DateTime.now())),
    );
  }

  /// お気に入り状態をトグル
  Future<void> setFavorite(String id, bool isFavorite) async {
    await (_db.update(_db.savedRoutes)..where((t) => t.id.equals(id))).write(
      SavedRoutesCompanion(isFavorite: Value(isFavorite)),
    );
  }

  /// 名前を変更
  Future<void> rename(String id, String name) async {
    await (_db.update(_db.savedRoutes)..where((t) => t.id.equals(id))).write(
      SavedRoutesCompanion(name: Value(name)),
    );
  }

  /// 削除
  Future<void> delete(String id) async {
    await (_db.delete(_db.savedRoutes)..where((t) => t.id.equals(id))).go();
  }

  /// 上限を超えたお気に入り以外を古い順に削除する
  Future<void> _pruneOldRoutes(String userId) async {
    final allRoutes = await (_db.select(_db.savedRoutes)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .get();

    if (allRoutes.length <= _maxRoutesPerUser) return;

    // お気に入り以外を新しい順に並べ、上限超過分を削除
    final nonFavorites =
        allRoutes.where((r) => !r.isFavorite).toList(growable: false);
    final overflow = allRoutes.length - _maxRoutesPerUser;
    final toDelete = nonFavorites.length >= overflow
        ? nonFavorites.sublist(nonFavorites.length - overflow)
        : nonFavorites;

    for (final route in toDelete) {
      await (_db.delete(_db.savedRoutes)
            ..where((t) => t.id.equals(route.id)))
          .go();
    }
  }

  /// SavedRoute を RouteResult に変換する
  static RouteResult toRouteResult(SavedRoute saved) {
    final coords = jsonDecode(saved.polylineJson) as List;
    final points = coords.map((p) {
      final pair = p as List;
      return LatLng((pair[0] as num).toDouble(), (pair[1] as num).toDouble());
    }).toList();

    return RouteResult(
      points: points,
      distanceMeters: saved.actualDistanceM,
      durationSeconds: saved.durationSeconds,
      routeType: saved.routeType == RouteType.oneWay.name
          ? RouteType.oneWay
          : RouteType.circular,
    );
  }
}

/// Riverpod プロバイダ
final savedRouteRepositoryProvider = Provider<SavedRouteRepository>((ref) {
  return SavedRouteRepository(ref.watch(appDatabaseProvider));
});
