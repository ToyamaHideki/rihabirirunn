import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../shared/router/app_routes.dart';
import '../../shared/services/tracking_service.dart';
import '../../shared/widgets/app_map.dart';
import '../route_generation/route_preview_args.dart';

/// S30: 走行中ナビ
///
/// T-2.2.1: フルスクリーン地図（ボトムナビ非表示）
/// T-2.2.2: リアルタイム情報オーバーレイ（距離・ペース・経過時間・残距離）
/// T-2.2.3: 計画ルート（グレー）＋実績軌跡（primary）の 2 色ポリライン
/// T-2.2.4: 一時停止・再開ボタン
/// T-2.2.5: 終了ボタン（確認ダイアログ）→ サマリー画面へ
/// T-2.2.6: 画面オフ防止（WakelockPlus）
class ActiveRunScreen extends ConsumerStatefulWidget {
  const ActiveRunScreen({super.key});

  @override
  ConsumerState<ActiveRunScreen> createState() => _ActiveRunScreenState();
}

class _ActiveRunScreenState extends ConsumerState<ActiveRunScreen> {
  RoutePreviewArgs? _args;
  bool _initialized = false;

  // ---- ライフサイクル ----

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    // GoRouter extra から計画ルート情報を受け取る
    final extra = GoRouterState.of(context).extra;
    if (extra is RoutePreviewArgs) {
      _args = extra;
    }

    // 画面構築後に追跡開始・画面オフ防止を設定
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // T-2.2.6: 画面オフ防止
      await WakelockPlus.enable();
      // GPS 追跡開始
      if (mounted) {
        await ref.read(trackingNotifierProvider.notifier).start();
      }
    });
  }

  @override
  void dispose() {
    // T-2.2.6: 画面オフ防止を解除
    WakelockPlus.disable();
    super.dispose();
  }

  // ---- ユーティリティ ----

  /// 計画ルートの重心（地図の初期中心）
  LatLng? _routeCenter() {
    final points = _args?.routeResult.points;
    if (points == null || points.isEmpty) return null;
    double sumLat = 0, sumLng = 0;
    for (final p in points) {
      sumLat += p.latitude;
      sumLng += p.longitude;
    }
    return LatLng(sumLat / points.length, sumLng / points.length);
  }

  /// 残距離の表示文字列（計画距離 − 実績距離、0 以上）
  String _formatRemaining(double actualMeters) {
    final planned = _args?.routeResult.distanceMeters ?? 0.0;
    final rem = (planned - actualMeters).clamp(0.0, double.infinity);
    if (rem < 1000) return '${rem.round()}m';
    return '${(rem / 1000).toStringAsFixed(2)}km';
  }

  // ---- T-2.2.5: 終了確認ダイアログ ----

  Future<void> _showStopDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('走行を終了しますか？'),
        content: const Text('終了すると現在の走行データが記録されます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('終了する'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // 追跡停止（T-2.4 で DB 保存・sessionId 取得を行う）
      await ref.read(trackingNotifierProvider.notifier).stop();
      if (mounted) {
        // サマリー画面へ（T-2.4 実装後に実際の sessionId に置き換え）
        context.go(AppRoutes.runSummaryPath('pending'));
      }
    }
  }

  // ---- ビルド ----

  @override
  Widget build(BuildContext context) {
    final trackingState = ref.watch(trackingNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final padding = MediaQuery.of(context).padding;

    // T-2.2.3: 計画ルートポリライン（薄いグレー）
    final plannedPoints = _args?.routeResult.points ?? const [];
    final plannedLayer = plannedPoints.length >= 2
        ? PolylineLayer(
            polylines: [
              Polyline(
                points: plannedPoints,
                strokeWidth: 4.0,
                color: Colors.grey.shade400.withValues(alpha: 0.75),
              ),
            ],
          )
        : null;

    // T-2.2.3: 実績軌跡ポリライン（primary カラー）
    final actualLayer = trackingState.positions.length >= 2
        ? PolylineLayer(
            polylines: [
              Polyline(
                points: trackingState.positions,
                strokeWidth: 5.0,
                color: colorScheme.primary,
                borderColor:
                    colorScheme.primary.withValues(alpha: 0.35),
                borderStrokeWidth: 2.0,
              ),
            ],
          )
        : null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // ステータスバーアイコンを白に（地図背景が暗い場合に視認性確保）
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ---- T-2.2.1: フルスクリーン地図 ----
            AppMap(
              initialZoom: 16.5,
              initialCenter: _routeCenter(),
              showCurrentLocation: true,
              // 走行中のみ追跡センタリング（一時停止中は固定）
              centerOnLocationUpdate: trackingState.isTracking,
              layers: [
                ?plannedLayer,
                ?actualLayer,
              ],
            ),

            // ---- T-2.2.2: 統計オーバーレイ（上部） ----
            Positioned(
              top: padding.top + 8,
              left: 12,
              right: 12,
              child: _StatsOverlay(
                formattedDistance:
                    trackingState.formattedDistance,
                formattedPace: trackingState.formattedPace,
                formattedElapsed: trackingState.formattedElapsed,
                formattedRemaining:
                    _formatRemaining(trackingState.distanceMeters),
              ),
            ),

            // ---- 一時停止バナー ----
            if (trackingState.isPaused)
              Positioned(
                top: padding.top + 108,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade700
                          .withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text(
                      '一時停止中',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),

            // ---- T-2.2.4 / T-2.2.5: コントロールバー（下部） ----
            Positioned(
              bottom: padding.bottom + 28,
              left: 0,
              right: 0,
              child: _ControlBar(
                isPaused: trackingState.isPaused,
                onPause: () =>
                    ref.read(trackingNotifierProvider.notifier).pause(),
                onResume: () =>
                    ref.read(trackingNotifierProvider.notifier).resume(),
                onStop: _showStopDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// T-2.2.2: 統計オーバーレイ
// ---------------------------------------------------------------------------

class _StatsOverlay extends StatelessWidget {
  const _StatsOverlay({
    required this.formattedDistance,
    required this.formattedPace,
    required this.formattedElapsed,
    required this.formattedRemaining,
  });

  final String formattedDistance;
  final String formattedPace;
  final String formattedElapsed;
  final String formattedRemaining;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.68),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: _StatCell(
                  label: '距離',
                  value: formattedDistance,
                ),
              ),
              _StatDivider(),
              Expanded(
                child: _StatCell(
                  label: 'ペース',
                  value: formattedPace,
                ),
              ),
              _StatDivider(),
              Expanded(
                child: _StatCell(
                  label: '経過',
                  value: formattedElapsed,
                ),
              ),
              _StatDivider(),
              Expanded(
                child: _StatCell(
                  label: '残距離',
                  value: formattedRemaining,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.62),
            fontSize: 10,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: Colors.white.withValues(alpha: 0.18),
    );
  }
}

// ---------------------------------------------------------------------------
// T-2.2.4 / T-2.2.5: コントロールバー
// ---------------------------------------------------------------------------

class _ControlBar extends StatelessWidget {
  const _ControlBar({
    required this.isPaused,
    required this.onPause,
    required this.onResume,
    required this.onStop,
  });

  final bool isPaused;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // T-2.2.4: 一時停止 / 再開ボタン
        _RoundButton(
          icon: isPaused
              ? Icons.play_arrow_rounded
              : Icons.pause_rounded,
          backgroundColor:
              isPaused ? Colors.orange.shade600 : Colors.white,
          iconColor: isPaused ? Colors.white : Colors.black87,
          size: 64,
          onTap: isPaused ? onResume : onPause,
          tooltip: isPaused ? '再開' : '一時停止',
        ),
        const SizedBox(width: 48),
        // T-2.2.5: 終了ボタン
        _RoundButton(
          icon: Icons.stop_rounded,
          backgroundColor: Colors.red.shade600,
          iconColor: Colors.white,
          size: 64,
          onTap: onStop,
          tooltip: '走行終了',
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.size,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: backgroundColor,
        shape: const CircleBorder(),
        elevation: 6,
        shadowColor: Colors.black38,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, color: iconColor, size: size * 0.47),
          ),
        ),
      ),
    );
  }
}
