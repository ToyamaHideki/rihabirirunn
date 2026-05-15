import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database.dart';

// ---------------------------------------------------------------------------
// T-4.2.3: インポートサービス
// ---------------------------------------------------------------------------

/// エクスポート JSON の解析結果サマリ
class ImportSummary {
  const ImportSummary({
    required this.exportVersion,
    required this.exportedAt,
    required this.appVersion,
    required this.sessionCount,
    required this.hasProfile,
    required this.rawData,
  });

  final String exportVersion;
  final DateTime exportedAt;
  final String appVersion;
  final int sessionCount;
  final bool hasProfile;

  /// 解析済み生データ（confirm後に importData に渡す）
  final Map<String, dynamic> rawData;
}

/// インポート処理結果
class ImportResult {
  const ImportResult({
    required this.importedSessions,
    required this.skippedSessions,
  });

  final int importedSessions;
  final int skippedSessions;
}

/// T-4.2.3〜4.2.5: データインポートサービス
///
/// JSON を解析 → バージョン確認 → DB に batch insert（T-4.2.4: バージョン互換チェック）
/// T-4.2.5: マージ（既存セッション保持）または上書き（全データ削除後に挿入）を選択可能
class DataImportService {
  DataImportService(this._db);

  final AppDatabase _db;

  // ---------------------------------------------------------------------------
  // T-4.2.3: パース・バリデーション
  // ---------------------------------------------------------------------------

  /// JSON 文字列を解析し ImportSummary を返す。
  /// T-4.2.4: exportVersion が "1.0" 以外の場合は FormatException をスロー。
  ImportSummary parseAndValidate(String jsonStr) {
    final Map<String, dynamic> data;
    try {
      data = jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      throw const FormatException('JSONの形式が正しくありません');
    }

    // T-4.2.4: バージョン互換チェック
    final version = data['exportVersion'] as String?;
    if (version == null || version != '1.0') {
      throw FormatException(
        'このバックアップファイルには対応していません（バージョン: $version）',
      );
    }

    final exportedAtStr = data['exportedAt'] as String?;
    final exportedAt =
        exportedAtStr != null ? DateTime.parse(exportedAtStr) : DateTime.now();

    final sessions = data['runSessions'] as List? ?? [];
    final profile = data['userProfile'];

    return ImportSummary(
      exportVersion: version,
      exportedAt: exportedAt,
      appVersion: data['appVersion'] as String? ?? '不明',
      sessionCount: sessions.length,
      hasProfile: profile != null,
      rawData: data,
    );
  }

  // ---------------------------------------------------------------------------
  // T-4.2.5: DB インポート（マージ or 上書き）
  // ---------------------------------------------------------------------------

  /// [overwrite] = true: 既存データを削除してから挿入
  /// [overwrite] = false: 既存 ID はスキップ（マージ）
  Future<ImportResult> importData(
    Map<String, dynamic> data, {
    required bool overwrite,
  }) async {
    int imported = 0;
    int skipped = 0;

    await _db.transaction(() async {
      if (overwrite) {
        // 外部キー cascade があるため sessions 削除だけで連鎖削除される
        await _db.delete(_db.runSessions).go();
      }

      // ---- Profile & Settings ----
      final profileJson = data['userProfile'] as Map<String, dynamic>?;
      if (profileJson != null) {
        await _upsertProfile(profileJson);
      }
      final settingsJson = data['userSettings'] as Map<String, dynamic>?;
      if (settingsJson != null && profileJson != null) {
        await _upsertSettings(settingsJson);
      }

      // ---- RunSessions ----
      final sessionsJson =
          (data['runSessions'] as List?)?.cast<Map<String, dynamic>>() ?? [];

      // マージ時: 既存 ID セットを取得
      Set<String> existingIds = {};
      if (!overwrite) {
        final rows = await _db.select(_db.runSessions).get();
        existingIds = rows.map((r) => r.id).toSet();
      }

      for (final sJson in sessionsJson) {
        final sessionId = sJson['id'] as String? ?? '';
        if (existingIds.contains(sessionId)) {
          skipped++;
          continue;
        }

        try {
          await _insertSession(sJson);
          imported++;
        } catch (_) {
          // 1件の失敗でトランザクション全体を止めない
          skipped++;
        }
      }
    });

    return ImportResult(
      importedSessions: imported,
      skippedSessions: skipped,
    );
  }

  // ---------------------------------------------------------------------------
  // 内部: Profile upsert
  // ---------------------------------------------------------------------------

  Future<void> _upsertProfile(Map<String, dynamic> p) async {
    final id = p['id'] as String? ?? '';
    final exists = await (_db.select(_db.userProfiles)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();

    final agreedAt = _parseDate(p['agreedDisclaimerAt']) ?? DateTime.now();
    final createdAt = _parseDate(p['createdAt']) ?? DateTime.now();
    final updatedAt = _parseDate(p['updatedAt']) ?? DateTime.now();

    if (exists == null) {
      await _db.into(_db.userProfiles).insert(
            UserProfilesCompanion.insert(
              id: id,
              agreedDisclaimerAt: agreedAt,
              age: Value(p['age'] as int?),
              rehabTarget: Value(p['rehabTarget'] as String?),
              finalGoalDistance: Value(_toDouble(p['finalGoalDistance'])),
              mode: Value(p['mode'] as String? ?? 'standard'),
              currentTargetDistance:
                  Value(_toDouble(p['currentTargetDistance']) ?? 500.0),
              createdAt: createdAt,
              updatedAt: updatedAt,
            ),
          );
    } else {
      await (_db.update(_db.userProfiles)..where((t) => t.id.equals(id)))
          .write(
        UserProfilesCompanion(
          age: Value(p['age'] as int?),
          rehabTarget: Value(p['rehabTarget'] as String?),
          finalGoalDistance: Value(_toDouble(p['finalGoalDistance'])),
          mode: Value(p['mode'] as String? ?? 'standard'),
          currentTargetDistance:
              Value(_toDouble(p['currentTargetDistance']) ?? 500.0),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // 内部: Settings upsert
  // ---------------------------------------------------------------------------

  Future<void> _upsertSettings(Map<String, dynamic> s) async {
    final id = s['id'] as String? ?? '';
    final userId = s['userId'] as String? ?? '';
    final exists = await (_db.select(_db.userSettings)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();

    if (exists == null) {
      await _db.into(_db.userSettings).insert(
            UserSettingsCompanion.insert(
              id: id,
              userId: userId,
              designTheme: Value(s['designTheme'] as String? ?? 'soft'),
              fontSize: Value(s['fontSize'] as String? ?? 'medium'),
              notificationEnabled:
                  Value(s['notificationEnabled'] as bool? ?? true),
              streakAlertEnabled:
                  Value(s['streakAlertEnabled'] as bool? ?? false),
              weatherAlertEnabled:
                  Value(s['weatherAlertEnabled'] as bool? ?? false),
              updatedAt: _parseDate(s['updatedAt']) ?? DateTime.now(),
            ),
          );
    } else {
      await (_db.update(_db.userSettings)..where((t) => t.id.equals(id)))
          .write(
        UserSettingsCompanion(
          designTheme: Value(s['designTheme'] as String? ?? 'soft'),
          fontSize: Value(s['fontSize'] as String? ?? 'medium'),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // 内部: Session + GPS + Condition 一括 insert
  // ---------------------------------------------------------------------------

  Future<void> _insertSession(Map<String, dynamic> s) async {
    final sessionId = s['id'] as String? ?? '';
    final userId = s['userId'] as String? ?? '';

    await _db.into(_db.runSessions).insert(
          RunSessionsCompanion.insert(
            id: sessionId,
            userId: userId,
            startedAt: _parseDate(s['startedAt']) ?? DateTime.now(),
            finishedAt: Value(_parseDate(s['finishedAt'])),
            plannedDistance: _toDouble(s['plannedDistance']) ?? 0.0,
            actualDistance: Value(_toDouble(s['actualDistance']) ?? 0.0),
            durationSeconds: Value(s['durationSeconds'] as int? ?? 0),
            avgPaceSecsPerKm: Value(_toDouble(s['avgPaceSecsPerKm'])),
            routeType: Value(s['routeType'] as String? ?? 'loop'),
            routeGeoJson: Value(s['routeGeoJson'] as String?),
            isGoalAchieved: Value(s['isGoalAchieved'] as bool? ?? false),
            status: Value(s['status'] as String? ?? 'completed'),
            startLat: _toDouble(s['startLat']) ?? 0.0,
            startLng: _toDouble(s['startLng']) ?? 0.0,
            endLat: Value(_toDouble(s['endLat'])),
            endLng: Value(_toDouble(s['endLng'])),
            estimatedCalories: Value(s['estimatedCalories'] as int?),
            createdAt: _parseDate(s['createdAt']) ?? DateTime.now(),
          ),
        );

    // GPS ポイント
    final gpsPoints =
        (s['gpsPoints'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    if (gpsPoints.isNotEmpty) {
      await _db.batch((batch) {
        batch.insertAll(
          _db.gpsPoints,
          gpsPoints.map(
            (g) => GpsPointsCompanion.insert(
              id: g['id'] as String? ?? '',
              sessionId: sessionId,
              lat: _toDouble(g['lat']) ?? 0.0,
              lng: _toDouble(g['lng']) ?? 0.0,
              altitudeM: Value(_toDouble(g['altitudeM'])),
              accuracyM: Value(_toDouble(g['accuracyM'])),
              speedMps: Value(_toDouble(g['speedMps'])),
              recordedAt:
                  _parseDate(g['recordedAt']) ?? DateTime.now(),
            ),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      });
    }

    // 体調ログ
    for (final timing in ['conditionBefore', 'conditionAfter']) {
      final condJson = s[timing] as Map<String, dynamic>?;
      if (condJson != null) {
        await _insertConditionLog(condJson, sessionId, userId);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // 内部: ConditionLog + PainAreas insert
  // ---------------------------------------------------------------------------

  Future<void> _insertConditionLog(
    Map<String, dynamic> c,
    String sessionId,
    String userId,
  ) async {
    final logId = c['id'] as String? ?? '';
    await _db.into(_db.conditionLogs).insertOnConflictUpdate(
          ConditionLogsCompanion.insert(
            id: logId,
            userId: userId,
            sessionId: Value(sessionId),
            timing: c['timing'] as String? ?? 'before',
            painScore: Value(c['painScore'] as int? ?? 0),
            memo: Value(c['memo'] as String?),
            recordedAt: _parseDate(c['recordedAt']) ?? DateTime.now(),
          ),
        );

    final areas =
        (c['painAreas'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    if (areas.isNotEmpty) {
      await _db.batch((batch) {
        batch.insertAll(
          _db.painAreas,
          areas.map(
            (a) => PainAreasCompanion.insert(
              id: a['id'] as String? ?? '',
              conditionLogId: logId,
              bodyPart: a['bodyPart'] as String? ?? '',
              side: Value(a['side'] as String?),
            ),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      });
    }
  }

  // ---------------------------------------------------------------------------
  // ユーティリティ
  // ---------------------------------------------------------------------------

  DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    try {
      return DateTime.parse(v as String);
    } catch (_) {
      return null;
    }
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }
}

// ---------------------------------------------------------------------------
// Riverpod プロバイダ
// ---------------------------------------------------------------------------

final dataImportServiceProvider = Provider<DataImportService>((ref) {
  return DataImportService(ref.watch(appDatabaseProvider));
});
