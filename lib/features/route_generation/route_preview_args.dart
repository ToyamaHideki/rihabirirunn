import 'package:latlong2/latlong.dart';

import '../../shared/models/route_result.dart';

/// S20 → S21 への画面遷移引数
///
/// GoRouter extra として渡す。
/// RoutePreviewScreen での再生成にも使用する。
class RoutePreviewArgs {
  const RoutePreviewArgs({
    required this.routeResult,
    required this.distanceMeters,
    required this.routeType,
    required this.departure,
    this.destination,
  });

  /// 生成済みルート結果
  final RouteResult routeResult;

  /// 要求した目標距離（m）
  final double distanceMeters;

  /// ルート種別（周回 / 片道）
  final RouteType routeType;

  /// 出発地点
  final LatLng departure;

  /// 目的地（片道でユーザーが明示指定した場合のみ非 null）
  final LatLng? destination;

  /// 同じパラメータで別ルートを生成する際に使うコピーメソッド
  RoutePreviewArgs copyWith({RouteResult? routeResult}) {
    return RoutePreviewArgs(
      routeResult: routeResult ?? this.routeResult,
      distanceMeters: distanceMeters,
      routeType: routeType,
      departure: departure,
      destination: destination,
    );
  }
}
