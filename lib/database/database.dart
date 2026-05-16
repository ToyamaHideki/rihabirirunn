import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'db_connect.dart';

import 'tables/condition_logs.dart';
import 'tables/gps_points.dart';
import 'tables/pain_areas.dart';
import 'tables/run_sessions.dart';
import 'tables/saved_routes.dart';
import 'tables/user_profiles.dart';
import 'tables/user_settings.dart';

part 'database.g.dart';

/// アプリ全体で使用する Drift データベース
@DriftDatabase(tables: [
  UserProfiles,
  UserSettings,
  RunSessions,
  GpsPoints,
  ConditionLogs,
  PainAreas,
  SavedRoutes,
])
class AppDatabase extends _$AppDatabase {
  /// [openDriftDatabase] はプラットフォームを自動判別する条件付きインポート。
  /// Web では WebDatabase + sql.js、Native では drift_flutter の driftDatabase を使用する。
  AppDatabase() : super(openDriftDatabase());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        // 全テーブル作成
        await m.createAll();

        // ---- インデックス追加 (T-0.2.8) ----

        // 走行履歴一覧（降順ソート用）
        await customStatement(
          'CREATE INDEX idx_run_sessions_user_started '
          'ON run_sessions(user_id, started_at DESC)',
        );

        // ストリーク計算用（達成セッションを日付降順で取得）
        await customStatement(
          'CREATE INDEX idx_run_sessions_streak '
          'ON run_sessions(user_id, is_goal_achieved, started_at DESC)',
        );

        // 体調記録のセッション紐付け取得用
        await customStatement(
          'CREATE INDEX idx_condition_logs_session '
          'ON condition_logs(session_id)',
        );

        // GPS 軌跡のルート再描画用（セッション + 時刻順）
        await customStatement(
          'CREATE INDEX idx_gps_points_session_time '
          'ON gps_points(session_id, recorded_at ASC)',
        );

        // 保存済みルート一覧（ユーザー単位、作成日降順）
        await customStatement(
          'CREATE INDEX idx_saved_routes_user_created '
          'ON saved_routes(user_id, created_at DESC)',
        );
      },
      onUpgrade: (m, from, to) async {
        // v1 → v2: user_settings.gps_correction_enabled カラム追加
        if (from < 2) {
          await m.addColumn(
            userSettings,
            userSettings.gpsCorrectionEnabled,
          );
        }
        // v2 → v3: saved_routes テーブル追加
        if (from < 3) {
          await m.createTable(savedRoutes);
          await customStatement(
            'CREATE INDEX idx_saved_routes_user_created '
            'ON saved_routes(user_id, created_at DESC)',
          );
        }
      },
    );
  }
}

/// Riverpod プロバイダ
/// アプリ全体でシングルトンとして使用する
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
