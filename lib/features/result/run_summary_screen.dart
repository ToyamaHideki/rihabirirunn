import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../database/database.dart';
import '../../shared/repositories/run_session_repository.dart';
import '../../shared/repositories/user_profile_repository.dart';
import '../../shared/router/app_routes.dart';
import '../../shared/widgets/app_map.dart';

/// S31: 走行サマリー画面
///
/// T-2.4.4: 距離/時間/ペース/カロリーの UI
/// T-2.4.3: 達成判定バッジ（95% 以上で「目標達成！」）
/// T-2.4.5: カロリーは RunSession.estimatedCalories から取得
/// T-2.4.6: GPS 軌跡の縮小地図表示
class RunSummaryScreen extends ConsumerStatefulWidget {
  const RunSummaryScreen({required this.sessionId, super.key});

  final String sessionId;

  @override
  ConsumerState<RunSummaryScreen> createState() => _RunSummaryScreenState();
}

class _RunSummaryScreenState extends ConsumerState<RunSummaryScreen> {
  RunSession? _session;
  List<GpsPoint> _gpsPoints = const [];
  UserProfile? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.sessionId == 'pending') {
      setState(() {
        _loading = false;
        _error = 'セッションデータが見つかりません';
      });
      return;
    }
    try {
      final repo = ref.read(runSessionRepositoryProvider);
      final session = await repo.getSession(widget.sessionId);
      final points = await repo.getGpsPoints(widget.sessionId);
      // T-3.2.4: 次回目標表示のためにプロフィール取得
      final profile =
          await ref.read(userProfileRepositoryProvider).getProfile();
      if (mounted) {
        setState(() {
          _session = session;
          _gpsPoints = points;
          _profile = profile;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'データの読み込みに失敗しました';
        });
      }
    }
  }

  // ---- ユーティリティ ----

  /// GPS ポイント群の重心（地図初期中心）
  LatLng _trackCenter(List<GpsPoint> points) {
    if (points.isEmpty) return const LatLng(35.6812362, 139.7671248);
    double sumLat = 0, sumLng = 0;
    for (final p in points) {
      sumLat += p.lat;
      sumLng += p.lng;
    }
    return LatLng(sumLat / points.length, sumLng / points.length);
  }

  /// 軌跡のバウンディングボックスからズームレベルを推定する
  double _autoZoom(List<GpsPoint> points) {
    if (points.isEmpty) return 14.0;
    double minLat = points.first.lat, maxLat = points.first.lat;
    double minLng = points.first.lng, maxLng = points.first.lng;
    for (final p in points) {
      if (p.lat < minLat) minLat = p.lat;
      if (p.lat > maxLat) maxLat = p.lat;
      if (p.lng < minLng) minLng = p.lng;
      if (p.lng > maxLng) maxLng = p.lng;
    }
    // 対角線の長さ（度）でズームレベルを概算
    final diagDeg = math.sqrt(
      math.pow(maxLat - minLat, 2) + math.pow(maxLng - minLng, 2),
    );
    if (diagDeg < 0.005) return 16.0;
    if (diagDeg < 0.02) return 14.5;
    if (diagDeg < 0.05) return 13.5;
    if (diagDeg < 0.1) return 12.5;
    return 11.5;
  }

  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.round()}m';
    return '${(meters / 1000).toStringAsFixed(2)}km';
  }

  String _formatElapsed(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _formatPace(double? paceSecsPerKm) {
    if (paceSecsPerKm == null || paceSecsPerKm <= 0) return "--'--\"";
    final secs = paceSecsPerKm.round();
    final m = secs ~/ 60;
    final s = secs % 60;
    return "$m'${s.toString().padLeft(2, '0')}\"";
  }

  // ---- ビルド ----

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // ---- ローディング ----
    if (_loading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('走行データを保存中…', style: textTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    // ---- エラー ----
    if (_error != null || _session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('走行完了')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 64, color: colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  _error ?? 'エラーが発生しました',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('ホームへ'),
                  onPressed: () => context.go(AppRoutes.home),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ---- メイン ----
    final session = _session!;
    final isAchieved = session.isGoalAchieved;
    final gpsLatLng =
        _gpsPoints.map((p) => LatLng(p.lat, p.lng)).toList();
    final trackCenter = _trackCenter(_gpsPoints);
    final zoom = _autoZoom(_gpsPoints);
    final achieveRatePct = session.plannedDistance > 0
        ? (session.actualDistance / session.plannedDistance * 100)
            .clamp(0, 999)
            .round()
        : 0;

    // T-2.4.6: 実績軌跡ポリライン
    final trackLayer = gpsLatLng.length >= 2
        ? PolylineLayer(
            polylines: [
              Polyline(
                points: gpsLatLng,
                strokeWidth: 5.0,
                color: colorScheme.primary,
                borderColor:
                    colorScheme.primary.withValues(alpha: 0.35),
                borderStrokeWidth: 2.0,
              ),
            ],
          )
        : null;

    // 出発/到着マーカー
    final markerLayer = gpsLatLng.isNotEmpty
        ? MarkerLayer(
            markers: [
              Marker(
                point: gpsLatLng.first,
                width: 32,
                height: 32,
                child: _RouteMarker(
                    color: Colors.green.shade600, label: 'S'),
              ),
              if (gpsLatLng.length > 1)
                Marker(
                  point: gpsLatLng.last,
                  width: 32,
                  height: 32,
                  child: _RouteMarker(
                      color: Colors.red.shade600, label: 'E'),
                ),
            ],
          )
        : null;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('走行完了'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ---- T-2.4.6: 軌跡地図（上 40%）----
          Expanded(
            flex: 40,
            child: gpsLatLng.isNotEmpty
                ? AppMap(
                    initialZoom: zoom,
                    initialCenter: trackCenter,
                    showCurrentLocation: false,
                    centerOnLocationUpdate: false,
                    layers: [?trackLayer, ?markerLayer],
                  )
                : ColoredBox(
                    color: colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.gps_off_rounded,
                              size: 40,
                              color: colorScheme.onSurfaceVariant),
                          const SizedBox(height: 8),
                          Text(
                            'GPS 軌跡なし',
                            style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // ---- サマリーパネル（下 60%）----
          Expanded(
            flex: 60,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // T-2.4.3: 達成バッジ
                  _AchievementBadge(
                    isAchieved: isAchieved,
                    achieveRatePct: achieveRatePct,
                  ),
                  const SizedBox(height: 20),

                  // T-2.4.4: 4 指標グリッド（距離・時間・ペース・カロリー）
                  GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.7,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _MetricCard(
                        icon: Icons.straighten_rounded,
                        label: '距離',
                        value: _formatDistance(session.actualDistance),
                      ),
                      _MetricCard(
                        icon: Icons.schedule_rounded,
                        label: '時間',
                        value: _formatElapsed(session.durationSeconds),
                      ),
                      _MetricCard(
                        icon: Icons.speed_rounded,
                        label: 'ペース',
                        value: _formatPace(session.avgPaceSecsPerKm),
                      ),
                      _MetricCard(
                        icon: Icons.local_fire_department_rounded,
                        label: 'カロリー',
                        value: session.estimatedCalories != null
                            ? '${session.estimatedCalories} kcal'
                            : '--',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 計画 vs 実績バー
                  _PlanVsActualRow(
                    plannedM: session.plannedDistance,
                    actualM: session.actualDistance,
                    achieveRatePct: achieveRatePct,
                  ),
                  const SizedBox(height: 16),

                  // T-3.2.4: 次回目標距離
                  if (_profile != null)
                    _NextTargetCard(
                      profile: _profile!,
                      basePlannedM: session.plannedDistance,
                    ),
                  const SizedBox(height: 28),

                  // 走行後体調入力へ（T-3.1: conditionPost 経由でホームへ）
                  FilledButton.icon(
                    icon: const Icon(Icons.edit_note_rounded),
                    label: const Text('体調を記録する'),
                    onPressed: () => context.go(
                      AppRoutes.conditionPost,
                      extra: widget.sessionId,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// T-2.4.3: 達成バッジ
// ---------------------------------------------------------------------------

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({
    required this.isAchieved,
    required this.achieveRatePct,
  });

  final bool isAchieved;
  final int achieveRatePct;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color =
        isAchieved ? colorScheme.primary : Colors.orange.shade700;
    final icon =
        isAchieved ? Icons.emoji_events_rounded : Icons.directions_walk_rounded;
    final title = isAchieved ? '目標達成！' : 'お疲れさまでした';
    final sub = isAchieved
        ? '計画距離の $achieveRatePct% を歩きました 🎉'
        : '計画距離の $achieveRatePct% まで歩きました';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 44),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sub,
                  style: textTheme.bodySmall
                      ?.copyWith(color: color.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// T-2.4.4: 指標カード
// ---------------------------------------------------------------------------

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: colorScheme.primary, size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 計画 vs 実績バー
// ---------------------------------------------------------------------------

class _PlanVsActualRow extends StatelessWidget {
  const _PlanVsActualRow({
    required this.plannedM,
    required this.actualM,
    required this.achieveRatePct,
  });

  final double plannedM;
  final double actualM;
  final int achieveRatePct;

  static String _fmt(double m) {
    if (m < 1000) return '${m.round()}m';
    return '${(m / 1000).toStringAsFixed(2)}km';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final barColor = achieveRatePct >= 95
        ? colorScheme.primary
        : Colors.orange.shade700;

    return Row(
      children: [
        // 計画
        SizedBox(
          width: 60,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '計画',
                style: textTheme.labelSmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              Text(
                _fmt(plannedM),
                style: textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),

        // プログレスバー
        Expanded(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (achieveRatePct / 100).clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: colorScheme.outlineVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$achieveRatePct%',
                style: textTheme.labelSmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),

        // 実績
        SizedBox(
          width: 60,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '実績',
                style: textTheme.labelSmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              Text(
                _fmt(actualM),
                style: textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// T-3.2.4: 次回目標距離カード
// ---------------------------------------------------------------------------

class _NextTargetCard extends StatelessWidget {
  const _NextTargetCard({
    required this.profile,
    required this.basePlannedM,
  });

  final UserProfile profile;

  /// 今回の計画距離（変化の基準に使用）
  final double basePlannedM;

  String _fmtM(double m) {
    if (m >= 1000) {
      return '${(m / 1000).toStringAsFixed(2)} km';
    }
    return '${m.round()} m';
  }

  String _modeLabel(String mode) {
    switch (mode) {
      case 'conservative':
        return '慎重';
      case 'standard':
        return '標準';
      case 'challenge':
        return 'チャレンジ';
      case 'custom':
        return 'カスタム';
      default:
        return mode;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final nextTarget = profile.currentTargetDistance;
    final delta = nextTarget - basePlannedM;
    final isCustom = profile.mode == 'custom';

    String deltaText;
    Color deltaColor;
    if (isCustom) {
      deltaText = 'カスタムモード（手動設定）';
      deltaColor = colorScheme.onSurfaceVariant;
    } else if (delta.abs() < 50) {
      deltaText = '変更なし';
      deltaColor = colorScheme.onSurfaceVariant;
    } else if (delta > 0) {
      final pct = (delta / basePlannedM * 100).round();
      deltaText = '+${_fmtM(delta)} (+$pct%)';
      deltaColor = colorScheme.primary;
    } else {
      final pct = (delta / basePlannedM * 100).round();
      deltaText = '${_fmtM(delta)} ($pct%)';
      deltaColor = Colors.orange;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.flag_rounded,
              color: colorScheme.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '次回の目標',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  _fmtM(nextTarget),
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _modeLabel(profile.mode),
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                deltaText,
                style: textTheme.bodySmall?.copyWith(
                  color: deltaColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// T-2.4.6: ルートマーカー
// ---------------------------------------------------------------------------

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
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
