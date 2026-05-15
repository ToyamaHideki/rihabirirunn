import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../database/database.dart';

/// T-3.1.6: ConditionLog + PainArea の保存と取得を担当するリポジトリ
///
/// 走行前(before) / 走行後(after) / 単独(standalone) の3タイミングに対応。
/// PainArea は ConditionLog と同一トランザクションで一括保存する。
class ConditionLogRepository {
  ConditionLogRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  // ---------------------------------------------------------------------------
  // T-3.1.6: 体調ログ保存
  // ---------------------------------------------------------------------------

  /// 体調ログと痛み部位をトランザクション内で一括保存する
  ///
  /// [userId]            ユーザー ID
  /// [sessionId]         走行セッション ID（after / before の場合は nullable）
  /// [timing]            'before' / 'after' / 'standalone'
  /// [painScore]         0（無痛）〜 10（最大痛）
  /// [memo]              自由記述メモ（null or 空文字は保存なし）
  /// [selectedBodyParts] 選択された部位コードのセット
  ///
  /// @return 作成された ConditionLog の ID
  Future<String> saveConditionLog({
    required String userId,
    String? sessionId,
    required String timing,
    required int painScore,
    String? memo,
    required Set<String> selectedBodyParts,
  }) async {
    final logId = _uuid.v4();
    final now = DateTime.now();
    final trimmedMemo =
        (memo == null || memo.trim().isEmpty) ? null : memo.trim();

    await _db.transaction(() async {
      // ---- ConditionLog 保存 ----
      await _db.into(_db.conditionLogs).insert(
            ConditionLogsCompanion.insert(
              id: logId,
              userId: userId,
              sessionId: Value(sessionId),
              timing: timing,
              painScore: Value(painScore),
              memo: Value(trimmedMemo),
              recordedAt: now,
            ),
          );

      // ---- PainArea 一括保存 ----
      if (selectedBodyParts.isNotEmpty) {
        final companions = selectedBodyParts.map((part) {
          return PainAreasCompanion.insert(
            id: _uuid.v4(),
            conditionLogId: logId,
            bodyPart: part,
            side: Value(_sideForPart(part)),
          );
        }).toList();

        await _db.batch((batch) {
          batch.insertAll(_db.painAreas, companions);
        });
      }
    });

    return logId;
  }

  // ---------------------------------------------------------------------------
  // 取得
  // ---------------------------------------------------------------------------

  /// セッションに紐付く体調記録を時刻順で取得する
  Future<List<ConditionLog>> getConditionLogsForSession(String sessionId) {
    return (
      _db.select(_db.conditionLogs)
        ..where((t) => t.sessionId.equals(sessionId))
        ..orderBy([(t) => OrderingTerm(expression: t.recordedAt)])
    ).get();
  }

  /// 体調記録 ID に紐付く痛み部位を取得する
  Future<List<PainArea>> getPainAreasForLog(String conditionLogId) {
    return (
      _db.select(_db.painAreas)
        ..where((t) => t.conditionLogId.equals(conditionLogId))
    ).get();
  }

  // ---------------------------------------------------------------------------
  // 内部ユーティリティ
  // ---------------------------------------------------------------------------

  /// 部位コードから表示面 (front / back / null) を判定する
  ///
  /// - 前面のみ表示される部位 → 'front'
  /// - 背面のみ表示される部位 → 'back'
  /// - 両面に表示される部位   → null
  static String? _sideForPart(String code) {
    const frontOnly = {
      'chest',
      'left_wrist',
      'right_wrist',
      'left_knee',
      'right_knee',
      'left_shin',
      'right_shin',
      'left_sole',
      'right_sole',
    };
    const backOnly = {
      'upper_back',
      'left_calf',
      'right_calf',
    };
    if (frontOnly.contains(code)) return 'front';
    if (backOnly.contains(code)) return 'back';
    return null;
  }
}

// ---- Riverpod プロバイダ ----

final conditionLogRepositoryProvider =
    Provider<ConditionLogRepository>((ref) {
  return ConditionLogRepository(ref.watch(appDatabaseProvider));
});
