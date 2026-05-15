import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../database/database.dart';

// ---------------------------------------------------------------------------
// デバッグ用ダミーデータ投入サービス（kDebugMode のみ使用）
// ---------------------------------------------------------------------------

/// 統計画面・履歴画面の動作確認用にリアルなダミーデータを DB に挿入する。
///
/// 使用条件: kDebugMode == true のとき限定。
/// 投入内容:
///   - 直近 12 週にランダム配置の走行セッション（計 20〜25 件）
///   - 各セッションの走行前/走行後 体調ログ
///   - 痛みスコアが高いセッションに痛み部位レコード
class DebugDataService {
  DebugDataService(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  // ---- 部位候補 ----
  static const _bodyParts = [
    'right_knee',
    'left_knee',
    'right_ankle',
    'left_ankle',
    'lower_back',
    'right_hip',
    'left_hip',
    'right_calf',
    'left_calf',
  ];

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// ダミーデータを投入する。プロフィールが未作成の場合は例外を投げる。
  /// 既存のダミーデータは上書きしない（重複 ID は insert or ignore）。
  Future<int> injectDummyData() async {
    assert(kDebugMode, 'DebugDataService は kDebugMode 限定です');

    final profile = await (_db.select(_db.userProfiles)..limit(1))
        .getSingleOrNull();
    if (profile == null) {
      throw StateError(
          'プロフィールが未作成のためダミーデータを投入できません。'
          '先にオンボーディングを完了させてください。');
    }

    final userId = profile.id;
    final rng = math.Random(2026); // 再現性のある乱数シード
    final now = DateTime.now();
    int insertedCount = 0;

    // 週ごとにセッション数を決定（直近ほど多め）
    for (int week = 11; week >= 0; week--) {
      final sessionsThisWeek = _sessionsPerWeek(week, rng);

      for (int s = 0; s < sessionsThisWeek; s++) {
        // セッション開始時刻（週内のランダムな日・朝〜昼前）
        final daysAgo = week * 7 + rng.nextInt(6);
        final hour = 7 + rng.nextInt(5); // 7〜11 時台
        final startedAt = DateTime(
          now.year,
          now.month,
          now.day - daysAgo,
          hour,
          rng.nextInt(60),
        );

        // 距離は週が新しいほど段階的に増加（300m → 2000m）
        final baseDist = 300.0 + (11 - week) * 140.0;
        final plannedDist = baseDist + 100.0;
        final actualDist = (baseDist + rng.nextDouble() * 300 - 100)
            .clamp(100.0, 3000.0);
        final achieved = actualDist >= plannedDist * 0.95;

        // ペース: 1.0〜1.5 m/s（歩行速度）
        final speedMps = 1.0 + rng.nextDouble() * 0.5;
        final durationSecs = (actualDist / speedMps).round();
        final paceSecsPerKm =
            durationSecs > 0 ? durationSecs / (actualDist / 1000) : 0.0;

        final calories =
            ((actualDist / 1000) * 60 + rng.nextInt(20)).round();

        // 東京近辺のダミー座標
        final lat = 35.68 + rng.nextDouble() * 0.02 - 0.01;
        final lng = 139.69 + rng.nextDouble() * 0.02 - 0.01;

        final sessionId = _uuid.v4();

        await _db
            .into(_db.runSessions)
            .insertOnConflictUpdate(RunSessionsCompanion(
              id: Value(sessionId),
              userId: Value(userId),
              startedAt: Value(startedAt),
              finishedAt: Value(
                  startedAt.add(Duration(seconds: durationSecs))),
              plannedDistance: Value(plannedDist),
              actualDistance: Value(actualDist),
              durationSeconds: Value(durationSecs),
              avgPaceSecsPerKm: Value(paceSecsPerKm),
              isGoalAchieved: Value(achieved),
              status: const Value('completed'),
              startLat: Value(lat),
              startLng: Value(lng),
              estimatedCalories: Value(calories),
              createdAt: Value(startedAt),
            ));

        // 走行前 体調ログ
        final painBefore = rng.nextInt(5); // 0〜4
        final beforeLogId = _uuid.v4();
        await _db
            .into(_db.conditionLogs)
            .insertOnConflictUpdate(ConditionLogsCompanion(
              id: Value(beforeLogId),
              userId: Value(userId),
              sessionId: Value(sessionId),
              timing: const Value('before'),
              painScore: Value(painBefore),
              recordedAt: Value(
                  startedAt.subtract(const Duration(minutes: 5))),
            ));

        // 走行後 体調ログ
        final painAfter =
            (painBefore + rng.nextInt(4) - 1).clamp(0, 10);
        final afterLogId = _uuid.v4();
        await _db
            .into(_db.conditionLogs)
            .insertOnConflictUpdate(ConditionLogsCompanion(
              id: Value(afterLogId),
              userId: Value(userId),
              sessionId: Value(sessionId),
              timing: const Value('after'),
              painScore: Value(painAfter),
              recordedAt: Value(
                  startedAt.add(Duration(seconds: durationSecs + 300))),
            ));

        // 痛みがある場合は痛み部位を追加
        if (painAfter >= 3) {
          final part = _bodyParts[rng.nextInt(_bodyParts.length)];
          await _db
              .into(_db.painAreas)
              .insertOnConflictUpdate(PainAreasCompanion(
                id: Value(_uuid.v4()),
                conditionLogId: Value(afterLogId),
                bodyPart: Value(part),
                side: const Value('front'),
              ));
        }

        insertedCount++;
      }
    }

    return insertedCount;
  }

  /// このユーザーの走行セッションを全削除（CASCADE で体調ログ・GPS も消える）
  Future<void> clearAllSessions() async {
    assert(kDebugMode, 'DebugDataService は kDebugMode 限定です');

    final profile = await (_db.select(_db.userProfiles)..limit(1))
        .getSingleOrNull();
    if (profile == null) return;

    await (_db.delete(_db.runSessions)
          ..where((t) => t.userId.equals(profile.id)))
        .go();
  }

  // ---- ヘルパー ----

  /// 週インデックス（0=最古, 11=直近）からその週のセッション数を決定
  int _sessionsPerWeek(int weekIdx, math.Random rng) {
    // 直近4週は多め、古い週はまばら
    if (weekIdx >= 8) return rng.nextInt(2) + 2; // 2〜3
    if (weekIdx >= 4) return rng.nextInt(2) + 1; // 1〜2
    return rng.nextInt(2); // 0〜1
  }
}

// ---------------------------------------------------------------------------
// Riverpod プロバイダ
// ---------------------------------------------------------------------------

final debugDataServiceProvider = Provider<DebugDataService>((ref) {
  return DebugDataService(ref.watch(appDatabaseProvider));
});
