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

  /// 2026年5月1日〜15日の毎日1セッション（計15件）を投入する。
  ///
  /// 距離は 600m から段階的に増加し、各種グラフが見栄え良く埋まる。
  Future<int> injectMay2026DailyData() async {
    assert(kDebugMode, 'DebugDataService は kDebugMode 限定です');

    final profile =
        await (_db.select(_db.userProfiles)..limit(1)).getSingleOrNull();
    if (profile == null) throw StateError('プロフィールが未作成です');

    final userId = profile.id;
    final rng = math.Random(20260501);
    int count = 0;

    // 距離プロファイル: 5月1日〜15日（600m → 1400m、やや波あり）
    const distancesM = <double>[
      620, 680, 590, 750, 820,  // 5/1〜5/5
      870, 910, 780, 950, 1020, // 5/6〜5/10
      1050, 980, 1100, 1180, 1250, // 5/11〜5/15
    ];
    // 痛みスコア（走行後）: 徐々に改善傾向
    const painAfterScores = <int>[
      5, 4, 5, 4, 3,  // 5/1〜5/5
      3, 3, 2, 3, 2,  // 5/6〜5/10
      2, 1, 2, 1, 1,  // 5/11〜5/15
    ];

    for (int day = 1; day <= 15; day++) {
      final idx = day - 1;
      final startedAt = DateTime(2026, 5, day, 7 + rng.nextInt(3),
          rng.nextInt(60)); // 7〜9 時台

      final plannedDist = distancesM[idx] + 100;
      final actualDist = distancesM[idx];
      final achieved = actualDist >= plannedDist * 0.95;

      // ペース: 700〜900 秒/km（ゆっくり歩き想定）
      final paceSecsPerKm = 700.0 + rng.nextInt(200);
      final durationSecs = (actualDist / 1000 * paceSecsPerKm).round();
      final calories = ((actualDist / 1000) * 55 + rng.nextInt(15)).round();

      final lat = 35.68 + rng.nextDouble() * 0.01 - 0.005;
      final lng = 139.69 + rng.nextDouble() * 0.01 - 0.005;

      final sessionId = _uuid.v4();

      await _insertSession(
        sessionId: sessionId,
        userId: userId,
        startedAt: startedAt,
        durationSecs: durationSecs,
        plannedDist: plannedDist,
        actualDist: actualDist,
        paceSecsPerKm: paceSecsPerKm,
        achieved: achieved,
        calories: calories,
        lat: lat,
        lng: lng,
      );

      final painBefore = (painAfterScores[idx] + rng.nextInt(2)).clamp(0, 10);
      await _insertConditionLogs(
        userId: userId,
        sessionId: sessionId,
        startedAt: startedAt,
        durationSecs: durationSecs,
        painBefore: painBefore,
        painAfter: painAfterScores[idx],
        rng: rng,
      );

      count++;
    }

    return count;
  }

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

        await _insertSession(
          sessionId: sessionId,
          userId: userId,
          startedAt: startedAt,
          durationSecs: durationSecs,
          plannedDist: plannedDist,
          actualDist: actualDist,
          paceSecsPerKm: paceSecsPerKm,
          achieved: achieved,
          calories: calories,
          lat: lat,
          lng: lng,
        );

        final painBefore = rng.nextInt(5);
        final painAfter = (painBefore + rng.nextInt(4) - 1).clamp(0, 10);
        await _insertConditionLogs(
          userId: userId,
          sessionId: sessionId,
          startedAt: startedAt,
          durationSecs: durationSecs,
          painBefore: painBefore,
          painAfter: painAfter,
          rng: rng,
        );

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

  // ---- プライベートヘルパー ----

  Future<void> _insertSession({
    required String sessionId,
    required String userId,
    required DateTime startedAt,
    required int durationSecs,
    required double plannedDist,
    required double actualDist,
    required double paceSecsPerKm,
    required bool achieved,
    required int calories,
    required double lat,
    required double lng,
  }) async {
    await _db.into(_db.runSessions).insertOnConflictUpdate(
          RunSessionsCompanion(
            id: Value(sessionId),
            userId: Value(userId),
            startedAt: Value(startedAt),
            finishedAt:
                Value(startedAt.add(Duration(seconds: durationSecs))),
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
          ),
        );
  }

  Future<void> _insertConditionLogs({
    required String userId,
    required String sessionId,
    required DateTime startedAt,
    required int durationSecs,
    required int painBefore,
    required int painAfter,
    required math.Random rng,
  }) async {
    final beforeLogId = _uuid.v4();
    await _db.into(_db.conditionLogs).insertOnConflictUpdate(
          ConditionLogsCompanion(
            id: Value(beforeLogId),
            userId: Value(userId),
            sessionId: Value(sessionId),
            timing: const Value('before'),
            painScore: Value(painBefore),
            recordedAt: Value(
                startedAt.subtract(const Duration(minutes: 5))),
          ),
        );

    final afterLogId = _uuid.v4();
    await _db.into(_db.conditionLogs).insertOnConflictUpdate(
          ConditionLogsCompanion(
            id: Value(afterLogId),
            userId: Value(userId),
            sessionId: Value(sessionId),
            timing: const Value('after'),
            painScore: Value(painAfter),
            recordedAt: Value(
                startedAt.add(Duration(seconds: durationSecs + 300))),
          ),
        );

    if (painAfter >= 3) {
      final part = _bodyParts[rng.nextInt(_bodyParts.length)];
      await _db.into(_db.painAreas).insertOnConflictUpdate(
            PainAreasCompanion(
              id: Value(_uuid.v4()),
              conditionLogId: Value(afterLogId),
              bodyPart: Value(part),
              side: const Value('front'),
            ),
          );
    }
  }

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
