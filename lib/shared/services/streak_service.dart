import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database.dart';

// ---------------------------------------------------------------------------
// ストリークデータ DTO
// ---------------------------------------------------------------------------

/// T-3.4: ストリーク計算の結果
class StreakData {
  const StreakData({
    required this.streak,
    required this.weeklyStatus,
    required this.totalDistanceM,
  });

  /// 連続走行日数（仕様6.1: 今日から遡って連続で走行した日数）
  final int streak;

  /// 直近7日間（今日を含む）の達成状況
  ///   true  = その日に走行かつ目標達成
  ///   false = その日に走行したが未達成
  ///   null  = その日に走行なし
  /// key は DateUtils.dateOnly() で正規化した DateTime
  final Map<DateTime, bool?> weeklyStatus;

  /// 全セッションの累計距離(m)
  final double totalDistanceM;
}

// ---------------------------------------------------------------------------
// T-3.4.1: ストリーク計算サービス
// ---------------------------------------------------------------------------

/// T-3.4.1: 仕様6.1に基づくストリーク計算
///
/// streak = 0
/// today = 今日の日付
/// 日付 = today から過去へ1日ずつループ
///   その日に completed セッションがあれば streak++
///   なければ break
/// return streak
class StreakService {
  StreakService(this._db);

  final AppDatabase _db;

  /// ストリーク・週次状況・累計距離を一度のDBクエリで取得する
  Future<StreakData> getStreakData(String userId) async {
    // 全セッションを取得（1回のクエリで3指標をまとめて計算）
    final allSessions = await (
      _db.select(_db.runSessions)
        ..where((t) => t.userId.equals(userId))
        ..orderBy([
          (t) => OrderingTerm(
                expression: t.startedAt,
                mode: OrderingMode.desc,
              ),
        ])
    ).get();

    return StreakData(
      streak: _computeStreak(allSessions),
      weeklyStatus: _computeWeekly(allSessions),
      totalDistanceM: allSessions.fold(0.0, (sum, s) => sum + s.actualDistance),
    );
  }

  // ---------------------------------------------------------------------------
  // 内部計算ロジック
  // ---------------------------------------------------------------------------

  /// T-3.4.1: ストリーク計算（仕様6.1）
  ///
  /// セッションが存在する日付の集合を作り、今日から遡って連続日数を数える。
  int _computeStreak(List<RunSession> sessions) {
    if (sessions.isEmpty) return 0;

    // 走行した日付の集合（時刻なし）
    final runDays = sessions
        .map((s) => DateUtils.dateOnly(s.startedAt))
        .toSet();

    int streak = 0;
    var current = DateUtils.dateOnly(DateTime.now());
    while (runDays.contains(current)) {
      streak++;
      current = current.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// T-3.4.3: 直近7日間の達成状況を計算する
  ///
  /// 今日を含む過去7日を古い順（左）→新しい順（右）で返す。
  Map<DateTime, bool?> _computeWeekly(List<RunSession> sessions) {
    // 日付 → セッション一覧 のマップを構築
    final Map<DateTime, List<RunSession>> byDay = {};
    for (final s in sessions) {
      final day = DateUtils.dateOnly(s.startedAt);
      (byDay[day] ??= []).add(s);
    }

    final today = DateUtils.dateOnly(DateTime.now());
    final result = <DateTime, bool?>{};

    // 6日前〜今日の7日分を構築
    for (int i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final daySessions = byDay[day];
      if (daySessions == null || daySessions.isEmpty) {
        result[day] = null;
      } else {
        result[day] = daySessions.any((s) => s.isGoalAchieved);
      }
    }
    return result;
  }
}

// ---- Riverpod プロバイダ ----

final streakServiceProvider = Provider<StreakService>((ref) {
  return StreakService(ref.watch(appDatabaseProvider));
});
