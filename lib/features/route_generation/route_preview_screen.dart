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

  // ---------------------------------------------------------------------------
  // ポリライン オフセット描画
  // ---------------------------------------------------------------------------

  /// 周回ルート用: 前半(往路)と後半(復路)を分けて 2 本のオフセットポリラインで描画。
  ///
  /// 共通区間では 2 色が隣接して見え（ズーム 16 以上で明確分離）、
  /// 分岐点では色が二叉に分かれるため「どちらへ進むか」が一目で分かる。
  PolylineLayer _buildOffsetPolylineLayer(
    List<LatLng> points,
    ColorScheme colorScheme,
  ) {
    final mid = points.length ~/ 2;
    final outbound = points.sublist(0, mid + 1); // 往路: 始点 → 折返し点
    final returning = points.sublist(mid);        // 復路: 折返し点 → 終点

    // 4 m オフセット: ズーム 16 以上で視覚的に分離
    const kOffset = 4.0;
    const kOrange = Color(0xFFF57C00); // Colors.orange.shade700 相当

    return PolylineLayer(
      polylines: [
        // 往路（テーマカラー・右オフセット）
        Polyline(
          points: _offsetPolyline(outbound, kOffset),
          strokeWidth: 4.5,
          color: colorScheme.primary,
          borderColor: colorScheme.primary.withValues(alpha: 0.25),
          borderStrokeWidth: 1.5,
        ),
        // 復路（オレンジ・左オフセット）
        Polyline(
          points: _offsetPolyline(returning, -kOffset),
          strokeWidth: 4.5,
          color: kOrange,
          borderColor: kOrange.withValues(alpha: 0.25),
          borderStrokeWidth: 1.5,
        ),
      ],
    );
  }

  /// ポリラインを進行方向の右側に [offsetMeters] だけ平行移動した点列を返す。
  ///
  /// 負値のとき左側に移動する。前後セグメントの方向を平均して
  /// 折れ目のある箇所でも滑らかな法線を算出する。
  List<LatLng> _offsetPolyline(List<LatLng> points, double offsetMeters) {
    if (points.length < 2) return List.of(points);
    const metersPerDeg = 111319.9;
    final result = <LatLng>[];

    for (int i = 0; i < points.length; i++) {
      double sumE = 0.0, sumN = 0.0;

      // セグメント (a→b) の正規化方向ベクトルを East/North 成分で累積
      void accum(LatLng a, LatLng b) {
        final midLat = (a.latitude + b.latitude) / 2;
        final cosLat = math.cos(midLat * math.pi / 180);
        final dE = (b.longitude - a.longitude) * cosLat;
        final dN = b.latitude - a.latitude;
        final len = math.sqrt(dE * dE + dN * dN);
        if (len > 1e-12) {
          sumE += dE / len;
          sumN += dN / len;
        }
      }

      if (i > 0) accum(points[i - 1], points[i]);
      if (i < points.length - 1) accum(points[i], points[i + 1]);

      // 進行方向 (sumE, sumN) の右直角法線 = (sumN, -sumE) / |(sumE, sumN)|
      final len = math.sqrt(sumE * sumE + sumN * sumN);
      final rE = len > 1e-12 ? sumN / len : 0.0;
      final rN = len > 1e-12 ? -sumE / len : 0.0;

      final cosLat = math.cos(points[i].latitude * math.pi / 180);
      result.add(LatLng(
        points[i].latitude + rN * offsetMeters / metersPerDeg,
        points[i].longitude + rE * offsetMeters / (metersPerDeg * cosLat),
      ));
    }
    return result;
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
    // 周回ルートは往路・復路を 2 本のオフセット線で表示（重複区間の方向を視覚的に区別）
    // 片道ルートは従来通り 1 本
    final polylineLayer =
        result.routeType == RouteType.circular && result.points.length >= 4
            ? _buildOffsetPolylineLayer(result.points, colorScheme)
            : PolylineLayer(
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
                  targetDistanceMeters: _args?.distanceMeters,
                  onRegenerate: _isRegenerating ? null : _regenerate,
                  // T-3.1: conditionPre（走行前体調入力）を経由して activeRun へ
                  onStart: () =>
                      context.push(AppRoutes.conditionPre, extra: _args),
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
    this.targetDistanceMeters,
  });

  final RouteResult result;
  final bool isRegenerating;
  final String? error;
  final VoidCallback? onRegenerate;
  final VoidCallback onStart;

  /// 目標距離（m）。null の場合は乖離メッセージを表示しない
  final double? targetDistanceMeters;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // 距離乖離の判定（目標比 5% 超で表示）
    final targetDist = targetDistanceMeters;
    final hasDistanceDeviation = targetDist != null &&
        (result.distanceMeters - targetDist).abs() / targetDist > 0.05;
    final targetFormatted = targetDist != null
        ? (targetDist < 1000
            ? '${targetDist.round()}m'
            : '${(targetDist / 1000).toStringAsFixed(1)}km')
        : '';

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

          // 往路/復路 凡例（周回ルートのみ）
          if (result.routeType == RouteType.circular) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendLine(
                  color: Theme.of(context).colorScheme.primary,
                  label: '往路',
                ),
                const SizedBox(width: 24),
                _LegendLine(
                  color: const Color(0xFFF57C00),
                  label: '復路',
                ),
              ],
            ),
          ],

          // 距離乖離メッセージ（実際の距離が目標から 5% 超ずれた場合）
          if (hasDistanceDeviation) ...[
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: Colors.blue.shade700, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ルートの都合上、実際の距離が${result.formattedDistance}になっています（目標: $targetFormatted）。',
                      style: textTheme.bodySmall
                          ?.copyWith(color: Colors.blue.shade800),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // U-ターン警告（短距離で折り返しが発生した場合）
          if (result.hasUTurns) ...[
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: Colors.orange.shade700, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '短距離では道路の制約により折り返しが生じる場合があります。「別のルートを生成」で改善することがあります。',
                      style: textTheme.bodySmall
                          ?.copyWith(color: Colors.orange.shade800),
                    ),
                  ),
                ],
              ),
            ),
          ],

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

/// 往路/復路 凡例: 色付き線サンプル + ラベル
class _LegendLine extends StatelessWidget {
  const _LegendLine({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
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
