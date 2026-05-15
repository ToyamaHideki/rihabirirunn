import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database.dart';

// ---------------------------------------------------------------------------
// T-6.1: 統計データ DTO
// ---------------------------------------------------------------------------

/// 全期間サマリ
class StatsSummary {
  const StatsSummary({
    required this.totalDistanceM,
    required this.runCount,
    required this.achieveRate,
    required this.avgPaceSecPerKm,
  });

  final double totalDistanceM;
  final int runCount;
  final double achieveRate; // 0.0–1.0
  final int avgPaceSecPerKm;
}

/// 距離推移の1点（週始め or 月始め）
class DistancePoint {
  const DistancePoint({required this.date, required this.distanceM});

  final DateTime date;
  final double distanceM;
}

/// ペース推移の1点
class PacePoint {
  const PacePoint({required this.date, required this.paceSecPerKm});

  final DateTime date;
  final double paceSecPerKm; // nullable カラムの都合で double
}

/// 痛みスコア推移の1点
class PainPoint {
  const PainPoint({required this.date, required this.avgPainScore});

  final DateTime date;
  final double avgPainScore;
}

// ---------------------------------------------------------------------------
// T-6.1: 統計クエリリポジトリ
// ---------------------------------------------------------------------------

class StatisticsRepository {
  StatisticsRepository(this._db);

  final AppDatabase _db;

  // ---- サマリ (T-6.1.4) ----

  Future<StatsSummary> getStatsSummary(String userId) async {
    final sessions = await (_db.select(_db.runSessions)
          ..where(
            (t) => t.userId.equals(userId) & t.status.equals('completed'),
          ))
        .get();

    if (sessions.isEmpty) {
      return const StatsSummary(
        totalDistanceM: 0,
        runCount: 0,
        achieveRate: 0,
        avgPaceSecPerKm: 0,
      );
    }

    final totalDist =
        sessions.fold<double>(0, (s, r) => s + r.actualDistance);
    final achievedCount = sessions.where((s) => s.isGoalAchieved).length;
    final paceList =
        sessions.where((s) => (s.avgPaceSecsPerKm ?? 0) > 0).toList();
    final avgPace = paceList.isEmpty
        ? 0
        : (paceList.fold<double>(
                  0.0, (s, r) => s + (r.avgPaceSecsPerKm ?? 0)) /
                paceList.length)
            .round();

    return StatsSummary(
      totalDistanceM: totalDist,
      runCount: sessions.length,
      achieveRate: achievedCount / sessions.length,
      avgPaceSecPerKm: avgPace,
    );
  }

  // ---- 週別距離 (T-6.1.1) ----

  /// 直近 [weeks] 週の月曜日始まり週別距離を返す
  Future<List<DistancePoint>> getWeeklyDistances(
    String userId, {
    int weeks = 8,
  }) async {
    final result = <DistancePoint>[];
    final thisWeekStart = _mondayOf(DateTime.now());

    for (int i = weeks - 1; i >= 0; i--) {
      final weekStart = thisWeekStart.subtract(Duration(days: i * 7));
      final weekEnd = weekStart.add(const Duration(days: 7));

      final sessions = await (_db.select(_db.runSessions)
            ..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.status.equals('completed') &
                  t.startedAt.isBiggerOrEqualValue(weekStart) &
                  t.startedAt.isSmallerThanValue(weekEnd),
            ))
          .get();

      final dist =
          sessions.fold<double>(0, (s, r) => s + r.actualDistance);
      result.add(DistancePoint(date: weekStart, distanceM: dist));
    }
    return result;
  }

  // ---- 月別距離 (T-6.1.1) ----

  /// 直近 [months] ヶ月の月初別距離を返す
  Future<List<DistancePoint>> getMonthlyDistances(
    String userId, {
    int months = 6,
  }) async {
    final result = <DistancePoint>[];
    final now = DateTime.now();

    for (int i = months - 1; i >= 0; i--) {
      final monthStart = _monthStart(now.year, now.month, -i);
      final monthEnd = _monthStart(now.year, now.month, -i + 1);

      final sessions = await (_db.select(_db.runSessions)
            ..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.status.equals('completed') &
                  t.startedAt.isBiggerOrEqualValue(monthStart) &
                  t.startedAt.isSmallerThanValue(monthEnd),
            ))
          .get();

      final dist =
          sessions.fold<double>(0, (s, r) => s + r.actualDistance);
      result.add(DistancePoint(date: monthStart, distanceM: dist));
    }
    return result;
  }

  // ---- ペース推移 (T-6.1.3) ----

  /// 直近 [count] セッションのペース履歴（古い順）
  Future<List<PacePoint>> getRecentPaceHistory(
    String userId, {
    int count = 12,
  }) async {
    final sessions = await (_db.select(_db.runSessions)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.status.equals('completed') &
                t.avgPaceSecsPerKm.isBiggerThanValue(0.0),
          )
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.startedAt,
                  mode: OrderingMode.desc,
                ),
          ])
          ..limit(count))
        .get();

    // 降順取得 → reversed で古い順に
    return sessions.reversed
        .map((s) => PacePoint(
              date: s.startedAt,
              paceSecPerKm: s.avgPaceSecsPerKm ?? 0.0,
            ))
        .toList();
  }

  // ---- 痛みスコア推移 (T-6.1.2) ----

  /// 直近 [count] セッションの走行後 痛みスコア履歴（古い順）
  Future<List<PainPoint>> getPainScoreHistory(
    String userId, {
    int count = 12,
  }) async {
    final sessions = await (_db.select(_db.runSessions)
          ..where(
            (t) =>
                t.userId.equals(userId) & t.status.equals('completed'),
          )
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.startedAt,
                  mode: OrderingMode.desc,
                ),
          ])
          ..limit(count))
        .get();

    final result = <PainPoint>[];
    for (final s in sessions.reversed) {
      final logs = await (_db.select(_db.conditionLogs)
            ..where(
              (t) =>
                  t.sessionId.equals(s.id) & t.timing.equals('after'),
            ))
          .get();
      if (logs.isNotEmpty) {
        result.add(PainPoint(
          date: s.startedAt,
          avgPainScore: logs.first.painScore.toDouble(),
        ));
      }
    }
    return result;
  }

  // ---- ヘルパー ----

  /// dt を含む週の月曜日 0:00 を返す
  DateTime _mondayOf(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day - (dt.weekday - 1));

  /// year/month から offset ヶ月先の月初を返す（負 = 過去）
  DateTime _monthStart(int year, int month, int offset) {
    int m = month + offset;
    int y = year;
    while (m <= 0) {
      m += 12;
      y--;
    }
    while (m > 12) {
      m -= 12;
      y++;
    }
    return DateTime(y, m);
  }
}

// ---------------------------------------------------------------------------
// Riverpod プロバイダ
// ---------------------------------------------------------------------------

final statisticsRepositoryProvider = Provider<StatisticsRepository>((ref) {
  return StatisticsRepository(ref.watch(appDatabaseProvider));
});
