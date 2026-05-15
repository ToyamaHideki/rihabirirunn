import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../models/route_result.dart';
import 'directions_service.dart';

// ---------------------------------------------------------------------------
// 定数・設定値
// ---------------------------------------------------------------------------

/// 道路距離 / 直線距離の経験的な比率（市街地での平均）
const _kRoadFactor = 1.35;

/// 許容誤差（±5%）— T-1.2.2 / T-1.2.3 完了条件
const _kTolerance = 0.05;

/// 距離調整の最大リトライ回数
const _kMaxRetries = 3;

/// 1日の最大ルート生成リクエスト回数（ユーザー向け）— T-1.2.4
const _kDailyLimit = 10;

// ---------------------------------------------------------------------------
// ルートジェネレーター
// ---------------------------------------------------------------------------

/// T-1.2.2 / T-1.2.3 / T-1.2.4 / T-1.2.5: ルート生成サービス
///
/// - 周回ルート: 指定距離±5% の循環ルートを自動生成
/// - 片道ルート: 指定距離±5% の直進型ルートを自動生成
/// - レートリミット: 1日10回まで（インメモリ管理）
/// - エラーハンドリング: すべての失敗を RouteFailure で返す
class RouteGenerator {
  RouteGenerator(this._directionsService);

  final DirectionsService _directionsService;

  // ---- 1日あたりのリクエストカウンター（インメモリ）---- T-1.2.4
  int _dailyCount = 0;
  DateTime _lastCounterReset = DateTime.now();

  // ---- リクエスト結果キャッシュ ---- T-1.2.4
  final Map<String, RouteResult> _cache = {};

  // ---------------------------------------------------------------------------
  // T-1.2.2: 周回ルート生成
  // ---------------------------------------------------------------------------

  /// 現在地を起点とした、指定距離±5% の周回ルートを生成する
  ///
  /// アルゴリズム:
  ///   1. 起点から東・北の方向にウェイポイントを配置（直角三角形形状）
  ///   2. Directions API でルートを取得
  ///   3. 実際の距離が目標と乖離していれば半径を比例補正してリトライ
  ///
  /// [start]: 出発地点（現在地）
  /// [targetDistanceMeters]: 目標歩行距離（m）
  /// [bearingOffsetDeg]: ルート方向の回転オフセット（0〜360°）。0=東向き基準
  Future<RouteGenerationResult> generateCircularRoute({
    required LatLng start,
    required double targetDistanceMeters,
    double bearingOffsetDeg = 0.0,
  }) async {
    if (!_checkRateLimit()) {
      return const RouteFailure(
        errorType: RouteErrorType.rateLimitExceeded,
        message: '1日のルート生成回数上限に達しました',
      );
    }

    // キャッシュチェック
    final cacheKey = _cacheKey(start, targetDistanceMeters, RouteType.circular,
        bearingOffsetDeg);
    if (_cache.containsKey(cacheKey)) {
      return RouteSuccess(_cache[cacheKey]!);
    }

    // 初期半径の見積もり
    // 直角三角形の各辺: R, R√2, R → 合計 ≈ 3.41R
    // 道路係数補正後: 3.41 * 1.35 ≈ 4.6R
    // よって R_init = target / 4.6
    double radiusM = targetDistanceMeters / (_kRoadFactor * (2 + math.sqrt2));

    RouteResult? lastResult;
    for (int attempt = 0; attempt < _kMaxRetries; attempt++) {
      // ウェイポイント配置（直角三角形ループ）
      // wp1: 東方向
      // wp2: 北方向
      final wp1 = _destinationPoint(start, 90 + bearingOffsetDeg, radiusM);
      final wp2 = _destinationPoint(start, 0 + bearingOffsetDeg, radiusM);

      try {
        final result = await _directionsService.getRoute(
          [start, wp1, wp2, start],
          routeType: RouteType.circular,
        );
        lastResult = result;

        // 距離が許容範囲内なら確定
        final deviation =
            (result.distanceMeters - targetDistanceMeters).abs() /
                targetDistanceMeters;
        if (deviation <= _kTolerance) {
          _incrementRateLimit();
          _cache[cacheKey] = result;
          return RouteSuccess(result);
        }

        // 比例補正: 実距離が短ければ半径を拡大、長ければ縮小
        radiusM *= targetDistanceMeters / result.distanceMeters;
      } on RouteApiException catch (e) {
        if (e.type == RouteErrorType.noRouteFound && attempt < _kMaxRetries - 1) {
          // ウェイポイントを少しずらして再試行
          bearingOffsetDeg += 45;
          continue;
        }
        return RouteFailure(
          errorType: e.type,
          message: e.message,
        );
      }
    }

    // 最終リトライ結果を評価
    if (lastResult != null) {
      final deviation =
          (lastResult.distanceMeters - targetDistanceMeters).abs() /
              targetDistanceMeters;
      if (deviation <= 0.10) {
        // 10% 以内なら許容して返す
        _incrementRateLimit();
        _cache[cacheKey] = lastResult;
        return RouteSuccess(lastResult);
      }
    }

    return const RouteFailure(
      errorType: RouteErrorType.distanceNotAchievable,
      message: '指定距離のルートを $kMaxRetries 回試行しましたが生成できませんでした',
    );
  }

  // ---------------------------------------------------------------------------
  // T-1.2.3: 片道ルート生成
  // ---------------------------------------------------------------------------

  /// 現在地から指定方位・距離方向への片道ルートを生成する
  ///
  /// [start]: 出発地点
  /// [targetDistanceMeters]: 目標距離（m）
  /// [bearingDeg]: 進行方向（0=北, 90=東, 180=南, 270=西）
  Future<RouteGenerationResult> generateOneWayRoute({
    required LatLng start,
    required double targetDistanceMeters,
    double bearingDeg = 0.0,
  }) async {
    if (!_checkRateLimit()) {
      return const RouteFailure(
        errorType: RouteErrorType.rateLimitExceeded,
        message: '1日のルート生成回数上限に達しました',
      );
    }

    // キャッシュチェック
    final cacheKey =
        _cacheKey(start, targetDistanceMeters, RouteType.oneWay, bearingDeg);
    if (_cache.containsKey(cacheKey)) {
      return RouteSuccess(_cache[cacheKey]!);
    }

    // 初期目的地距離の見積もり（直線距離 = 目標 / 道路係数）
    double straightLineM = targetDistanceMeters / _kRoadFactor;

    RouteResult? lastResult;
    for (int attempt = 0; attempt < _kMaxRetries; attempt++) {
      final dest = _destinationPoint(start, bearingDeg, straightLineM);

      try {
        final result = await _directionsService.getRoute(
          [start, dest],
          routeType: RouteType.oneWay,
        );
        lastResult = result;

        final deviation =
            (result.distanceMeters - targetDistanceMeters).abs() /
                targetDistanceMeters;
        if (deviation <= _kTolerance) {
          _incrementRateLimit();
          _cache[cacheKey] = result;
          return RouteSuccess(result);
        }

        straightLineM *= targetDistanceMeters / result.distanceMeters;
      } on RouteApiException catch (e) {
        if (e.type == RouteErrorType.noRouteFound && attempt < _kMaxRetries - 1) {
          // 別方角で再試行
          bearingDeg = (bearingDeg + 45) % 360;
          continue;
        }
        return RouteFailure(errorType: e.type, message: e.message);
      }
    }

    if (lastResult != null) {
      final deviation =
          (lastResult.distanceMeters - targetDistanceMeters).abs() /
              targetDistanceMeters;
      if (deviation <= 0.10) {
        _incrementRateLimit();
        _cache[cacheKey] = lastResult;
        return RouteSuccess(lastResult);
      }
    }

    return const RouteFailure(
      errorType: RouteErrorType.distanceNotAchievable,
      message: '指定距離のルートを $kMaxRetries 回試行しましたが生成できませんでした',
    );
  }

  // ---------------------------------------------------------------------------
  // T-1.2.4: レートリミット管理（インメモリ）
  // ---------------------------------------------------------------------------

  /// 1日のカウンターが上限以内かを確認し、日付が変わっていればリセットする
  /// ⚠️ アプリ再起動でカウンターはリセットされる（永続化は TODO）
  bool _checkRateLimit() {
    final now = DateTime.now();
    if (now.year != _lastCounterReset.year ||
        now.month != _lastCounterReset.month ||
        now.day != _lastCounterReset.day) {
      _dailyCount = 0;
      _lastCounterReset = now;
    }
    return _dailyCount < _kDailyLimit;
  }

  void _incrementRateLimit() => _dailyCount++;

  /// 残りリクエスト可能回数を返す（UI 表示用）
  int get remainingRequests {
    _checkRateLimit(); // 日付リセットを反映
    return (_kDailyLimit - _dailyCount).clamp(0, _kDailyLimit);
  }

  // ---------------------------------------------------------------------------
  // キャッシュ
  // ---------------------------------------------------------------------------

  String _cacheKey(
      LatLng start, double targetM, RouteType type, double bearing) {
    // ~10m 精度でキャッシュキーを生成
    final lat = (start.latitude * 10000).round();
    final lng = (start.longitude * 10000).round();
    final dist = (targetM / 100).round(); // 100m 単位
    final b = bearing.round();
    return '${type.name}_${lat}_${lng}_${dist}_$b';
  }

  /// キャッシュをクリアする（例: 場所が大きく変わった場合）
  void clearCache() => _cache.clear();
}

// ---------------------------------------------------------------------------
// 地理計算ユーティリティ
// ---------------------------------------------------------------------------

/// Haversine 逆算: 起点から指定方位・距離にある点を返す
///
/// [origin]: 起点
/// [bearingDeg]: 方位角（0=北, 90=東, 180=南, 270=西）
/// [distanceMeters]: 移動距離（m）
LatLng _destinationPoint(
    LatLng origin, double bearingDeg, double distanceMeters) {
  const earthRadius = 6371000.0; // m
  final lat1 = origin.latitudeInRad;
  final lng1 = origin.longitudeInRad;
  final bearing = bearingDeg * math.pi / 180.0;
  final d = distanceMeters / earthRadius;

  final lat2 =
      math.asin(math.sin(lat1) * math.cos(d) +
          math.cos(lat1) * math.sin(d) * math.cos(bearing));
  final lng2 = lng1 +
      math.atan2(
        math.sin(bearing) * math.sin(d) * math.cos(lat1),
        math.cos(d) - math.sin(lat1) * math.sin(lat2),
      );

  return LatLng(
    lat2 * 180 / math.pi,
    _normalizeLng(lng2 * 180 / math.pi),
  );
}

/// 経度を -180〜180 の範囲に正規化する
double _normalizeLng(double lng) {
  while (lng > 180) {
    lng -= 360;
  }
  while (lng < -180) {
    lng += 360;
  }
  return lng;
}

// ---- Riverpod プロバイダ ----

final routeGeneratorProvider = Provider<RouteGenerator>((ref) {
  return RouteGenerator(ref.watch(directionsServiceProvider));
});

// 日次レートリミットの残り回数プロバイダ（UI 表示用）
final remainingRouteRequestsProvider = Provider<int>((ref) {
  return ref.watch(routeGeneratorProvider).remainingRequests;
});

// ファイルスコープから参照できるよう定数を public 化
const kMaxRetries = _kMaxRetries;
