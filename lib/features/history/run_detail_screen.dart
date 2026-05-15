import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../database/database.dart';
import '../../shared/repositories/condition_log_repository.dart';
import '../../shared/repositories/run_session_repository.dart';
import '../../shared/widgets/app_map.dart';

// ---------------------------------------------------------------------------
// 部位コード → 表示ラベル
// ---------------------------------------------------------------------------

const _bodyPartLabels = {
  'neck': '首',
  'chest': '胸',
  'upper_back': '上背部',
  'lower_back': '腰',
  'left_shoulder': '左肩',
  'right_shoulder': '右肩',
  'left_elbow': '左肘',
  'right_elbow': '右肘',
  'left_wrist': '左手首',
  'right_wrist': '右手首',
  'left_hip': '左股関節',
  'right_hip': '右股関節',
  'left_knee': '左膝',
  'right_knee': '右膝',
  'left_shin': '左すね',
  'right_shin': '右すね',
  'left_calf': '左ふくらはぎ',
  'right_calf': '右ふくらはぎ',
  'left_ankle': '左足首',
  'right_ankle': '右足首',
  'left_sole': '左足底',
  'right_sole': '右足底',
};

// ---------------------------------------------------------------------------
// S41: 走行詳細画面
// ---------------------------------------------------------------------------

/// S41: 走行詳細
///
/// T-3.3.4: ルート・痛みスコア・メモを含む走行詳細を表示する
class RunDetailScreen extends ConsumerStatefulWidget {
  const RunDetailScreen({required this.sessionId, super.key});

  final String sessionId;

  @override
  ConsumerState<RunDetailScreen> createState() => _RunDetailScreenState();
}

class _RunDetailScreenState extends ConsumerState<RunDetailScreen> {
  RunSession? _session;
  List<GpsPoint> _gpsPoints = const [];
  List<ConditionLog> _conditionLogs = const [];
  Map<String, List<PainArea>> _painAreasByLog = const {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final sessionRepo = ref.read(runSessionRepositoryProvider);
      final condRepo = ref.read(conditionLogRepositoryProvider);

      final session = await sessionRepo.getSession(widget.sessionId);
      final gpsPoints = await sessionRepo.getGpsPoints(widget.sessionId);
      final condLogs =
          await condRepo.getConditionLogsForSession(widget.sessionId);

      final painAreasByLog = <String, List<PainArea>>{};
      for (final log in condLogs) {
        painAreasByLog[log.id] =
            await condRepo.getPainAreasForLog(log.id);
      }

      if (mounted) {
        setState(() {
          _session = session;
          _gpsPoints = gpsPoints;
          _conditionLogs = condLogs;
          _painAreasByLog = painAreasByLog;
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

  // ---- 地図ヘルパー ----

  LatLng _trackCenter(List<GpsPoint> points) {
    if (points.isEmpty) return const LatLng(35.6812362, 139.7671248);
    double sumLat = 0, sumLng = 0;
    for (final p in points) {
      sumLat += p.lat;
      sumLng += p.lng;
    }
    return LatLng(sumLat / points.length, sumLng / points.length);
  }

  double _autoZoom(List<GpsPoint> points) {
    if (points.length < 2) return 15.0;
    double minLat = points.first.lat, maxLat = points.first.lat;
    double minLng = points.first.lng, maxLng = points.first.lng;
    for (final p in points) {
      if (p.lat < minLat) minLat = p.lat;
      if (p.lat > maxLat) maxLat = p.lat;
      if (p.lng < minLng) minLng = p.lng;
      if (p.lng > maxLng) maxLng = p.lng;
    }
    final diag = ((maxLat - minLat) * (maxLat - minLat) +
            (maxLng - minLng) * (maxLng - minLng))
        .clamp(0.0001, 100.0);
    return (15.5 - 2.0 * (diag * 1000).clamp(0.0, 1.0)).clamp(11.5, 15.5);
  }

  // ---- フォーマットユーティリティ ----

  String _fmtDist(double m) {
    if (m >= 1000) return '${(m / 1000).toStringAsFixed(2)} km';
    return '${m.round()} m';
  }

  String _fmtElapsed(int sec) {
    if (sec >= 3600) {
      final h = sec ~/ 3600;
      final m = (sec % 3600) ~/ 60;
      final s = sec % 60;
      return "$h時間$m'${s.toString().padLeft(2, '0')}\"";
    }
    final m = sec ~/ 60;
    final s = sec % 60;
    return "$m'${s.toString().padLeft(2, '0')}\"";
  }

  String _fmtPace(double? secPerKm) {
    if (secPerKm == null || secPerKm <= 0) return '--';
    final min = (secPerKm ~/ 60).toString();
    final sec = (secPerKm.round() % 60).toString().padLeft(2, '0');
    return "$min'$sec\"/km";
  }

  String _painEmoji(int score) {
    if (score == 0) return '😊';
    if (score <= 2) return '🙂';
    if (score <= 4) return '😐';
    if (score <= 6) return '😟';
    if (score <= 8) return '😣';
    return '😖';
  }

  // ---- Build ----

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _session == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 48, color: colorScheme.error),
              const SizedBox(height: 12),
              Text(_error ?? 'データが見つかりません'),
            ],
          ),
        ),
      );
    }

    final session = _session!;
    final gpsLatLng = _gpsPoints.map((p) => LatLng(p.lat, p.lng)).toList();
    final trackCenter = _trackCenter(_gpsPoints);
    final zoom = _autoZoom(_gpsPoints);
    final title = DateFormat('M月d日(E)', 'ja').format(session.startedAt);
    final achieveRatePct = session.plannedDistance > 0
        ? (session.actualDistance / session.plannedDistance * 100)
            .clamp(0, 999)
            .round()
        : 0;

    // ポリライン
    final trackLayer = gpsLatLng.length >= 2
        ? PolylineLayer(
            polylines: [
              Polyline(
                points: gpsLatLng,
                strokeWidth: 4.0,
                color: colorScheme.primary,
                borderColor: colorScheme.primary.withValues(alpha: 0.3),
                borderStrokeWidth: 2.0,
              ),
            ],
          )
        : null;

    // S / E マーカー
    final markerLayer = gpsLatLng.isNotEmpty
        ? MarkerLayer(
            markers: [
              Marker(
                point: gpsLatLng.first,
                width: 24,
                height: 24,
                child: _RouteMarker(color: Colors.green, label: 'S'),
              ),
              if (gpsLatLng.length > 1)
                Marker(
                  point: gpsLatLng.last,
                  width: 24,
                  height: 24,
                  child: _RouteMarker(color: Colors.red, label: 'E'),
                ),
            ],
          )
        : null;

    // 体調ログを before / after で仕分け
    final beforeLog = _conditionLogs
        .where((l) => l.timing == 'before')
        .firstOrNull;
    final afterLog = _conditionLogs
        .where((l) => l.timing == 'after')
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---- GPS 軌跡マップ ----
            SizedBox(
              height: 220,
              child: gpsLatLng.length >= 2
                  ? AppMap(
                      initialCenter: trackCenter,
                      initialZoom: zoom,
                      showCurrentLocation: false,
                      centerOnLocationUpdate: false,
                      layers: [?trackLayer, ?markerLayer],
                    )
                  : ColoredBox(
                      color: colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.gps_off_rounded, size: 36),
                            SizedBox(height: 8),
                            Text('GPS 軌跡なし'),
                          ],
                        ),
                      ),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- 達成バッジ ----
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: session.isGoalAchieved
                              ? colorScheme.primaryContainer
                              : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          session.isGoalAchieved
                              ? '🎉 目標達成！($achieveRatePct%)'
                              : '未達成 ($achieveRatePct%)',
                          style: textTheme.labelMedium?.copyWith(
                            color: session.isGoalAchieved
                                ? colorScheme.primary
                                : Colors.orange.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ---- 走行統計 ----
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 2.4,
                    children: [
                      _StatCard(
                        icon: Icons.straighten_rounded,
                        label: '距離',
                        value: _fmtDist(session.actualDistance),
                      ),
                      _StatCard(
                        icon: Icons.schedule_rounded,
                        label: '時間',
                        value: _fmtElapsed(session.durationSeconds),
                      ),
                      _StatCard(
                        icon: Icons.speed_rounded,
                        label: 'ペース',
                        value: _fmtPace(session.avgPaceSecsPerKm),
                      ),
                      _StatCard(
                        icon: Icons.local_fire_department_rounded,
                        label: 'カロリー',
                        value: session.estimatedCalories != null
                            ? '${session.estimatedCalories} kcal'
                            : '--',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ---- 体調ログ ----
                  if (beforeLog != null || afterLog != null) ...[
                    Text(
                      '体調記録',
                      style: textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (beforeLog != null)
                      _ConditionLogCard(
                        timing: '走行前',
                        log: beforeLog,
                        painAreas: _painAreasByLog[beforeLog.id] ?? [],
                        painEmoji: _painEmoji(beforeLog.painScore),
                      ),
                    if (afterLog != null) ...[
                      if (beforeLog != null) const SizedBox(height: 8),
                      _ConditionLogCard(
                        timing: '走行後',
                        log: afterLog,
                        painAreas: _painAreasByLog[afterLog.id] ?? [],
                        painEmoji: _painEmoji(afterLog.painScore),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 走行統計カード
// ---------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  const _StatCard({
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    )),
                Text(value,
                    style: textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 体調ログカード
// ---------------------------------------------------------------------------

class _ConditionLogCard extends StatelessWidget {
  const _ConditionLogCard({
    required this.timing,
    required this.log,
    required this.painAreas,
    required this.painEmoji,
  });

  final String timing;
  final ConditionLog log;
  final List<PainArea> painAreas;
  final String painEmoji;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final partLabels = painAreas
        .map((a) => _bodyPartLabels[a.bodyPart] ?? a.bodyPart)
        .toList()
      ..sort();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // タイミングラベル
          Text(
            timing,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // 痛みスコア
          Row(
            children: [
              Text(painEmoji,
                  style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                '痛みスコア: ${log.painScore} / 10',
                style: textTheme.bodyMedium,
              ),
            ],
          ),

          // 痛み部位
          if (partLabels.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: partLabels
                  .map(
                    (label) => Chip(
                      label: Text(label,
                          style: textTheme.labelSmall),
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          ],

          // メモ
          if (log.memo != null && log.memo!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              log.memo!,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ルートマーカー（S / E）
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
