import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database.dart';
import '../repositories/user_profile_repository.dart';

// ---------------------------------------------------------------------------
// 更新結果DTO
// ---------------------------------------------------------------------------

/// T-3.2: 目標距離自動調整の結果
class TargetUpdateResult {
  const TargetUpdateResult({
    required this.previousTarget,
    required this.newTarget,
    required this.consecutiveAchieved,
    required this.consecutiveNotAchieved,
  });

  /// 今回の走行前の目標距離(m)
  final double previousTarget;

  /// 次回の目標距離(m)（100m 単位に丸め済み）
  final double newTarget;

  /// 連続達成回数（今回含む、未達成時は 0）
  final int consecutiveAchieved;

  /// 連続未達成回数（今回含む、達成時は 0）
  final int consecutiveNotAchieved;

  /// 差分(m)
  double get deltaMeters => newTarget - previousTarget;

  /// 変化があったか
  bool get changed => deltaMeters.abs() > 0.5;

  /// 変化率の文字列（例: "+10.0%" / "-5.0%"）
  String get deltaPercentText {
    if (!changed || previousTarget <= 0) return '';
    final pct = deltaMeters / previousTarget * 100;
    return pct >= 0
        ? '+${pct.toStringAsFixed(1)}%'
        : '${pct.toStringAsFixed(1)}%';
  }
}

// ---------------------------------------------------------------------------
// T-3.2: 目標距離自動調整サービス
// ---------------------------------------------------------------------------

/// モード別目標距離自動調整ロジック
///
/// T-3.2.1: モード別更新ロジック
/// T-3.2.2: 連続達成・連続未達成カウント
/// T-3.2.3: 走行終了時の自動更新
class TargetDistanceService {
  TargetDistanceService(this._db, this._profileRepo);

  final AppDatabase _db;
  final UserProfileRepository _profileRepo;

  /// 距離の下限(m) = 仕様書 S20 スライダー最小値
  static const double minDistance = 100.0;

  /// 距離の上限(m) = 仕様書 S20 スライダー最大値
  static const double maxDistance = 21000.0;

  // ---------------------------------------------------------------------------
  // T-3.2.1: モード別更新ロジック（純粋計算、static でテスト容易）
  // ---------------------------------------------------------------------------

  /// モード・達成状況・ストリークから次回目標距離を計算する
  ///
  /// 慎重モード: 達成 → ×1.05、2日連続未達成 → ×0.95、それ以外維持
  /// 標準モード: 達成 → ×1.10、未達成 → 維持
  /// チャレンジモード: 達成 → ×1.15 (3日連続達成時 × 1.20)、未達成 → 維持
  /// カスタム: 自動調整なし
  ///
  /// 結果は 100m 単位に丸め、100m〜21km にクランプする
  static double calculate({
    required String mode,
    required double currentTarget,
    required bool isAchieved,
    required int consecutiveAchieved,
    required int consecutiveNotAchieved,
  }) {
    double next = currentTarget;

    switch (mode) {
      case 'conservative':
        if (isAchieved) {
          next = currentTarget * 1.05;
        } else if (consecutiveNotAchieved >= 2) {
          next = currentTarget * 0.95;
        }
      case 'standard':
        if (isAchieved) {
          next = currentTarget * 1.10;
        }
      case 'challenge':
        if (isAchieved) {
          // 3日連続達成でボーナス +20%、それ以外 +15%
          next = currentTarget *
              (consecutiveAchieved >= 3 ? 1.20 : 1.15);
        }
      case 'custom':
      // カスタムモードは自動調整なし
    }

    // 100m 単位に丸めてクランプ
    return ((next / 100.0).round() * 100.0)
        .clamp(minDistance, maxDistance)
        .toDouble();
  }

  // ---------------------------------------------------------------------------
  // T-3.2.3: 走行終了後の自動更新
  // ---------------------------------------------------------------------------

  /// 走行完了後に目標距離を自動更新する
  ///
  /// 1. DB からストリーク（連続達成 / 連続未達成）を集計
  /// 2. モード別ロジックで次回目標を計算
  /// 3. UserProfile.currentTargetDistance を DB に書き込む
  ///
  /// カスタムモードでも呼び出し可能（変更なしの TargetUpdateResult を返す）
  Future<TargetUpdateResult> updateAfterRun({
    required UserProfile profile,
    required RunSession session,
  }) async {
    // T-3.2.2: ストリーク集計（今回のセッションを含む）
    final consecutiveAchieved = session.isGoalAchieved
        ? await _countConsecutiveAchieved(profile.id)
        : 0;
    final consecutiveNotAchieved = session.isGoalAchieved
        ? 0
        : await _countConsecutiveNotAchieved(profile.id);

    // T-3.2.1: 次回目標距離を計算
    final newTarget = calculate(
      mode: profile.mode,
      currentTarget: profile.currentTargetDistance,
      isAchieved: session.isGoalAchieved,
      consecutiveAchieved: consecutiveAchieved,
      consecutiveNotAchieved: consecutiveNotAchieved,
    );

    // DB 更新
    await _profileRepo.updateTargetDistance(profile.id, newTarget);

    return TargetUpdateResult(
      previousTarget: profile.currentTargetDistance,
      newTarget: newTarget,
      consecutiveAchieved: consecutiveAchieved,
      consecutiveNotAchieved: consecutiveNotAchieved,
    );
  }

  // ---------------------------------------------------------------------------
  // T-3.2.2: ストリーク集計
  // ---------------------------------------------------------------------------

  /// 直近から遡って連続達成セッション数を返す（今回のセッションを含む）
  Future<int> _countConsecutiveAchieved(String userId) async {
    final sessions = await _recentSessions(userId);
    var count = 0;
    for (final s in sessions) {
      if (s.isGoalAchieved) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  /// 直近から遡って連続未達成セッション数を返す（今回のセッションを含む）
  Future<int> _countConsecutiveNotAchieved(String userId) async {
    final sessions = await _recentSessions(userId);
    var count = 0;
    for (final s in sessions) {
      if (!s.isGoalAchieved) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  /// ストリーク計算用: 直近 20 件のセッションを開始時刻降順で取得
  Future<List<RunSession>> _recentSessions(String userId) {
    return (
      _db.select(_db.runSessions)
        ..where((t) => t.userId.equals(userId))
        ..orderBy([
          (t) => OrderingTerm(
                expression: t.startedAt,
                mode: OrderingMode.desc,
              ),
        ])
        ..limit(20)
    ).get();
  }
}

// ---- Riverpod プロバイダ ----

final targetDistanceServiceProvider =
    Provider<TargetDistanceService>((ref) {
  return TargetDistanceService(
    ref.watch(appDatabaseProvider),
    ref.watch(userProfileRepositoryProvider),
  );
});
