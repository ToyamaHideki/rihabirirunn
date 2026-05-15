import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../shared/models/route_result.dart';
import '../../shared/router/app_routes.dart';
import '../../shared/services/directions_service.dart';
import '../../shared/services/route_generator.dart';
import '../../shared/widgets/app_map.dart';
import '../../shared/widgets/primary_button.dart';
import 'route_preview_args.dart';

/// S21: ルートプレビュー画面
///
/// T-1.3.5: 生成済みルートをポリラインで地図表示
/// T-1.3.6: 別ルートを再生成するボタン
class RoutePreviewScreen extends ConsumerStatefulWidget {
  const RoutePreviewScreen({super.key});

  @override
  ConsumerState<RoutePreviewScreen> createState() =>
      _RoutePreviewScreenState();
}

class _RoutePreviewScreenState extends ConsumerState<RoutePreviewScreen> {
  RoutePreviewArgs? _args;
  RouteResult? _result;
  bool _isRegenerating = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // GoRouter extra から引数を取得（初回のみ）
    if (_args == null) {
      final extra = GoRouterState.of(context).extra;
      if (extra is RoutePreviewArgs) {
        _args = extra;
        _result = extra.routeResult;
      }
    }
  }

  /// T-1.3.6: 別ルートを再生成
  Future<void> _regenerate() async {
    final args = _args;
    if (args == null) return;

    setState(() {
      _isRegenerating = true;
      _error = null;
    });

    final generator = ref.read(routeGeneratorProvider);
    final bearingOffset = math.Random().nextDouble() * 360;

    RouteGenerationResult result;

    if (args.routeType == RouteType.circular) {
      result = await generator.generateCircularRoute(
        start: args.departure,
        targetDistanceMeters: args.distanceMeters,
        bearingOffsetDeg: bearingOffset,
      );
    } else if (args.destination != null) {
      try {
        final route = await ref.read(directionsServiceProvider).getRoute(
          [args.departure, args.destination!],
          routeType: RouteType.oneWay,
        );
        result = RouteSuccess(route);
      } on RouteApiException catch (e) {
        result = RouteFailure(errorType: e.type, message: e.message);
      }
    } else {
      result = await generator.generateOneWayRoute(
        start: args.departure,
        targetDistanceMeters: args.distanceMeters,
        bearingDeg: bearingOffset,
      );
    }

    if (!mounted) return;
    setState(() => _isRegenerating = false);

    switch (result) {
      case RouteSuccess(:final route):
        setState(() {
          _result = route;
          _args = args.copyWith(routeResult: route);
        });
      case RouteFailure():
        setState(() => _error = (result as RouteFailure).userMessage);
    }
  }

  /// ルートの重心を計算（地図の初期中心に使用）
  LatLng _routeCenter(List<LatLng> points) {
    if (points.isEmpty) return const LatLng(35.6812362, 139.7671248);
    double sumLat = 0, sumLng = 0;
    for (final p in points) {
      sumLat += p.latitude;
      sumLng += p.longitude;
    }
    return LatLng(sumLat / points.length, sumLng / points.length);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final result = _result;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('ルートプレビュー')),
        body: const Center(child: Text('ルート情報がありません')),
      );
    }

    final center = _routeCenter(result.points);

    // T-1.3.5: ポリラインレイヤー
    final polylineLayer = PolylineLayer(
      polylines: [
        Polyline(
          points: result.points,
          strokeWidth: 5.0,
          color: colorScheme.primary,
          borderColor: colorScheme.primary.withValues(alpha: 0.3),
          borderStrokeWidth: 2.0,
        ),
      ],
    );

    // 出発地・終点マーカー
    final markerLayer = MarkerLayer(
      markers: [
        Marker(
          point: result.points.first,
          width: 36,
          height: 36,
          child: _RouteMarker(
            color: Colors.green.shade600,
            label: result.routeType == RouteType.circular ? 'S/E' : 'S',
          ),
        ),
        if (result.routeType == RouteType.oneWay &&
            result.points.length > 1)
          Marker(
            point: result.points.last,
            width: 36,
            height: 36,
            child: _RouteMarker(color: Colors.red.shade600, label: 'E'),
          ),
      ],
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.88),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text('ルートプレビュー', style: textTheme.titleMedium),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // ---- T-1.3.5: ルート地図（60%）----
              Expanded(
                flex: 60,
                child: AppMap(
                  initialZoom: 14.0,
                  initialCenter: center,
                  showCurrentLocation: false,
                  centerOnLocationUpdate: false,
                  layers: [polylineLayer, markerLayer],
                ),
              ),

              // ---- ルート情報 + ボタンパネル（40%）----
              Expanded(
                flex: 40,
                child: _PreviewPanel(
                  result: result,
                  isRegenerating: _isRegenerating,
                  error: _error,
                  onRegenerate: _isRegenerating ? null : _regenerate,
                  onStart: () => context.push(AppRoutes.conditionPre),
                ),
              ),
            ],
          ),

          // 再生成中オーバーレイ
          if (_isRegenerating)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.35),
                child: Center(
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: const Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('別のルートを探しています…'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// プレビューパネル
// ---------------------------------------------------------------------------

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({
    required this.result,
    required this.isRegenerating,
    required this.error,
    required this.onRegenerate,
    required this.onStart,
  });

  final RouteResult result;
  final bool isRegenerating;
  final String? error;
  final VoidCallback? onRegenerate;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ハンドルバー
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ---- ルート情報チップ ----
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _InfoChip(
                icon: Icons.straighten_rounded,
                label: result.formattedDistance,
                sublabel: '距離',
              ),
              _InfoChip(
                icon: Icons.schedule_rounded,
                label: result.formattedDuration,
                sublabel: '所要時間',
              ),
              _InfoChip(
                icon: result.routeType == RouteType.circular
                    ? Icons.loop_rounded
                    : Icons.arrow_forward_rounded,
                label: result.routeType.label,
                sublabel: 'ルート形状',
              ),
            ],
          ),

          // エラーメッセージ
          if (error != null) ...[
            const SizedBox(height: 8),
            Text(
              error!,
              style: textTheme.bodySmall
                  ?.copyWith(color: colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ],

          const Spacer(),

          // ---- ボタン ----
          PrimaryButton(
            icon: const Icon(Icons.directions_walk_rounded),
            label: 'この内容で出発する',
            onPressed: onStart,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('別のルートを生成'),
            onPressed: onRegenerate,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// サブウィジェット
// ---------------------------------------------------------------------------

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.sublabel,
  });

  final IconData icon;
  final String label;
  final String sublabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(icon, color: colorScheme.primary, size: 22),
        const SizedBox(height: 4),
        Text(
          label,
          style: textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          sublabel,
          style: textTheme.labelSmall
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _RouteMarker extends StatelessWidget {
  const _RouteMarker({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
