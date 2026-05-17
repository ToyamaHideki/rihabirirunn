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
const _kUTurnAngleDeg = 120.0;

/// U-ターン検出用サンプリング点数（全座標からこの数に均等間引き）
const _kUTurnSampleN = 30;

/// 周回ルートのウェイポイント数（正多角形の頂点数）の最小値・最大値
/// 距離に応じて 1辺が _kPreferredSideM 程度になるよう調整する
const _kMinCircleN = 3; // 三角形で足りる短距離ルートに対応
const _kMaxCircleN = 6; // 頂点を絞って行き止まり路地への侵入機会を減らす

/// 多角形 1辺の目標長さ（m）
///
/// 短すぎる辺（< 120m）はウェイポイントが住宅ブロック内部や行き止まり路地に
/// 密集し、API が袋小路に引き込まれるループルートを生成しやすくなる。
/// 長すぎる辺は 1区間で大きく迂回するリスクがあるが、行き止まり問題より軽微。
/// 280m（≒ 市街地 2〜3ブロック分）を基準にすることでウェイポイントを幹線道路付近に分散させる。
const _kPreferredSideM = 280.0;

/// U-ターン回避のための方向リトライ数
/// 90° ずつ回転して最大 4 方向を試行する
const _kBearingRetries = 4;

/// 1日の最大ルート生成リクエスト回数（ユーザー向け）— T-1.2.4
const _kDailyLimit = 10;

/// 自己重複検出のサンプリング間隔（m）
const _kOverlapSampleStepM = 20.0;

/// 「同じ道」と判定する 2 サンプル間の距離しきい値（m）
const _kOverlapNearM = 12.0;

/// 自己重複比較で「隣接」とみなすサンプル数（この範囲内は無視）
/// 6 サンプル ≒ 120m
const _kOverlapMinIndexGap = 6;

/// 周回ルートの自然な始点-終点近接を無視するためのバッファサンプル数
const _kOverlapClosureBuffer = 2;

/// 自己重複比率の許容値（これ以上は「同じ道を回るルート」とみなす）
const _kOverlapThreshold = 0.20;

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
  ///   1. 距離に応じて頂点数 N を決定（1辺 ~180m 目安、5〜10 頂点）
  ///   2. 起点から時計回りに正 N 角形を描くウェイポイント列を構築
  ///   3. Directions API を `continue_straight=true` で呼び、
  ///      中間ウェイポイントでのU-ターンを禁止
  ///   4. NoRoute なら `continue_straight=false` でフォールバック
  ///   5. 距離乖離が ±5% 超なら辺長を比例補正してリトライ（最大 3 回）
  ///   6. U-ターンが残る場合は 90° ずつ回転して最大 4 方向を試行
  ///   7. 全方向で U-ターンが残った場合は最良候補に hasUTurns=true を付けて返す
  ///      （UI でユーザーに注意メッセージを表示）
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

    // 距離に応じて頂点数を選択（1辺が ~_kPreferredSideM になるよう調整）
    final n = ((targetDistanceMeters / _kPreferredSideM).ceil())
        .clamp(_kMinCircleN, _kMaxCircleN);

    // 正多角形を 90° ずつ回転しながら最大 _kBearingRetries 方向を試行
    // 向きを変えることで道路網の一方通行・行き止まりを回避しやすくなる
    for (int bearingIdx = 0; bearingIdx < _kBearingRetries; bearingIdx++) {
      final bearing = (bearingOffsetDeg + bearingIdx * 90.0) % 360.0;

      // 多角形の1辺の長さ（初期推定）
      // 辺の数 × 辺長 × 道路係数 ≒ 目標距離
      double side = targetDistanceMeters / (n * _kRoadFactor);

      RouteResult? candidate;
      for (int attempt = 0; attempt < _kMaxRetries; attempt++) {
        // 正多角形ウェイポイントを生成（時計回り）
        final waypoints = _polygonWaypoints(start, bearing, side, n);
        final route = [start, ...waypoints, start];

        try {
          // 1st: continue_straight=true で中間ウェイポイントでのU-ターンを禁止
          candidate = await _directionsService.getRoute(
            route,
            routeType: RouteType.circular,
            continueStraight: true,
          );
        } on RouteApiException catch (e) {
          if (e.type == RouteErrorType.noRouteFound) {
            // フォールバック: continue_straight 制約を外して再試行
            // （道路網の都合で waypoint U-ターンが必要なケース）
            try {
              candidate = await _directionsService.getRoute(
                route,
                routeType: RouteType.circular,
                continueStraight: false,
              );
            } on RouteApiException {
              if (attempt < _kMaxRetries - 1) {
                side *= 1.2; // 辺を 20% 拡大して再試行
                continue;
              }
              candidate = null;
              break;
            }
          } else {
            return RouteFailure(errorType: e.type, message: e.message);
          }
        }

        // 距離が許容範囲内なら内側ループを抜ける
        final deviation =
            (candidate.distanceMeters - targetDistanceMeters).abs() /
                targetDistanceMeters;
        if (deviation <= _kTolerance) break;

        // 比例補正: 実距離に合わせて辺を拡縮
        side *= targetDistanceMeters / candidate.distanceMeters;
      }

      if (candidate == null) continue;

      // 最初に得られた結果をフォールバックとして保持
      // ただし「目標距離に近い」「U-ターンが少ない」結果を優先する
      if (bestResult == null ||
          _isBetterCandidate(candidate, bestResult, targetDistanceMeters)) {
        bestResult = candidate;
      }

      // U-ターンがなく自己重複も少なければ即確定して返す
      // ① 自己重複 = 同じ道を 2 回以上通る箇所が ${_kOverlapThreshold*100}% 以上ある状態
      if (!_hasUTurns(candidate.points) &&
          _selfOverlapRatio(candidate.points) < _kOverlapThreshold) {
        _incrementRateLimit();
        _cache[cacheKey] = candidate;
        return RouteSuccess(candidate);
      }
      // U-ターンあり or 同じ道のループあり → 次の方向で再試行
    }

    // 全方向でU-ターンを回避できなかった → フォールバック結果を返す（hasUTurns=true でUI警告）
    if (bestResult != null) {
      _incrementRateLimit();
      final withFlag = bestResult.copyWith(hasUTurns: true);
      _cache[cacheKey] = withFlag;
      return RouteSuccess(withFlag);
    }

    return const RouteFailure(
      errorType: RouteErrorType.distanceNotAchievable,
      message: '指定距離のルートを生成できませんでした',
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
// 候補比較
// ---------------------------------------------------------------------------

/// 周回ルート候補のスコアリング
/// 優先順位:
///   1. U-ターンが無い候補（hasUTurns 不検出）
///   2. 自己重複が少ない候補（同じ道を二度通らない）
///   3. 同条件なら目標距離との乖離が小さい候補
bool _isBetterCandidate(
    RouteResult candidate, RouteResult current, double targetM) {
  final candHasU = _hasUTurns(candidate.points);
  final currHasU = _hasUTurns(current.points);

  // U-ターン有無で優先順位
  if (candHasU != currHasU) return !candHasU;

  // ① 自己重複の少なさで優先順位
  final candOverlap = _selfOverlapRatio(candidate.points);
  final currOverlap = _selfOverlapRatio(current.points);
  // しきい値の上下が異なるなら「しきい値内」を優先
  final candBelow = candOverlap < _kOverlapThreshold;
  final currBelow = currOverlap < _kOverlapThreshold;
  if (candBelow != currBelow) return candBelow;
  // 同等カテゴリ → 比率差が 5% 以上あれば低い方を優先
  if ((candOverlap - currOverlap).abs() > 0.05) {
    return candOverlap < currOverlap;
  }

  // 同条件 → 目標距離との差で比較
  final candDev = (candidate.distanceMeters - targetM).abs();
  final currDev = (current.distanceMeters - targetM).abs();
  return candDev < currDev;
}

// ---------------------------------------------------------------------------
// 地理計算ユーティリティ
// ---------------------------------------------------------------------------

/// 正N角形ルートのウェイポイントを生成する
///
/// [start] を第1頂点とし、[bearingDeg] 方向に歩き始めて時計回りに N 辺を描く。
/// 戻り値は [start] と [start] の間に挟む N-1 個の中間点。
///
/// 各頂点は直前の頂点から [sideM] メートル離れた位置に配置される。
/// 時計回りの外角 = 360° / N を毎頂点加算することで正多角形が閉じる。
List<LatLng> _polygonWaypoints(
    LatLng start, double bearingDeg, double sideM, int n) {
  final exteriorAngle = 360.0 / n;
  var pos = start;
  var dir = bearingDeg;
  return List.generate(n - 1, (_) {
    pos = _destinationPoint(pos, dir, sideM);
    dir = (dir + exteriorAngle) % 360.0; // 時計回りに外角分だけ回転
    return pos;
  });
}

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

// ---------------------------------------------------------------------------
// ① 自己重複検出ユーティリティ
// ---------------------------------------------------------------------------

/// ルートの自己重複比率（0.0〜1.0）を返す。
///
/// 「自己重複」= 同じ道を 2 回以上通ること（往復・周回での経路再踏み）。
/// 周回ルートでは始点と終点が同一座標になるため、両端の数サンプルは比較から除外する。
///
/// アルゴリズム:
///   1. ルートを [_kOverlapSampleStepM] m 間隔でサンプリング
///   2. 各サンプル i について、インデックス差が [_kOverlapMinIndexGap] 以上ある
///      他のサンプル j との距離を測る
///   3. 距離 < [_kOverlapNearM] なら「重複」とカウント
///   4. 比較対象サンプル数に対する重複比率を返す
double _selfOverlapRatio(List<LatLng> points) {
  if (points.length < 10) return 0.0;

  final samples = _sampleByDistance(points, _kOverlapSampleStepM);
  final n = samples.length;
  if (n < _kOverlapMinIndexGap * 2 + _kOverlapClosureBuffer * 2 + 4) {
    return 0.0;
  }

  final start = _kOverlapClosureBuffer;
  final end = n - _kOverlapClosureBuffer;
  final tested = end - start;
  if (tested <= 0) return 0.0;

  int overlapping = 0;
  for (int i = start; i < end; i++) {
    for (int j = start; j < end; j++) {
      if ((j - i).abs() < _kOverlapMinIndexGap) continue;
      if (_haversineMeters(samples[i], samples[j]) < _kOverlapNearM) {
        overlapping++;
        break;
      }
    }
  }
  return overlapping / tested;
}

/// 折れ線を距離間隔 [intervalM] でサンプリングする。
///
/// 累積距離が intervalM を超えるたびに点を採用し、最終点も末尾に含める。
List<LatLng> _sampleByDistance(List<LatLng> points, double intervalM) {
  if (points.length < 2) return List<LatLng>.from(points);
  final result = <LatLng>[points.first];
  double acc = 0;
  for (int i = 1; i < points.length; i++) {
    acc += _haversineMeters(points[i - 1], points[i]);
    if (acc >= intervalM) {
      result.add(points[i]);
      acc = 0;
    }
  }
  if (result.last != points.last) result.add(points.last);
  return result;
}

/// Haversine 距離（m）
double _haversineMeters(LatLng a, LatLng b) {
  const r = 6371000.0;
  final lat1 = a.latitudeInRad;
  final lat2 = b.latitudeInRad;
  final dLat = lat2 - lat1;
  final dLng = b.longitudeInRad - a.longitudeInRad;
  final s = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1) *
          math.cos(lat2) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  return r * 2 * math.atan2(math.sqrt(s), math.sqrt(1 - s));
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
