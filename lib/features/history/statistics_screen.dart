import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../database/database.dart';
import '../../shared/repositories/statistics_repository.dart';
import '../../shared/repositories/user_profile_repository.dart';
import '../../shared/widgets/app_card.dart';

// ---------------------------------------------------------------------------
// Riverpod プロバイダ
// ---------------------------------------------------------------------------

final _statsProfileProvider = FutureProvider<UserProfile?>((ref) {
  return ref.watch(userProfileRepositoryProvider).getProfile();
});

final _statsSummaryProvider = FutureProvider<StatsSummary?>((ref) async {
  final profile = await ref.watch(_statsProfileProvider.future);
  if (profile == null) return null;
  return ref.read(statisticsRepositoryProvider).getStatsSummary(profile.id);
});

/// 週間(true) / 月間(false) トグル
final _isWeeklyProvider = StateProvider<bool>((ref) => true);

final _distanceDataProvider =
    FutureProvider<List<DistancePoint>>((ref) async {
  final profile = await ref.watch(_statsProfileProvider.future);
  if (profile == null) return [];
  final isWeekly = ref.watch(_isWeeklyProvider);
  final repo = ref.read(statisticsRepositoryProvider);
  return isWeekly
      ? repo.getWeeklyDistances(profile.id)
      : repo.getMonthlyDistances(profile.id);
});

final _paceDataProvider = FutureProvider<List<PacePoint>>((ref) async {
  final profile = await ref.watch(_statsProfileProvider.future);
  if (profile == null) return [];
  return ref
      .read(statisticsRepositoryProvider)
      .getRecentPaceHistory(profile.id);
});

final _painDataProvider = FutureProvider<List<PainPoint>>((ref) async {
  final profile = await ref.watch(_statsProfileProvider.future);
  if (profile == null) return [];
  return ref
      .read(statisticsRepositoryProvider)
      .getPainScoreHistory(profile.id);
});

// ---------------------------------------------------------------------------
// S42: 統計サマリ画面
// ---------------------------------------------------------------------------

/// T-6.1.4: 統計サマリ画面
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('統計'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            _SummarySection(),
            SizedBox(height: 20),
            _DistanceChartSection(),
            SizedBox(height: 20),
            _PaceChartSection(),
            SizedBox(height: 20),
            _PainChartSection(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// T-6.1.4: サマリカード（2×2 グリッド）
// ---------------------------------------------------------------------------

class _SummarySection extends ConsumerWidget {
  const _SummarySection();

  String _fmtPace(int sec) {
    if (sec <= 0) return '–';
    return "${sec ~/ 60}'${(sec % 60).toString().padLeft(2, '0')}\"";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(_statsSummaryProvider).when(
          data: (s) {
            final km = (s?.totalDistanceM ?? 0) / 1000;
            final kmStr = km >= 1
                ? '${km.toStringAsFixed(1)} km'
                : '${(km * 1000).round()} m';
            final count = s?.runCount ?? 0;
            final rate = count == 0
                ? '–'
                : '${((s?.achieveRate ?? 0) * 100).round()}%';
            final pace = _fmtPace(s?.avgPaceSecPerKm ?? 0);

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.straighten_rounded,
                        label: '累計距離',
                        value: kmStr,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.directions_walk_rounded,
                        label: '走行回数',
                        value: '$count 回',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.emoji_events_rounded,
                        label: '達成率',
                        value: rate,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.speed_rounded,
                        label: '平均ペース',
                        value: pace,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, _) => const SizedBox.shrink(),
        );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: cs.primary, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: tt.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold, color: cs.onSurface),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// T-6.1.1: 距離推移グラフ（棒グラフ）
// ---------------------------------------------------------------------------

class _DistanceChartSection extends ConsumerWidget {
  const _DistanceChartSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWeekly = ref.watch(_isWeeklyProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                Icon(Icons.bar_chart_rounded,
                    color: cs.primary, size: 18),
                const SizedBox(width: 6),
                Text('距離推移', style: tt.labelLarge),
                const Spacer(),
                _PeriodToggle(
                  isWeekly: isWeekly,
                  onChanged: (v) =>
                      ref.read(_isWeeklyProvider.notifier).state = v,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: ref.watch(_distanceDataProvider).when(
                  data: (data) =>
                      _DistanceBarChart(data: data, isWeekly: isWeekly),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => const SizedBox.shrink(),
                ),
          ),
        ],
      ),
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  const _PeriodToggle({
    required this.isWeekly,
    required this.onChanged,
  });

  final bool isWeekly;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    Widget chip(String label, bool value) {
      final selected = isWeekly == value;
      return GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? cs.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  selected ? cs.primary : cs.outlineVariant,
            ),
          ),
          child: Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: selected ? cs.onPrimary : cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        chip('週間', true),
        const SizedBox(width: 6),
        chip('月間', false),
      ],
    );
  }
}

class _DistanceBarChart extends StatelessWidget {
  const _DistanceBarChart({
    required this.data,
    required this.isWeekly,
  });

  final List<DistancePoint> data;
  final bool isWeekly;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final maxKm = data.isEmpty
        ? 0.0
        : data
            .map((d) => d.distanceM / 1000)
            .reduce((a, b) => a > b ? a : b);

    if (maxKm == 0) {
      return _empty(context);
    }

    final barGroups = data.asMap().entries.map((e) {
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: e.value.distanceM / 1000,
            color: cs.primary,
            width: isWeekly ? 16.0 : 26.0,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    final yMax = (maxKm * 1.3).clamp(1.0, double.infinity);
    final yInterval = yMax > 5 ? 2.0 : 1.0;

    return BarChart(
      BarChartData(
        maxY: yMax,
        barGroups: barGroups,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yInterval,
          getDrawingHorizontalLine: (_) => FlLine(
            color: cs.outlineVariant.withValues(alpha: 0.5),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) =>
                cs.primary.withValues(alpha: 0.85),
            getTooltipItem: (_, _, rod, _) {
              final km = rod.toY;
              final label = km >= 1
                  ? '${km.toStringAsFixed(1)} km'
                  : '${(km * 1000).round()} m';
              return BarTooltipItem(
                label,
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: yInterval,
              getTitlesWidget: (v, _) => Text(
                '${v.toStringAsFixed(0)}k',
                style: TextStyle(
                    fontSize: 10, color: cs.onSurfaceVariant),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (idx < 0 || idx >= data.length) {
                  return const SizedBox.shrink();
                }
                final label = isWeekly
                    ? DateFormat('M/d').format(data[idx].date)
                    : DateFormat('M月').format(data[idx].date);
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    label,
                    style: TextStyle(
                        fontSize: 9, color: cs.onSurfaceVariant),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _empty(BuildContext context) => Center(
        child: Text(
          '走行データがありません',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color:
                    Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
}

// ---------------------------------------------------------------------------
// T-6.1.3: ペース推移グラフ（折れ線）
// ---------------------------------------------------------------------------

class _PaceChartSection extends ConsumerWidget {
  const _PaceChartSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.speed_rounded, color: cs.secondary, size: 18),
              const SizedBox(width: 6),
              Text('ペース推移', style: tt.labelLarge),
              const SizedBox(width: 6),
              Text(
                '直近12回',
                style: tt.labelSmall
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: ref.watch(_paceDataProvider).when(
                  data: (data) => _PaceLineChart(data: data),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => const SizedBox.shrink(),
                ),
          ),
        ],
      ),
    );
  }
}

class _PaceLineChart extends StatelessWidget {
  const _PaceLineChart({required this.data});

  final List<PacePoint> data;

  static String _fmtPace(double sec) {
    final s = sec.round();
    return "${s ~/ 60}'${(s % 60).toString().padLeft(2, '0')}\"";
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (data.isEmpty) return _empty(context);

    final spots = data.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.paceSecPerKm))
        .toList();

    final paces = data.map((d) => d.paceSecPerKm);
    final minP = paces.reduce((a, b) => a < b ? a : b);
    final maxP = paces.reduce((a, b) => a > b ? a : b);
    final margin = ((maxP - minP) * 0.25).clamp(30.0, 120.0);

    return LineChart(
      LineChartData(
        minY: (minP - margin).clamp(0, double.infinity),
        maxY: maxP + margin,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: cs.secondary,
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                radius: 4,
                color: cs.secondary,
                strokeWidth: 1.5,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: cs.secondary.withValues(alpha: 0.10),
            ),
          ),
        ],
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: cs.outlineVariant.withValues(alpha: 0.5),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.black87,
            getTooltipItems: (spots) => spots.map((s) {
              final idx = s.x.toInt();
              final date = data[idx].date;
              return LineTooltipItem(
                '${DateFormat('M/d').format(date)}\n'
                '${_fmtPace(s.y)}',
                const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList(),
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (v, meta) {
                if (v <= 0 || v == meta.min || v == meta.max) {
                  return const SizedBox.shrink();
                }
                return Text(
                  _fmtPace(v),
                  style: TextStyle(
                      fontSize: 9, color: cs.onSurfaceVariant),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: data.length > 6 ? 2 : 1,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (idx < 0 || idx >= data.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DateFormat('M/d').format(data[idx].date),
                    style: TextStyle(
                        fontSize: 9, color: cs.onSurfaceVariant),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _empty(BuildContext context) => Center(
        child: Text(
          '走行データがありません',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color:
                    Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
}

// ---------------------------------------------------------------------------
// T-6.1.2: 痛みスコア推移グラフ（折れ線）
// ---------------------------------------------------------------------------

class _PainChartSection extends ConsumerWidget {
  const _PainChartSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.sentiment_very_dissatisfied_rounded,
                color: Colors.orange,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text('痛みスコア推移', style: tt.labelLarge),
              const SizedBox(width: 6),
              Text(
                '走行後・直近12回',
                style: tt.labelSmall
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: ref.watch(_painDataProvider).when(
                  data: (data) => _PainLineChart(data: data),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => const SizedBox.shrink(),
                ),
          ),
        ],
      ),
    );
  }
}

class _PainLineChart extends StatelessWidget {
  const _PainLineChart({required this.data});

  final List<PainPoint> data;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (data.isEmpty) {
      return Center(
        child: Text(
          '体調ログがありません',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
        ),
      );
    }

    final spots = data.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.avgPainScore))
        .toList();

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 10,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: Colors.orange,
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                radius: 4,
                color: Colors.orange,
                strokeWidth: 1.5,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.orange.withValues(alpha: 0.10),
            ),
          ),
        ],
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2,
          getDrawingHorizontalLine: (_) => FlLine(
            color: cs.outlineVariant.withValues(alpha: 0.5),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.black87,
            getTooltipItems: (spots) => spots.map((s) {
              final idx = s.x.toInt();
              final date = data[idx].date;
              return LineTooltipItem(
                '${DateFormat('M/d').format(date)}\n'
                'スコア ${s.y.round()}',
                const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList(),
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: 2,
              getTitlesWidget: (v, meta) {
                if (v == meta.min || v == meta.max) {
                  return const SizedBox.shrink();
                }
                return Text(
                  v.toInt().toString(),
                  style: TextStyle(
                      fontSize: 10, color: cs.onSurfaceVariant),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: data.length > 6 ? 2 : 1,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (idx < 0 || idx >= data.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DateFormat('M/d').format(data[idx].date),
                    style: TextStyle(
                        fontSize: 9, color: cs.onSurfaceVariant),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
