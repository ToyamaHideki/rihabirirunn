import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/route_result.dart';

/// T-1.2.1: Mapbox Directions API クライアント
///
/// - walking プロファイルで waypoints 間のルートを取得
/// - GeoJSON overview geometry を返す
/// - タイムアウト・HTTP エラー・API エラーを RouteApiException に統一
class DirectionsService {
  DirectionsService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _profile = 'walking';
  static const _baseUrl =
      'https://api.mapbox.com/directions/v5/mapbox/$_profile';
  static const _timeout = Duration(seconds: 10);

  String get _token => dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';

  /// ウェイポイントを結ぶ徒歩ルートを取得する
  ///
  /// [waypoints]: 始点〜終点を含む 2〜25 点のリスト。
  ///   周回ルートの場合は始点と終点を同一座標にすること。
  ///
  /// Throws [RouteApiException] on any failure.
  Future<RouteResult> getRoute(
    List<LatLng> waypoints, {
    required RouteType routeType,
  }) async {
    if (waypoints.length < 2) {
      throw const RouteApiException(
        RouteErrorType.invalidInput,
        'ウェイポイントは2点以上必要です',
      );
    }
    if (_token.isEmpty) {
      throw const RouteApiException(
        RouteErrorType.invalidInput,
        'Mapbox アクセストークンが設定されていません',
      );
    }

    // 座標文字列: "{lng},{lat};{lng},{lat};..."（経度が先）
    final coords = waypoints
        .map((p) =>
            '${p.longitude.toStringAsFixed(6)},${p.latitude.toStringAsFixed(6)}')
        .join(';');

    final uri = Uri.parse(
      '$_baseUrl/$coords'
      '?geometries=geojson'
      '&overview=full'
      '&steps=false'
      '&access_token=$_token',
    );

    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        throw RouteApiException(
          RouteErrorType.networkError,
          'HTTP ${response.statusCode}',
        );
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final code = data['code'] as String? ?? '';

      if (code != 'Ok') {
        final type = switch (code) {
          'NoRoute' => RouteErrorType.noRouteFound,
          'NoSegment' => RouteErrorType.noRouteFound,
          'InvalidInput' => RouteErrorType.invalidInput,
          _ => RouteErrorType.networkError,
        };
        throw RouteApiException(type, 'Mapbox code: $code');
      }

      final routes = data['routes'] as List?;
      if (routes == null || routes.isEmpty) {
        throw const RouteApiException(
          RouteErrorType.noRouteFound,
          'ルートが見つかりませんでした',
        );
      }

      final route = routes[0] as Map<String, dynamic>;
      final geometry = route['geometry'] as Map<String, dynamic>;
      final points = (geometry['coordinates'] as List)
          .map((c) {
            final coord = c as List;
            return LatLng(
              (coord[1] as num).toDouble(),
              (coord[0] as num).toDouble(),
            );
          })
          .toList();

      return RouteResult(
        points: points,
        distanceMeters: (route['distance'] as num).toDouble(),
        durationSeconds: (route['duration'] as num).round(),
        routeType: routeType,
      );
    } on RouteApiException {
      rethrow;
    } on TimeoutException {
      throw const RouteApiException(
        RouteErrorType.timeout,
        'リクエストがタイムアウトしました',
      );
    } on http.ClientException catch (e) {
      throw RouteApiException(
        RouteErrorType.networkError,
        'ネットワークエラー: ${e.message}',
      );
    } on FormatException catch (e) {
      throw RouteApiException(
        RouteErrorType.networkError,
        'レスポンス解析エラー: $e',
      );
    }
  }
}

// ---- Riverpod プロバイダ ----

final directionsServiceProvider = Provider<DirectionsService>(
  (_) => DirectionsService(),
);
