import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../database/database.dart';
import '../../shared/repositories/history_repository.dart';
import '../../shared/repositories/user_profile_repository.dart';
import '../../shared/router/app_routes.dart';

// ---------------------------------------------------------------------------
// 内部データクラス
// ---------------------------------------------------------------------------

class _DayResult {
  const _DayResult({required this.sessions, required this.hasAchieved});
  final List<RunSession> sessions;
  final bool hasAchieved;
}

class _MonthlySummary {
  const _MonthlySummary({
    required this.runDays,
    required this.calendarDays,
    required this.totalDistanceM,
    required this.maxDistanceM,
    required this.avgPaceSecPerKm,
    required this.achievedCount,
  });
  final int runDays;
  final int calendarDays;
  final double totalDistanceM;
  final double maxDistanceM;
  final double? avgPaceSecPerKm;
  final int achievedCount;
}

// ---------------------------------------------------------------------------
// S40: 履歴カレンダー画面
// ---------------------------------------------------------------------------

/// S40: 履歴カレンダー
///
/// T-3.3.1: カレンダーUI（達成●/未達成○ ドット）
/// T-3.3.2: 月間サマリ（実施日数・累計距離・最長距離・平均ペース）
/// T-3.3.3: 日付タップでセッション一覧 BottomSheet
/// T-3.3.5: 月切り替え（← → ボタン + 左右スワイプ）
/// T-3.3.6: 全走行履歴リスト（降順ソート）
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  // 現在表示中の月（day=1 で統一）
  DateTime _currentMonth = DateUtils.dateOnly(DateTime.now()).copyWith(day: 1);
  List<RunSession> _monthSessions = [];
  List<RunSession> _allSessions = [];
  String? _userId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  // ---- データ読み込み ----

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    final profile =
        await ref.read(userProfileRepositoryProvider).getProfile();
    if (!mounted) return;
    if (profile == null) {
      setState(() => _loading = false);
      return;
    }

    final repo = ref.read(historyRepositoryProvider);
    final results = await Future.wait([
      repo.getSessionsForMonth(
          profile.id, _currentMonth.year, _currentMonth.month),
      repo.getAllSessionsDesc(profile.id),
    ]);

    if (!mounted) return;
    setState(() {
      _userId = profile.id;
      _monthSessions = results[0];
      _allSessions = results[1];
      _loading = false;
    });
  }

  Future<void> _loadMonth(DateTime month) async {
    final userId = _userId;
    if (userId == null) return;
    final sessions = await ref
        .read(historyRepositoryProvider)
        .getSessionsForMonth(userId, month.year, month.month);
    if (!mounted) return;
    setState(() {
      _currentMonth = month;
      _monthSessions = sessions;
    });
  }

  void _prevMonth() {
    _loadMonth(
      DateTime(_currentMonth.year, _currentMonth.month - 1),
    );
  }

  void _nextMonth() {
    final now = DateUtils.dateOnly(DateTime.now()).copyWith(day: 1);
    if (_currentMonth.isBefore(now)) {
      _loadMonth(
        DateTime(_currentMonth.year, _currentMonth.month + 1),
      );
    }
  }

  // ---- カレンダーデータ構築 ----

  Map<DateTime, _DayResult> _buildCalendarData() {
    final Map<DateTime, List<RunSession>> byDay = {};
    for (final s in _monthSessions) {
      final date = DateUtils.dateOnly(s.startedAt);
      (byDay[date] ??= []).add(s);
    }
    return byDay.map((date, sessions) {
      final hasAchieved = sessions.any((s) => s.isGoalAchieved);
      return MapEntry(date, _DayResult(sessions: sessions, hasAchieved: hasAchieved));
    });
  }

  // ---- 月間サマリ計算 ----

  _MonthlySummary _computeSummary() {
    final calDays = DateUtils.getDaysInMonth(
        _currentMonth.year, _currentMonth.month);
    if (_monthSessions.isEmpty) {
      return _MonthlySummary(
        runDays: 0,
        calendarDays: calDays,
        totalDistanceM: 0,
        maxDistanceM: 0,
        avgPaceSecPerKm: null,
        achievedCount: 0,
      );
    }

    final runDays = _monthSessions
        .map((s) => DateUtils.dateOnly(s.startedAt))
        .toSet()
        .length;
    final totalDist =
        _monthSessions.fold(0.0, (sum, s) => sum + s.actualDistance);
    final maxDist = _monthSessions
        .map((s) => s.actualDistance)
        .reduce(math.max);
    final achievedCount =
        _monthSessions.where((s) => s.isGoalAchieved).length;
    final totalDur =
        _monthSessions.fold(0, (sum, s) => sum + s.durationSeconds);
    final avgPace =
        totalDist > 100 && totalDur > 0 ? totalDur / (totalDist / 1000) : null;

    return _MonthlySummary(
      runDays: runDays,
      calendarDays: calDays,
      totalDistanceM: totalDist,
      maxDistanceM: maxDist,
      avgPaceSecPerKm: avgPace,
      achievedCount: achievedCount,
    );
  }

  // ---- BottomSheet（T-3.3.3） ----

  void _showDaySheet(DateTime date, List<RunSession> sessions) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _DaySessionSheet(
        date: date,
        sessions: sessions,
        onSessionTap: (sessionId) {
          Navigator.of(ctx).pop();
          context.push(AppRoutes.runDetailPath(sessionId));
        },
      ),
    );
  }

  // ---- Build ----

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final calData = _buildCalendarData();
    final summary = _computeSummary();
    final today = DateUtils.dateOnly(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text('履歴')),
      body: GestureDetector(
        // T-3.3.5: 左右スワイプで月切り替え
        onHorizontalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) < -300) _nextMonth();
          if ((details.primaryVelocity ?? 0) > 300) _prevMonth();
        },
        child: RefreshIndicator(
          onRefresh: _loadAll,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- T-3.3.5: 月ナビゲーション ----
                _MonthNavigator(
                  month: _currentMonth,
                  canGoNext: _currentMonth.isBefore(
                    DateUtils.dateOnly(DateTime.now()).copyWith(day: 1),
                  ),
                  onPrev: _prevMonth,
                  onNext: _nextMonth,
                ),

                // ---- T-3.3.1: カレンダーグリッド ----
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _MonthCalendar(
                    year: _currentMonth.year,
                    month: _currentMonth.month,
                    dayData: calData,
                    today: today,
                    onDayTap: (date) {
                      final result = calData[date];
                      if (result != null) {
                        _showDaySheet(date, result.sessions);
                      }
                    },
                  ),
                ),

                const Divider(height: 24),

                // ---- T-3.3.2: 月間サマリ ----
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _MonthlySummarySection(summary: summary),
                ),

                const Divider(height: 24),

                // ---- T-3.3.6: 全走行履歴リスト ----
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    '走行履歴',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (_allSessions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text('走行記録がまだありません'),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _allSessions.length,
                    separatorBuilder: (sepCtx, sepIdx) =>
                        const Divider(height: 1, indent: 16),
                    itemBuilder: (ctx, i) => _SessionListTile(
                      session: _allSessions[i],
                      onTap: () => context
                          .push(AppRoutes.runDetailPath(_allSessions[i].id)),
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// T-3.3.5: 月ナビゲーションヘッダー
// ---------------------------------------------------------------------------

class _MonthNavigator extends StatelessWidget {
  const _MonthNavigator({
    required this.month,
    required this.canGoNext,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime month;
  final bool canGoNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final label = DateFormat('yyyy年M月', 'ja').format(month);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: onPrev,
          ),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right_rounded,
              color: canGoNext ? null : Theme.of(context).disabledColor,
            ),
            onPressed: canGoNext ? onNext : null,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// T-3.3.1: カレンダーグリッド
// ---------------------------------------------------------------------------

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
    required this.year,
    required this.month,
    required this.dayData,
    required this.today,
    required this.onDayTap,
  });

  final int year;
  final int month;
  final Map<DateTime, _DayResult> dayData;
  final DateTime today;
  final ValueChanged<DateTime> onDayTap;

  static const _weekHeaders = ['日', '月', '火', '水', '木', '金', '土'];

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    // Dart weekday: 1=Mon...7=Sun → 日曜始まりのオフセット: Sun=0
    final startOffset = firstDay.weekday % 7;

    final cells = <Widget>[
      // 曜日ヘッダー
      for (final h in _weekHeaders)
        Center(
          child: Text(
            h,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: h == '日' ? Colors.red.shade400 : null,
            ),
          ),
        ),
      // 空白オフセット
      for (int i = 0; i < startOffset; i++) const SizedBox.shrink(),
      // 日付セル
      for (int d = 1; d <= daysInMonth; d++)
        _DayCell(
          day: d,
          date: DateTime(year, month, d),
          result: dayData[DateTime(year, month, d)],
          today: today,
          onTap: () => onDayTap(DateTime(year, month, d)),
        ),
    ];

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.85,
      children: cells,
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.date,
    required this.result,
    required this.today,
    required this.onTap,
  });

  final int day;
  final DateTime date;
  final _DayResult? result;
  final DateTime today;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isToday = DateUtils.isSameDay(date, today);
    final isSunday = date.weekday == DateTime.sunday;

    Color? textColor = isSunday ? Colors.red.shade400 : null;
    if (isToday) textColor = Colors.white;

    Widget dotWidget;
    if (result != null) {
      dotWidget = Container(
        width: 6,
        height: 6,
        margin: const EdgeInsets.only(top: 2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: result!.hasAchieved ? colorScheme.primary : Colors.orange,
        ),
      );
    } else {
      dotWidget = const SizedBox(width: 6, height: 8);
    }

    // T-4.3.3: スクリーンリーダー向けラベル
    String semanticLabel = '${date.month}月${date.day}日';
    if (result != null) {
      semanticLabel +=
          result!.hasAchieved ? ' 目標達成 タップで記録を表示' : ' 走行・未達成 タップで記録を表示';
    }

    return Semantics(
      label: semanticLabel,
      button: result != null,
      child: InkWell(
        onTap: result != null ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isToday ? colorScheme.primary : null,
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 13,
                    color: textColor,
                    fontWeight:
                        isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
            dotWidget,
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// T-3.3.2: 月間サマリセクション
// ---------------------------------------------------------------------------

class _MonthlySummarySection extends StatelessWidget {
  const _MonthlySummarySection({required this.summary});
  final _MonthlySummary summary;

  String _fmtDist(double m) {
    if (m >= 1000) return '${(m / 1000).toStringAsFixed(2)} km';
    return '${m.round()} m';
  }

  String _fmtPace(double? secPerKm) {
    if (secPerKm == null || secPerKm <= 0) return '--';
    final min = (secPerKm ~/ 60).toString().padLeft(2, '0');
    final sec = (secPerKm.round() % 60).toString().padLeft(2, '0');
    return "$min'$sec\"/km";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '今月のサマリ',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 2.4,
          children: [
            _SummaryCard(
              label: '実施日数',
              value: '${summary.runDays} / ${summary.calendarDays} 日',
            ),
            _SummaryCard(
              label: '累計距離',
              value: _fmtDist(summary.totalDistanceM),
            ),
            _SummaryCard(
              label: '最長距離',
              value: _fmtDist(summary.maxDistanceM),
            ),
            _SummaryCard(
              label: '平均ペース',
              value: _fmtPace(summary.avgPaceSecPerKm),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value});
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant)),
          Text(value,
              style: textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// T-3.3.3: 日付BottomSheet
// ---------------------------------------------------------------------------

class _DaySessionSheet extends StatelessWidget {
  const _DaySessionSheet({
    required this.date,
    required this.sessions,
    required this.onSessionTap,
  });

  final DateTime date;
  final List<RunSession> sessions;
  final ValueChanged<String> onSessionTap;

  @override
  Widget build(BuildContext context) {
    final label = DateFormat('M月d日(E)', 'ja').format(date);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      builder: (ctx, controller) => Column(
        children: [
          // ドラッグハンドル
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              controller: controller,
              itemCount: sessions.length,
              separatorBuilder: (sepCtx, sepIdx) =>
                  const Divider(height: 1, indent: 16),
              itemBuilder: (ctx, i) => _SessionListTile(
                session: sessions[i],
                onTap: () => onSessionTap(sessions[i].id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// T-3.3.6: セッションリストタイル（共用）
// ---------------------------------------------------------------------------

class _SessionListTile extends StatelessWidget {
  const _SessionListTile({
    required this.session,
    required this.onTap,
  });

  final RunSession session;
  final VoidCallback onTap;

  String _fmtDist(double m) {
    if (m >= 1000) return '${(m / 1000).toStringAsFixed(2)} km';
    return '${m.round()} m';
  }

  String _fmtDate(DateTime dt) {
    return DateFormat('M/d (E)', 'ja').format(dt);
  }

  String _fmtElapsed(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return "$m'${s.toString().padLeft(2, '0')}\"";
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: session.isGoalAchieved
              ? colorScheme.primaryContainer
              : colorScheme.errorContainer,
        ),
        child: Icon(
          session.isGoalAchieved
              ? Icons.check_rounded
              : Icons.close_rounded,
          color: session.isGoalAchieved
              ? colorScheme.primary
              : colorScheme.error,
          size: 20,
        ),
      ),
      title: Text(
        _fmtDate(session.startedAt),
        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        _fmtDist(session.actualDistance),
        style: textTheme.bodySmall
            ?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
      trailing: Text(
        _fmtElapsed(session.durationSeconds),
        style: textTheme.bodySmall,
      ),
    );
  }
}
