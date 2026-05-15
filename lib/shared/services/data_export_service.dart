import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../database/database.dart';

// ---------------------------------------------------------------------------
// T-4.2.1: エクスポートサービス
// ---------------------------------------------------------------------------

/// 全データを spec 4.1 形式の JSON にシリアライズし、共有シートで出力する。
class DataExportService {
  DataExportService(this._db);

  final AppDatabase _db;

  // アプリバージョン（ストア申請前に更新）
  static const _kAppVersion = '1.0.0';

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// T-4.2.2: JSON をメモリ上でエクスポートし、共有シートを表示する
  ///
  /// XFile.fromData を使用することで dart:io に依存せず
  /// iOS / Android / Web すべてで動作する。
  Future<void> exportAndShare() async {
    final data = await _buildExportData();
    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    final bytes = Uint8List.fromList(utf8.encode(jsonStr));
    final ts = DateTime.now().millisecondsSinceEpoch;

    await Share.shareXFiles(
      [
        XFile.fromData(
          bytes,
          name: 'rehabili_run_$ts.json',
          mimeType: 'application/json',
        ),
      ],
      subject: 'リハビリウォークデータ',
      text: 'リハビリウォークのバックアップデータです（v$_kAppVersion）',
    );
  }

  /// ファイルサイズ等の事前確認用: セッション件数を返す
  Future<int> getSessionCount() async {
    final profile = await (_db.select(_db.userProfiles)..limit(1))
        .getSingleOrNull();
    if (profile == null) return 0;
    final rows = await (_db.select(_db.runSessions)
          ..where((t) => t.userId.equals(profile.id)))
        .get();
    return rows.length;
  }

  // ---------------------------------------------------------------------------
  // 内部: エクスポートデータ構築
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> _buildExportData() async {
    final profile = await (_db.select(_db.userProfiles)..limit(1))
        .getSingleOrNull();

    final settings = profile == null
        ? null
        : await (_db.select(_db.userSettings)
              ..where((t) => t.userId.equals(profile.id)))
            .getSingleOrNull();

    final sessions = profile == null
        ? <RunSession>[]
        : await (_db.select(_db.runSessions)
              ..where((t) => t.userId.equals(profile.id))
              ..orderBy([
                (t) => OrderingTerm(
                      expression: t.startedAt,
                      mode: OrderingMode.desc,
                    ),
              ]))
            .get();

    final sessionsJson = <Map<String, dynamic>>[];
    for (final s in sessions) {
      final gps = await (_db.select(_db.gpsPoints)
            ..where((t) => t.sessionId.equals(s.id))
            ..orderBy([
              (t) => OrderingTerm(expression: t.recordedAt),
            ]))
          .get();

      final condLogs = await (_db.select(_db.conditionLogs)
            ..where((t) => t.sessionId.equals(s.id)))
          .get();

      Map<String, dynamic>? condBefore;
      Map<String, dynamic>? condAfter;

      for (final log in condLogs) {
        final areas = await (_db.select(_db.painAreas)
              ..where((t) => t.conditionLogId.equals(log.id)))
            .get();
        final logJson = _conditionLogToJson(log, areas);
        if (log.timing == 'before') {
          condBefore = logJson;
        } else if (log.timing == 'after') {
          condAfter = logJson;
        }
      }

      sessionsJson.add(_sessionToJson(s, gps, condBefore, condAfter));
    }

    return {
      'exportVersion': '1.0',
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'appVersion': _kAppVersion,
      'userProfile': profile == null ? null : _profileToJson(profile),
      'userSettings': settings == null ? null : _settingsToJson(settings),
      'runSessions': sessionsJson,
    };
  }

  // ---------------------------------------------------------------------------
  // シリアライズヘルパー
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _profileToJson(UserProfile p) => {
        'id': p.id,
        'agreedDisclaimerAt': p.agreedDisclaimerAt.toIso8601String(),
        'age': p.age,
        'rehabTarget': p.rehabTarget,
        'finalGoalDistance': p.finalGoalDistance,
        'mode': p.mode,
        'currentTargetDistance': p.currentTargetDistance,
        'createdAt': p.createdAt.toIso8601String(),
        'updatedAt': p.updatedAt.toIso8601String(),
      };

  Map<String, dynamic> _settingsToJson(UserSetting s) => {
        'id': s.id,
        'userId': s.userId,
        'designTheme': s.designTheme,
        'fontSize': s.fontSize,
        'notificationEnabled': s.notificationEnabled,
        'streakAlertEnabled': s.streakAlertEnabled,
        'weatherAlertEnabled': s.weatherAlertEnabled,
        'updatedAt': s.updatedAt.toIso8601String(),
      };

  Map<String, dynamic> _sessionToJson(
    RunSession s,
    List<GpsPoint> gps,
    Map<String, dynamic>? condBefore,
    Map<String, dynamic>? condAfter,
  ) =>
      {
        'id': s.id,
        'userId': s.userId,
        'startedAt': s.startedAt.toIso8601String(),
        'finishedAt': s.finishedAt?.toIso8601String(),
        'plannedDistance': s.plannedDistance,
        'actualDistance': s.actualDistance,
        'durationSeconds': s.durationSeconds,
        'avgPaceSecsPerKm': s.avgPaceSecsPerKm,
        'routeType': s.routeType,
        'routeGeoJson': s.routeGeoJson,
        'isGoalAchieved': s.isGoalAchieved,
        'status': s.status,
        'startLat': s.startLat,
        'startLng': s.startLng,
        'endLat': s.endLat,
        'endLng': s.endLng,
        'estimatedCalories': s.estimatedCalories,
        'createdAt': s.createdAt.toIso8601String(),
        'gpsPoints': gps
            .map(
              (g) => {
                'id': g.id,
                'lat': g.lat,
                'lng': g.lng,
                'altitudeM': g.altitudeM,
                'accuracyM': g.accuracyM,
                'speedMps': g.speedMps,
                'recordedAt': g.recordedAt.toIso8601String(),
              },
            )
            .toList(),
        'conditionBefore': condBefore,
        'conditionAfter': condAfter,
      };

  Map<String, dynamic> _conditionLogToJson(
    ConditionLog log,
    List<PainArea> areas,
  ) =>
      {
        'id': log.id,
        'userId': log.userId,
        'timing': log.timing,
        'painScore': log.painScore,
        'memo': log.memo,
        'recordedAt': log.recordedAt.toIso8601String(),
        'painAreas': areas
            .map((a) => {'id': a.id, 'bodyPart': a.bodyPart, 'side': a.side})
            .toList(),
      };
}

// ---------------------------------------------------------------------------
// Riverpod プロバイダ
// ---------------------------------------------------------------------------

final dataExportServiceProvider = Provider<DataExportService>((ref) {
  return DataExportService(ref.watch(appDatabaseProvider));
});
