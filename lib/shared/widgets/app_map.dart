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
/// - 走行追跡中は [currentPosition] を渡すことで位置ドットをリアルタイム追従
class AppMap extends ConsumerStatefulWidget {
  const AppMap({
    super.key,
    this.initialZoom = 16.0,
    this.initialCenter,
    this.showCurrentLocation = true,
    this.centerOnLocationUpdate = true,
    this.currentPosition,
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

  /// 現在地の上書き座標（走行追跡中など外部から位置を供給する場合に指定）。
  /// null のときは [currentPositionProvider]（一発取得）の位置を使用する。
  final LatLng? currentPosition;

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

  void _moveTo(LatLng point) {
    _mapController.move(point, widget.initialZoom);
  }

  @override
  void didUpdateWidget(AppMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 外部指定の現在地が変化したらマップを追従（走行追跡中のリアルタイム更新）
    if (!_mapReady || !widget.centerOnLocationUpdate) return;
    final newPos = widget.currentPosition;
    if (newPos != null && newPos != oldWidget.currentPosition) {
      _moveTo(newPos);
    }
  }

  @override
  Widget build(BuildContext context) {
    final posAsync = ref.watch(currentPositionProvider);
    final position = posAsync.valueOrNull;
    final colorScheme = Theme.of(context).colorScheme;

    // 外部指定の現在地があればそちらを優先（走行追跡中など）
    final effectiveLatLng = widget.currentPosition ??
        (position != null
            ? LatLng(position.latitude, position.longitude)
            : null);

    // 位置情報が変化したらマップをセンタリング（T-1.1.2）
    // 外部指定がある場合は didUpdateWidget で処理するためスキップ
    ref.listen<AsyncValue<Position?>>(currentPositionProvider, (_, next) {
      if (!_mapReady || !widget.centerOnLocationUpdate) return;
      if (widget.currentPosition != null) return; // 外部指定がある場合は無視
      final pos = next.valueOrNull;
      if (pos != null) _moveTo(LatLng(pos.latitude, pos.longitude));
    });

    // 初期中心: 引数指定 > 現在地 > 東京駅
    final defaultCenter = effectiveLatLng ?? const LatLng(35.6812362, 139.7671248);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: widget.initialCenter ?? defaultCenter,
        initialZoom: widget.initialZoom,
        onMapReady: () {
          _mapReady = true;
          if (widget.initialCenter == null) {
            if (widget.currentPosition != null) {
              _moveTo(widget.currentPosition!);
            } else if (position != null) {
              _moveTo(LatLng(position.latitude, position.longitude));
            }
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
        if (widget.showCurrentLocation && effectiveLatLng != null) ...[
          // 精度サークル: FutureProvider の Position が利用可能なときのみ表示
          // （外部指定の LatLng には accuracy 情報がないため省略）
          if (position != null && widget.currentPosition == null)
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
                point: effectiveLatLng,
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
