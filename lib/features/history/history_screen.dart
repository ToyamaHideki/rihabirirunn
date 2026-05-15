import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../database/database.dart';
import '../../shared/repositories/condition_log_repository.dart';
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
/// T-3.3.3: 日付タップでセッション一覧 BottomSheet（痛みスコア表示付き）
/// T-3.3.5: 月切り替え（← → ボタン + 左右スワイプ）
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  // 現在表示中の月（day=1 で統一）
  DateTime _currentMonth = DateUtils.dateOnly(DateTime.now()).copyWith(day: 1);
  List<RunSession> _monthSessions = [];
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

    final sessions = await ref
        .read(historyRepositoryProvider)
        .getSessionsForMonth(profile.id, _currentMonth.year, _currentMonth.month);

    if (!mounted) return;
    setState(() {
      _userId = profile.id;
      _monthSessions = sessions;
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

                const Divider(height: 16),

                // ---- T-3.3.2: 月間サマリ ----
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _MonthlySummarySection(summary: summary),
                ),
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
              fontSize: 11,
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
      // 1.1 にすることでセルを正方形に近くし縦方向を圧縮
      childAspectRatio: 1.1,
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
        width: 5,
        height: 5,
        margin: const EdgeInsets.only(top: 2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: result!.hasAchieved ? colorScheme.primary : Colors.orange,
        ),
      );
    } else {
      dotWidget = const SizedBox(width: 5, height: 7);
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
        borderRadius: BorderRadius.circular(6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isToday ? colorScheme.primary : null,
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 12,
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
// T-3.3.2: 月間サマリセクション（横1行コンパクトレイアウト）
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
    return "$min'$sec\"";
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '今月のサマリ',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: _CompactStat(
                  label: '実施日数',
                  value: '${summary.runDays}/${summary.calendarDays}日',
                ),
              ),
              _Divider(),
              Expanded(
                child: _CompactStat(
                  label: '累計距離',
                  value: _fmtDist(summary.totalDistanceM),
                ),
              ),
              _Divider(),
              Expanded(
                child: _CompactStat(
                  label: '最長距離',
                  value: _fmtDist(summary.maxDistanceM),
                ),
              ),
              _Divider(),
              Expanded(
                child: _CompactStat(
                  label: '平均ペース',
                  value: _fmtPace(summary.avgPaceSecPerKm),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompactStat extends StatelessWidget {
  const _CompactStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: textTheme.labelSmall
              ?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 10),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
    );
  }
}

// ---------------------------------------------------------------------------
// T-3.3.3: 日付BottomSheet（体調ログ付き）
// ---------------------------------------------------------------------------

class _DaySessionSheet extends ConsumerStatefulWidget {
  const _DaySessionSheet({
    required this.date,
    required this.sessions,
    required this.onSessionTap,
  });

  final DateTime date;
  final List<RunSession> sessions;
  final ValueChanged<String> onSessionTap;

  @override
  ConsumerState<_DaySessionSheet> createState() => _DaySessionSheetState();
}

class _DaySessionSheetState extends ConsumerState<_DaySessionSheet> {
  // sessionId → (painBefore, painAfter, memo)
  final Map<String, ({int? before, int? after, String? memo})> _painData = {};

  @override
  void initState() {
    super.initState();
    _loadConditionLogs();
  }

  Future<void> _loadConditionLogs() async {
    final condRepo = ref.read(conditionLogRepositoryProvider);
    final newData = <String, ({int? before, int? after, String? memo})>{};
    for (final s in widget.sessions) {
      final logs = await condRepo.getConditionLogsForSession(s.id);
      final before = logs.where((l) => l.timing == 'before').firstOrNull;
      final after = logs.where((l) => l.timing == 'after').firstOrNull;
      newData[s.id] = (
        before: before?.painScore,
        after: after?.painScore,
        // 走行後メモを優先、なければ走行前メモ
        memo: (after?.memo?.isNotEmpty ?? false)
            ? after!.memo
            : (before?.memo?.isNotEmpty ?? false)
                ? before!.memo
                : null,
      );
    }
    if (mounted) setState(() => _painData.addAll(newData));
  }

  @override
  Widget build(BuildContext context) {
    final label = DateFormat('M月d日(E)', 'ja').format(widget.date);
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
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '詳細をタップで確認',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              controller: controller,
              itemCount: widget.sessions.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, indent: 16),
              itemBuilder: (ctx, i) {
                final s = widget.sessions[i];
                final pain = _painData[s.id];
                return _DaySessionTile(
                  session: s,
                  painBefore: pain?.before,
                  painAfter: pain?.after,
                  memo: pain?.memo,
                  onTap: () => widget.onSessionTap(s.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// BottomSheet内セッションタイル（痛みスコア・メモ表示付き）
// ---------------------------------------------------------------------------

class _DaySessionTile extends StatelessWidget {
  const _DaySessionTile({
    required this.session,
    required this.painBefore,
    required this.painAfter,
    required this.memo,
    required this.onTap,
  });

  final RunSession session;
  final int? painBefore;
  final int? painAfter;
  final String? memo;
  final VoidCallback onTap;

  String _fmtDist(double m) {
    if (m >= 1000) return '${(m / 1000).toStringAsFixed(2)} km';
    return '${m.round()} m';
  }

  String _fmtElapsed(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return "$m'${s.toString().padLeft(2, '0')}\"";
  }

  Color _painColor(int? score, ColorScheme cs) {
    if (score == null) return cs.onSurfaceVariant;
    if (score <= 2) return cs.primary;
    if (score <= 5) return Colors.orange.shade700;
    return cs.error;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // 痛みスコア表示テキスト
    String? painText;
    if (painBefore != null || painAfter != null) {
      final parts = <String>[];
      if (painBefore != null) parts.add('前 $painBefore');
      if (painAfter != null) parts.add('後 $painAfter');
      painText = '痛み: ${parts.join(' → ')}';
    }

    final hasExtraInfo = painText != null || (memo?.isNotEmpty ?? false);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
      title: Row(
        children: [
          Text(
            _fmtDist(session.actualDistance),
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Text(
            _fmtElapsed(session.durationSeconds),
            style: textTheme.bodySmall
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
      subtitle: hasExtraInfo
          ? Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (painText != null)
                    Row(
                      children: [
                        Icon(
                          Icons.favorite_rounded,
                          size: 12,
                          color: _painColor(painAfter, colorScheme),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          painText,
                          style: textTheme.bodySmall?.copyWith(
                            color: _painColor(painAfter, colorScheme),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  if (memo != null && memo!.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.notes_rounded,
                          size: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            memo!,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: colorScheme.onSurfaceVariant,
        size: 20,
      ),
    );
  }
}
