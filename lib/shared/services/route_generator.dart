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

/// U-ターン判定の方位変化しきい値（度）
/// これを超える急激な方向転換を折り返しとみなす
const _kUTurnAngleDeg = 140.0;

/// U-ターン検出用サンプリング点数（全座標からこの数に均等間引き）
const _kUTurnSampleN = 20;

/// 折り返し回避のための距離拡大率リスト
/// U-ターン検出時に順番に試行する（元の距離 → +25% → +50%）
const _kUTurnMultipliers = [1.0, 1.1, 1.2];

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
  ///   1. 起点から正方形の頂点にウェイポイントを配置（4点ループ）
  ///      start → 東(wp1) → 北東(wp2) → 北(wp3) → start
  ///   2. Directions API でルートを取得・距離を比例補正してリトライ
  ///   3. 折り返し（U-ターン）を検出した場合は距離を段階的に拡大して再試行
  ///      短距離ほど正方形が小さく道路ネットワークに合いにくいため自動調整する
  ///
  /// [start]: 出発地点（現在地）
  /// [targetDistanceMeters]: 目標歩行距離（m）
  /// [bearingOffsetDeg]: ルート方向の回転オフセット（0〜360°）
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

    RouteResult? bestResult; // U-ターンがあっても最低限返せる結果

    // U-ターンが残る場合は距離を段階的に拡大して再試行
    // 短距離は正方形が小さくなりすぎるため +25%, +50% へ自動調整
    for (final multiplier in _kUTurnMultipliers) {
      final adjustedTarget = targetDistanceMeters * multiplier;

      // 正方形ループの辺の長さを計算
      // 正方形の周長 = 4 * side、道路係数補正後:
      // 4 * side * _kRoadFactor = adjustedTarget → side = adjustedTarget / (4 * _kRoadFactor)
      double side = adjustedTarget / (4.0 * _kRoadFactor);
      double bearing = bearingOffsetDeg; // 各multiplierごとにリセット

      RouteResult? candidate;
      for (int attempt = 0; attempt < _kMaxRetries; attempt++) {
        // ウェイポイント配置（正方形ループ・時計回り）
        // 東 → 北東 → 北 → start の順で各辺が直交し折り返しが出にくい
        final wp1 = _destinationPoint(start, 90 + bearing, side);
        final wp2 =
            _destinationPoint(start, 45 + bearing, side * math.sqrt2);
        final wp3 = _destinationPoint(start, 0 + bearing, side);

        try {
          candidate = await _directionsService.getRoute(
            [start, wp1, wp2, wp3, start],
            routeType: RouteType.circular,
          );

          // 距離が許容範囲内なら内側ループを抜ける
          final deviation =
              (candidate.distanceMeters - adjustedTarget).abs() /
                  adjustedTarget;
          if (deviation <= _kTolerance) break;

          // 比例補正: 実距離に合わせて辺を拡縮
          side *= adjustedTarget / candidate.distanceMeters;
        } on RouteApiException catch (e) {
          if (e.type == RouteErrorType.noRouteFound &&
              attempt < _kMaxRetries - 1) {
            // 45° 回転して再試行（菱形ループに切替）
            bearing += 45;
            continue;
          }
          return RouteFailure(errorType: e.type, message: e.message);
        }
      }

      if (candidate == null) continue;

      // 最初に得られた結果をフォールバックとして保持
      bestResult ??= candidate;

      // U-ターンがなければ即確定して返す
      if (!_hasUTurns(candidate.points)) {
        _incrementRateLimit();
        _cache[cacheKey] = candidate;
        return RouteSuccess(candidate);
      }
      // U-ターンあり → 次の距離で再試行
    }

    // 全距離でU-ターンを回避できなかった → フォールバック結果を返す（hasUTurns=true でUI警告）
    if (bestResult != null) {
      _incrementRateLimit();
      final withFlag = bestResult.copyWith(hasUTurns: true);
      _cache[cacheKey] = withFlag;
      return RouteSuccess(withFlag);
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

// ---------------------------------------------------------------------------
// U-ターン検出ユーティリティ
// ---------------------------------------------------------------------------

/// ルート座標列に折り返し（U-ターン）が含まれるか判定する
///
/// 全座標を [_kUTurnSampleN] 点に均等サンプリングし、
/// 連続する3点で方位変化が [_kUTurnAngleDeg] を超える箇所を検出する。
/// 始点・終点付近（自然な方向転換）は判定から除外する。
bool _hasUTurns(List<LatLng> points) {
  if (points.length < 5) return false;

  // 均等間引きサンプリング
  final step = math.max(1, points.length ~/ _kUTurnSampleN);
  final sampled = <LatLng>[];
  for (int i = 0; i < points.length; i += step) {
    sampled.add(points[i]);
  }
  if (sampled.length < 4) return false;

  // 最初と最後の1点をスキップ（出発・帰着での方向転換を誤検知しないよう）
  for (int i = 1; i < sampled.length - 2; i++) {
    final b1 = _bearingBetween(sampled[i - 1], sampled[i]);
    final b2 = _bearingBetween(sampled[i], sampled[i + 1]);
    if (_angleDiff(b1, b2) > _kUTurnAngleDeg) return true;
  }
  return false;
}

/// 2点間の方位角（北=0°, 東=90°, 南=180°, 西=270°）を返す
double _bearingBetween(LatLng from, LatLng to) {
  final lat1 = from.latitudeInRad;
  final lat2 = to.latitudeInRad;
  final dLng = (to.longitude - from.longitude) * math.pi / 180;
  final y = math.sin(dLng) * math.cos(lat2);
  final x = math.cos(lat1) * math.sin(lat2) -
      math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
  return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
}

/// 2つの方位角の差（0〜180°）を返す
double _angleDiff(double b1, double b2) {
  final diff = ((b2 - b1) % 360 + 360) % 360;
  return diff > 180 ? 360 - diff : diff;
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
