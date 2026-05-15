import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// スナップショットデータモデル
// ---------------------------------------------------------------------------

/// アプリ強制終了時に保存された走行の断片情報
///
/// T-2.3.1: 定期スナップショット保存
/// T-2.3.2: 起動時の中断走行検出に使用
class RunSnapshot {
  const RunSnapshot({
    required this.elapsedSeconds,
    required this.distanceMeters,
    required this.paceSecPerKm,
    required this.savedAt,
  });

  /// 経過秒数
  final int elapsedSeconds;

  /// 累積距離（m）
  final double distanceMeters;

  /// ペース（秒/km）
  final int paceSecPerKm;

  /// 保存日時
  final DateTime savedAt;

  // ---- 表示用ゲッター ----

  String get formattedDistance {
    if (distanceMeters < 1000) return '${distanceMeters.round()}m';
    return '${(distanceMeters / 1000).toStringAsFixed(2)}km';
  }

  String get formattedElapsed {
    final h = elapsedSeconds ~/ 3600;
    final m = (elapsedSeconds % 3600) ~/ 60;
    final s = elapsedSeconds % 60;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

// ---------------------------------------------------------------------------
// T-2.3.1: スナップショットサービス
// ---------------------------------------------------------------------------

/// アプリ強制終了時の走行状態を SharedPreferences に保存するサービス
///
/// - TrackingNotifier が 30 秒ごとに [save] を呼び出す
/// - 正常終了時に [clear] を呼び出してスナップショットを削除
/// - 起動時に [load] でスナップショットの存在を確認する（T-2.3.2）
class RunSnapshotService {
  static const _key = 'active_run_snapshot';

  /// スナップショットを保存する（上書き）
  Future<void> save({
    required int elapsedSeconds,
    required double distanceMeters,
    required int paceSecPerKm,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode({
      'elapsed': elapsedSeconds,
      'distance': distanceMeters,
      'pace': paceSecPerKm,
      'savedAt': DateTime.now().millisecondsSinceEpoch,
    });
    await prefs.setString(_key, json);
  }

  /// スナップショットを削除する（正常終了・ユーザー破棄時）
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// スナップショットを読み込む
  ///
  /// - スナップショットが存在しない場合は null を返す
  /// - 保存から 24 時間以上経過している場合は自動削除して null を返す
  /// - JSON の破損があれば自動削除して null を返す
  Future<RunSnapshot?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final savedAt = DateTime.fromMillisecondsSinceEpoch(
        map['savedAt'] as int,
      );

      // 24 時間以上前のスナップショットは無効とみなして削除
      if (DateTime.now().difference(savedAt).inHours >= 24) {
        await prefs.remove(_key);
        return null;
      }

      return RunSnapshot(
        elapsedSeconds: map['elapsed'] as int,
        distanceMeters: (map['distance'] as num).toDouble(),
        paceSecPerKm: map['pace'] as int,
        savedAt: savedAt,
      );
    } catch (_) {
      // 破損した JSON → 削除して null を返す
      await prefs.remove(_key);
      return null;
    }
  }
}

// ---- Riverpod プロバイダ ----

final runSnapshotServiceProvider = Provider<RunSnapshotService>(
  (_) => RunSnapshotService(),
);
