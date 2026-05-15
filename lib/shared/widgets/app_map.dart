import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../services/location_service.dart';

/// T-1.1.1 / T-1.1.2 / T-1.1.3: 共通地図ウィジェット
///
/// - Mapbox Streets タイルレイヤー表示
/// - 現在地へ自動センタリング（MapController）
/// - 現在地マーカー（精度サークル + 位置ドット）
/// - タップコールバック・初期中心指定（T-1.3 で追加）
class AppMap extends ConsumerStatefulWidget {
  const AppMap({
    super.key,
    this.initialZoom = 16.0,
    this.initialCenter,
    this.showCurrentLocation = true,
    this.centerOnLocationUpdate = true,
    this.onMapReady,
    this.onTap,
    this.layers = const [],
  });

  /// 初期ズームレベル（1–22）
  final double initialZoom;

  /// 初期表示中心（null の場合は現在地 or 東京駅）
  final LatLng? initialCenter;

  /// 現在地マーカーを表示するか
  final bool showCurrentLocation;

  /// 位置情報が更新されたときに地図を自動センタリングするか
  final bool centerOnLocationUpdate;

  /// マップ描画完了コールバック
  final VoidCallback? onMapReady;

  /// 地図タップコールバック（ピンドロップ等に使用）
  final void Function(LatLng)? onTap;

  /// 追加レイヤー（PolylineLayer, MarkerLayer など）
  final List<Widget> layers;

  @override
  ConsumerState<AppMap> createState() => _AppMapState();
}

class _AppMapState extends ConsumerState<AppMap> {
  final MapController _mapController = MapController();
  bool _mapReady = false;

  /// Mapbox Streets タイル URL（.env トークンを埋め込み）
  static String get _tileUrl {
    final token = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
    return 'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/256/{z}/{x}/{y}'
        '?access_token=$token';
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _moveTo(Position pos) {
    _mapController.move(
      LatLng(pos.latitude, pos.longitude),
      widget.initialZoom,
    );
  }

  @override
  Widget build(BuildContext context) {
    final posAsync = ref.watch(currentPositionProvider);
    final position = posAsync.valueOrNull;
    final colorScheme = Theme.of(context).colorScheme;

    // 位置情報が変化したらマップをセンタリング（T-1.1.2）
    ref.listen<AsyncValue<Position?>>(currentPositionProvider, (_, next) {
      if (!_mapReady || !widget.centerOnLocationUpdate) return;
      final pos = next.valueOrNull;
      if (pos != null) _moveTo(pos);
    });

    // 初期中心: 引数指定 > 現在地 > 東京駅
    final defaultCenter = position != null
        ? LatLng(position.latitude, position.longitude)
        : const LatLng(35.6812362, 139.7671248);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: widget.initialCenter ?? defaultCenter,
        initialZoom: widget.initialZoom,
        onMapReady: () {
          _mapReady = true;
          if (widget.initialCenter == null && position != null) {
            _moveTo(position);
          }
          widget.onMapReady?.call();
        },
        onTap: widget.onTap != null
            ? (_, point) => widget.onTap!(point)
            : null,
      ),
      children: [
        // T-1.1.1: Mapbox Streets タイルレイヤー
        TileLayer(
          urlTemplate: _tileUrl,
          userAgentPackageName: 'com.rihabirirun.app',
        ),

        // T-1.1.3: 現在地（精度サークル + 位置ドット）
        if (widget.showCurrentLocation && position != null) ...[
          CircleLayer(
            circles: [
              CircleMarker(
                point: LatLng(position.latitude, position.longitude),
                radius: position.accuracy.clamp(5.0, 200.0),
                useRadiusInMeter: true,
                color: colorScheme.primary.withValues(alpha: 0.15),
                borderColor: colorScheme.primary.withValues(alpha: 0.4),
                borderStrokeWidth: 1.0,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(position.latitude, position.longitude),
                width: 20,
                height: 20,
                child: _LocationDot(color: colorScheme.primary),
              ),
            ],
          ),
        ],

        // 追加レイヤー（ルートポリライン・ウェイポイントマーカー等）
        ...widget.layers,
      ],
    );
  }
}

/// 現在地ドット：白枠付き塗りつぶし円
class _LocationDot extends StatelessWidget {
  const _LocationDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}
