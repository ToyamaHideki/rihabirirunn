import 'package:latlong2/latlong.dart';

// ---------------------------------------------------------------------------
// ルート種別
// ---------------------------------------------------------------------------

/// ルート形状の種別
enum RouteType {
  circular('周回'),
  oneWay('片道');

  const RouteType(this.label);
  final String label;
}

// ---------------------------------------------------------------------------
// ルート結果
// ---------------------------------------------------------------------------

/// Mapbox Directions API から取得したルート情報
class RouteResult {
  const RouteResult({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.routeType,
    this.hasUTurns = false,
  });

  /// ルートを構成する座標列（GeoJSON LineString の各点）
  final List<LatLng> points;

  /// 実際のルート距離（m）
  final double distanceMeters;

  /// 推定所要時間（秒）
  final int durationSeconds;

  /// ルート種別
  final RouteType routeType;

  /// 折り返し（U-ターン）が含まれるか
  ///
  /// 短距離では道路ネットワークの制約により折り返しが生じることがある。
  /// true の場合、UI でユーザーへの注意メッセージを表示する。
  final bool hasUTurns;

  /// フィールドを部分的に上書きしたコピーを返す
  RouteResult copyWith({bool? hasUTurns}) => RouteResult(
        points: points,
        distanceMeters: distanceMeters,
        durationSeconds: durationSeconds,
        routeType: routeType,
        hasUTurns: hasUTurns ?? this.hasUTurns,
      );

  double get distanceKm => distanceMeters / 1000.0;

  /// 所要時間の表示文字列（例: "12分" / "1時間5分"）
  String get formattedDuration {
    final minutes = (durationSeconds / 60).round();
    if (minutes < 60) return '$minutes分';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '$h時間' : '$h時間$m分';
  }

  /// 距離の表示文字列（例: "1.5km" / "800m"）
  String get formattedDistance {
    if (distanceMeters < 1000) {
      return '${distanceMeters.round()}m';
    }
    return '${distanceKm.toStringAsFixed(1)}km';
  }
}

// ---------------------------------------------------------------------------
// エラー種別
// ---------------------------------------------------------------------------

/// ルート生成時のエラー種別
enum RouteErrorType {
  /// 1日の上限リクエスト回数に達した
  rateLimitExceeded,

  /// ネットワーク接続エラー
  networkError,

  /// 指定ウェイポイント間にルートが存在しない
  noRouteFound,

  /// 指定距離を ±5% 以内で達成できなかった（地形制約など）
  distanceNotAchievable,

  /// APIリクエストがタイムアウトした
  timeout,

  /// 不正な入力値
  invalidInput,
}

/// ルート生成の例外
class RouteApiException implements Exception {
  const RouteApiException(this.type, this.message);

  final RouteErrorType type;
  final String message;

  @override
  String toString() => 'RouteApiException(${type.name}): $message';
}

// ---------------------------------------------------------------------------
// 生成結果（sealed class）
// ---------------------------------------------------------------------------

/// ルート生成の結果型（成功 or 失敗）
sealed class RouteGenerationResult {
  const RouteGenerationResult();
}

/// ルート生成成功
final class RouteSuccess extends RouteGenerationResult {
  const RouteSuccess(this.route);
  final RouteResult route;
}

/// ルート生成失敗
final class RouteFailure extends RouteGenerationResult {
  const RouteFailure({required this.errorType, required this.message});

  final RouteErrorType errorType;
  final String message;

  /// UI に表示するユーザー向けメッセージ
  String get userMessage => switch (errorType) {
        RouteErrorType.rateLimitExceeded =>
          '本日のルート生成回数の上限（10回）に達しました。明日またお試しください。',
        RouteErrorType.networkError =>
          'ネットワークエラーが発生しました。通信環境を確認してください。',
        RouteErrorType.noRouteFound =>
          'この付近ではルートを生成できませんでした。別の場所でお試しください。',
        RouteErrorType.distanceNotAchievable =>
          '指定した距離のルートを生成できませんでした。距離を変更してみてください。',
        RouteErrorType.timeout =>
          'リクエストがタイムアウトしました。通信環境を確認して再度お試しください。',
        RouteErrorType.invalidInput => '入力値が正しくありません。',
      };
}
