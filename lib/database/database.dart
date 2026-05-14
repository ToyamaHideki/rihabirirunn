import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/condition_logs.dart';
import 'tables/gps_points.dart';
import 'tables/pain_areas.dart';
import 'tables/run_sessions.dart';
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
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

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
      },
      onUpgrade: (m, from, to) async {
        // 将来のマイグレーションはここに追加
      },
    );
  }
}

/// DB 接続を遅延オープン（アプリ起動時に documents ディレクトリを確定）
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'rihabiri_run.db'));
    return NativeDatabase.createInBackground(file);
  });
}

/// Riverpod プロバイダ
/// アプリ全体でシングルトンとして使用する
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
