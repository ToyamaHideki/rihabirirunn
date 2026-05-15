import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database.dart';

/// T-3.3: 履歴データの取得を担当するリポジトリ
///
/// T-3.3.1〜3.3.6 で使用するクエリをまとめる
class HistoryRepository {
  HistoryRepository(this._db);

  final AppDatabase _db;

  // ---------------------------------------------------------------------------
  // 月単位のセッション取得（T-3.3.1 カレンダー / T-3.3.2 月間サマリ）
  // ---------------------------------------------------------------------------

  /// 指定月のセッションを開始時刻昇順で取得する
  Future<List<RunSession>> getSessionsForMonth(
    String userId,
    int year,
    int month,
  ) {
    // 月初〜翌月初で範囲指定（Dart の DateTime は月/年オーバーフローを自動処理）
    final startOfMonth = DateTime(year, month);
    final startOfNextMonth = DateTime(year, month + 1);

    return (
      _db.select(_db.runSessions)
        ..where(
          (t) =>
              t.userId.equals(userId) &
              t.startedAt.isBiggerOrEqualValue(startOfMonth) &
              t.startedAt.isSmallerThanValue(startOfNextMonth),
        )
        ..orderBy([(t) => OrderingTerm(expression: t.startedAt)])
    ).get();
  }

  // ---------------------------------------------------------------------------
  // 全セッション降順（T-3.3.6 一覧リスト）
  // ---------------------------------------------------------------------------

  /// 全セッションを開始時刻降順で取得する
  Future<List<RunSession>> getAllSessionsDesc(String userId) {
    return (
      _db.select(_db.runSessions)
        ..where((t) => t.userId.equals(userId))
        ..orderBy([
          (t) => OrderingTerm(
                expression: t.startedAt,
                mode: OrderingMode.desc,
              ),
        ])
    ).get();
  }
}

// ---- Riverpod プロバイダ ----

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository(ref.watch(appDatabaseProvider));
});
