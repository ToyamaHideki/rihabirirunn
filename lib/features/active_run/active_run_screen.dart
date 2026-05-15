import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../shared/repositories/run_session_repository.dart';
import '../../shared/repositories/user_profile_repository.dart';
import '../../shared/router/app_routes.dart';
import '../../shared/services/target_distance_service.dart';
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
/// T-2.3.3: GPS ロスト警告バナー
/// T-2.3.4: バッテリー残量低下（20% 以下）警告バナー
class ActiveRunScreen extends ConsumerStatefulWidget {
  const ActiveRunScreen({super.key});

  @override
  ConsumerState<ActiveRunScreen> createState() => _ActiveRunScreenState();
}

class _ActiveRunScreenState extends ConsumerState<ActiveRunScreen> {
  RoutePreviewArgs? _args;
  bool _initialized = false;

  // T-2.4.1: 走行開始時刻（DB 保存時に使用）
  DateTime? _startedAt;

  // T-2.3.4: バッテリー状態
  final Battery _battery = Battery();
  int? _batteryLevel;
  Timer? _batteryTimer;

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

    // 画面構築後に追跡開始・画面オフ防止・バッテリー監視を設定
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // T-2.2.6: 画面オフ防止（Web 非対応）
      if (!kIsWeb) await WakelockPlus.enable();
      // GPS 追跡開始
      if (mounted) {
        _startedAt = DateTime.now(); // T-2.4.1: 開始時刻を記録
        await ref.read(trackingNotifierProvider.notifier).start();
      }
      // T-2.3.4: バッテリー初回チェック（Web 非対応）
      if (!kIsWeb && mounted) _updateBattery();
    });

    // T-2.3.4: バッテリーを 60 秒ごとにチェック（Web 非対応）
    if (!kIsWeb) {
      _batteryTimer = Timer.periodic(
        const Duration(seconds: 60),
        (_) {
          if (mounted) _updateBattery();
        },
      );
    }
  }

  @override
  void dispose() {
    // T-2.2.6: 画面オフ防止を解除（Web 非対応）
    if (!kIsWeb) WakelockPlus.disable();
    _batteryTimer?.cancel();
    super.dispose();
  }

  // ---- T-2.3.4: バッテリー取得 ----

  Future<void> _updateBattery() async {
    try {
      final level = await _battery.batteryLevel;
      if (mounted) {
        setState(() => _batteryLevel = level);
      }
    } catch (_) {
      // バッテリー情報が取得できない端末（エミュレーターなど）では無視
    }
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
      // 追跡停止
      final finalState =
          await ref.read(trackingNotifierProvider.notifier).stop();
      if (!mounted) return;

      // T-2.4.1: DB 保存 → sessionId 取得
      final profile =
          await ref.read(userProfileRepositoryProvider).getProfile();
      if (!mounted) return;

      if (profile != null) {
        final sessionId =
            await ref.read(runSessionRepositoryProvider).saveSession(
          userId: profile.id,
          startedAt: _startedAt ??
              DateTime.now()
                  .subtract(Duration(seconds: finalState.elapsedSeconds)),
          trackingState: finalState,
          plannedDistanceM: _args?.distanceMeters,
          routeType: _args?.routeType,
          routePoints: _args?.routeResult.points,
          departurePoint: _args?.departure,
        );
        if (!mounted) return;

        // T-3.2.3: 走行完了後の目標距離自動更新
        final savedSession =
            await ref.read(runSessionRepositoryProvider).getSession(sessionId);
        if (!mounted) return;
        if (savedSession != null) {
          await ref.read(targetDistanceServiceProvider).updateAfterRun(
                profile: profile,
                session: savedSession,
              );
        }
        if (mounted) {
          context.go(AppRoutes.runSummaryPath(sessionId));
        }
      } else {
        // プロフィールなし（通常は発生しない）
        if (mounted) context.go(AppRoutes.home);
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

    // T-2.3.4: バッテリー警告表示条件（20% 以下、走行中 or 一時停止中）
    final showBatteryWarning =
        _batteryLevel != null &&
        _batteryLevel! <= 20 &&
        trackingState.isActive;

    // 警告バナーの縦位置: stats overlay の下
    // stats overlay: top + 8 + 約68px = top + 76
    final warningTop = padding.top + 80.0;

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
                formattedDistance: trackingState.formattedDistance,
                formattedPace: trackingState.formattedPace,
                formattedElapsed: trackingState.formattedElapsed,
                formattedRemaining:
                    _formatRemaining(trackingState.distanceMeters),
              ),
            ),

            // ---- T-2.3.3 / T-2.3.4: 警告バナー群（stats の下） ----
            if (trackingState.gpsLost || showBatteryWarning)
              Positioned(
                top: warningTop,
                left: 12,
                right: 12,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // T-2.3.3: GPS ロスト
                    if (trackingState.gpsLost && trackingState.isActive)
                      _WarningBanner(
                        icon: Icons.gps_off_rounded,
                        message: 'GPS 信号ロスト',
                        color: Colors.red.shade700,
                      ),
                    if (trackingState.gpsLost &&
                        trackingState.isActive &&
                        showBatteryWarning)
                      const SizedBox(height: 4),
                    // T-2.3.4: バッテリー低下
                    if (showBatteryWarning)
                      _WarningBanner(
                        icon: Icons.battery_alert_rounded,
                        message: 'バッテリー残量 $_batteryLevel%',
                        color: Colors.orange.shade800,
                      ),
                  ],
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
// T-2.3.3 / T-2.3.4: 警告バナー
// ---------------------------------------------------------------------------

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({
    required this.icon,
    required this.message,
    required this.color,
  });

  final IconData icon;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
        // T-2.2.4: 一時停止 / 再開
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
        // T-2.2.5: 終了
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
