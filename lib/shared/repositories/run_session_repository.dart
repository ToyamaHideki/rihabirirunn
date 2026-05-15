import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

import '../../database/database.dart';
import '../models/route_result.dart';
import '../services/tracking_service.dart';

/// 走行セッション・GPS ポイントの保存と取得を担当するリポジトリ
///
/// T-2.4.1: RunSession レコード作成
/// T-2.4.2: GpsPoints 一括 INSERT
/// T-2.4.3: 達成判定（actualDistance >= plannedDistance × 0.95）
/// T-2.4.5: MET 法によるカロリー推定
class RunSessionRepository {
  RunSessionRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  // ---------------------------------------------------------------------------
  // T-2.4.1 / T-2.4.2: 走行セッション保存
  // ---------------------------------------------------------------------------

  /// 走行セッションと GPS ポイントをトランザクション内で一括保存する
  ///
  /// [userId]            ユーザー ID（UserProfiles.id）
  /// [startedAt]         走行開始時刻
  /// [trackingState]     走行終了時の TrackingState
  /// [plannedDistanceM]  ルート設定時の計画距離（m）
  /// [routeType]         ルート種別
  /// [routePoints]       計画ルート座標列（GeoJSON 保存用）
  /// [departurePoint]    出発地点（null の場合は最初の GPS 点を使用）
  ///
  /// @return 作成されたセッション ID
  Future<String> saveSession({
    required String userId,
    required DateTime startedAt,
    required TrackingState trackingState,
    double? plannedDistanceM,
    RouteType? routeType,
    List<LatLng>? routePoints,
    LatLng? departurePoint,
  }) async {
    final sessionId = _uuid.v4();
    final now = DateTime.now();
    final planned = plannedDistanceM ?? trackingState.distanceMeters;

    // T-2.4.3: 達成判定（計画距離の 95% 以上歩いたか）
    final isAchieved =
        planned > 0 && trackingState.distanceMeters >= planned * 0.95;

    // T-2.4.5: MET 法によるカロリー推定
    final calories = _estimateCalories(
      durationSeconds: trackingState.elapsedSeconds,
    );

    // 計画ルートを GeoJSON LineString に変換
    final geoJson = (routePoints != null && routePoints.isNotEmpty)
        ? _encodeLineStringGeoJson(routePoints)
        : null;

    // 出発地点座標
    final depLat = departurePoint?.latitude ??
        trackingState.positions.firstOrNull?.latitude ??
        0.0;
    final depLng = departurePoint?.longitude ??
        trackingState.positions.firstOrNull?.longitude ??
        0.0;

    // 到着地点座標（片道ルートのみ）
    final isOneWay = routeType == RouteType.oneWay;
    final arrLat =
        isOneWay ? trackingState.positions.lastOrNull?.latitude : null;
    final arrLng =
        isOneWay ? trackingState.positions.lastOrNull?.longitude : null;

    await _db.transaction(() async {
      // ---- T-2.4.1: RunSession 保存 ----
      await _db.into(_db.runSessions).insert(
            RunSessionsCompanion.insert(
              id: sessionId,
              userId: userId,
              startedAt: startedAt,
              finishedAt: Value(now),
              plannedDistance: planned,
              actualDistance: Value(trackingState.distanceMeters),
              durationSeconds: Value(trackingState.elapsedSeconds),
              avgPaceSecsPerKm: Value(
                trackingState.paceSecPerKm > 0
                    ? trackingState.paceSecPerKm.toDouble()
                    : null,
              ),
              routeType:
                  Value(routeType == RouteType.oneWay ? 'oneway' : 'loop'),
              routeGeoJson: Value(geoJson),
              isGoalAchieved: Value(isAchieved),
              status: Value('completed'),
              startLat: depLat,
              startLng: depLng,
              endLat: Value(arrLat),
              endLng: Value(arrLng),
              estimatedCalories:
                  Value(calories > 0 ? calories : null),
              createdAt: now,
            ),
          );

      // ---- T-2.4.2: GPS ポイント一括保存 ----
      final positions = trackingState.positions;
      if (positions.isNotEmpty) {
        final durationMs = trackingState.elapsedSeconds * 1000;
        final count = positions.length;

        final companions = positions.asMap().entries.map((entry) {
          final i = entry.key;
          final p = entry.value;
          // 経過時間に比例した近似タイムスタンプを付与
          final offsetMs =
              count > 1 ? (durationMs * i ~/ (count - 1)) : 0;
          return GpsPointsCompanion.insert(
            id: _uuid.v4(),
            sessionId: sessionId,
            lat: p.latitude,
            lng: p.longitude,
            recordedAt: startedAt.add(Duration(milliseconds: offsetMs)),
          );
        }).toList();

        await _db.batch((batch) {
          batch.insertAll(_db.gpsPoints, companions);
        });
      }
    });

    return sessionId;
  }

  // ---------------------------------------------------------------------------
  // 取得
  // ---------------------------------------------------------------------------

  /// セッションを ID で取得する
  Future<RunSession?> getSession(String sessionId) {
    return (
      _db.select(_db.runSessions)
        ..where((t) => t.id.equals(sessionId))
    ).getSingleOrNull();
  }

  /// セッションに紐付く GPS ポイントを時刻順で取得する
  Future<List<GpsPoint>> getGpsPoints(String sessionId) {
    return (
      _db.select(_db.gpsPoints)
        ..where((t) => t.sessionId.equals(sessionId))
        ..orderBy([(t) => OrderingTerm(expression: t.recordedAt)])
    ).get();
  }

  // ---------------------------------------------------------------------------
  // T-2.4.5: カロリー推定（内部ユーティリティ）
  // ---------------------------------------------------------------------------

  /// MET 法によるカロリー推定
  ///
  /// - MET 3.0: リハビリレベルの歩行（ゆっくり〜普通）
  /// - 体重 60 kg: UserProfiles に体重フィールドがないため固定値を使用
  ///   （将来的に UserProfiles.weightKg を追加して参照予定）
  static int _estimateCalories({
    required int durationSeconds,
    double met = 3.0,
    double weightKg = 60.0,
  }) {
    if (durationSeconds <= 0) return 0;
    return (met * weightKg * durationSeconds / 3600.0).round();
  }

  // ---------------------------------------------------------------------------
  // GeoJSON エンコード
  // ---------------------------------------------------------------------------

  static String _encodeLineStringGeoJson(List<LatLng> points) {
    final coords = points
        .map((p) => [p.longitude, p.latitude])
        .toList();
    return jsonEncode({'type': 'LineString', 'coordinates': coords});
  }
}

// ---- Riverpod プロバイダ ----

final runSessionRepositoryProvider = Provider<RunSessionRepository>((ref) {
  return RunSessionRepository(ref.watch(appDatabaseProvider));
});
