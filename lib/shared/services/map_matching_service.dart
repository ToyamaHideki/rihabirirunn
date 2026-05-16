import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// T-2.5: Mapbox Map Matching API クライアント
///
/// 走行終了時に蓄積した GPS 座標列を道路ネットワークにスナップし、
/// 「線が道から逸れて見える」問題を解消する。
///
/// - profile: walking
/// - 100 点までを 1 リクエストで処理（API 制限）
/// - 長いトレースは 1 点オーバーラップしながらバッチ分割
/// - 失敗 / トークン未設定時は生データをそのまま返す（フォールバック）
class MapMatchingService {
  MapMatchingService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _profile = 'walking';
  static const _baseUrl =
      'https://api.mapbox.com/matching/v5/mapbox/$_profile';
  static const _timeout = Duration(seconds: 15);

  /// API の最大ポイント数
  static const _maxPointsPerRequest = 100;

  /// バッチ間のオーバーラップ点数（接続部の不連続を抑える）
  static const _overlap = 1;

  String get _token => dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';

  /// GPS 座標列を道路にスナップした座標列に変換する。
  ///
  /// 失敗した場合は元の `positions` をそのまま返す（フォールバック）。
  /// 補正が無効化されたケースでは呼び出し側でこのメソッド自体を呼ばないこと。
  Future<List<LatLng>> match(List<LatLng> positions) async {
    // 入力が短すぎる、またはトークン未設定 → そのまま返す
    if (positions.length < 2) return positions;
    if (_token.isEmpty) return positions;

    try {
      // 100 点ずつ（1 点オーバーラップ）に分割
      final batches = <List<LatLng>>[];
      final step = _maxPointsPerRequest - _overlap;
      for (var i = 0; i < positions.length; i += step) {
        final end = (i + _maxPointsPerRequest).clamp(0, positions.length);
        batches.add(positions.sublist(i, end));
        if (end == positions.length) break;
      }

      final merged = <LatLng>[];
      for (var batchIndex = 0; batchIndex < batches.length; batchIndex++) {
        final batch = batches[batchIndex];
        final matched = await _matchSingleBatch(batch);
        // 2 つ目以降は最初の点が前バッチの末尾と重複しているのでスキップ
        final skip = batchIndex == 0 ? 0 : 1;
        for (var i = skip; i < matched.length; i++) {
          merged.add(matched[i]);
        }
      }
      return merged.isEmpty ? positions : merged;
    } catch (e, st) {
      // ネットワーク障害・パースエラー等は致命的にせず生データへフォールバック
      debugPrint('MapMatchingService.match fell back to raw GPS: $e\n$st');
      return positions;
    }
  }

  /// 単一バッチを Map Matching API に投げる
  ///
  /// 失敗時はそのバッチの元データを返す（フォールバック）。
  Future<List<LatLng>> _matchSingleBatch(List<LatLng> batch) async {
    if (batch.length < 2) return batch;

    final coords = batch
        .map((p) =>
            '${p.longitude.toStringAsFixed(6)},${p.latitude.toStringAsFixed(6)}')
        .join(';');

    // radiuses: 各点の探索半径（m）。GPS 精度を考慮して 25 m を指定。
    final radiuses = List.filled(batch.length, '25').join(';');

    final params = <String>[
      'geometries=geojson',
      'overview=full',
      'radiuses=$radiuses',
      'tidy=true',
      'access_token=$_token',
    ];

    final uri = Uri.parse('$_baseUrl/$coords?${params.join('&')}');

    try {
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode != 200) {
        debugPrint('MapMatching HTTP ${response.statusCode}: ${response.body}');
        return batch;
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final code = data['code'] as String? ?? '';
      if (code != 'Ok') {
        debugPrint('MapMatching code=$code body=${response.body}');
        return batch;
      }

      final matchings = data['matchings'] as List?;
      if (matchings == null || matchings.isEmpty) return batch;

      final geometry = (matchings.first as Map<String, dynamic>)['geometry']
          as Map<String, dynamic>?;
      final coordinates = geometry?['coordinates'] as List?;
      if (coordinates == null || coordinates.isEmpty) return batch;

      return coordinates.map((c) {
        final coord = c as List;
        return LatLng(
          (coord[1] as num).toDouble(),
          (coord[0] as num).toDouble(),
        );
      }).toList();
    } on TimeoutException {
      debugPrint('MapMatching timeout');
      return batch;
    } on http.ClientException catch (e) {
      debugPrint('MapMatching client error: ${e.message}');
      return batch;
    } on FormatException catch (e) {
      debugPrint('MapMatching parse error: $e');
      return batch;
    }
  }
}

// ---- Riverpod プロバイダ ----

final mapMatchingServiceProvider = Provider<MapMatchingService>(
  (_) => MapMatchingService(),
);
