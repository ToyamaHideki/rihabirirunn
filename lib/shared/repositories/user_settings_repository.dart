import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../database/database.dart';

/// UserSettings の CRUD 操作を担当するリポジトリ
class UserSettingsRepository {
  UserSettingsRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// userId に紐づく設定を取得（存在しない場合は null）
  Future<UserSetting?> getByUserId(String userId) {
    return (_db.select(_db.userSettings)
          ..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();
  }

  /// 設定を新規作成
  Future<void> createSettings({
    required String userId,
    String designTheme = 'soft',
    String fontSize = 'medium',
  }) async {
    await _db.into(_db.userSettings).insert(
          UserSettingsCompanion.insert(
            id: _uuid.v4(),
            userId: userId,
            designTheme: Value(designTheme),
            fontSize: Value(fontSize),
            updatedAt: DateTime.now(),
          ),
        );
  }

  /// 設定を更新
  Future<void> updateSettings(
    String id, {
    String? designTheme,
    String? fontSize,
    bool? notificationEnabled,
    bool? streakAlertEnabled,
    bool? weatherAlertEnabled,
    bool? gpsCorrectionEnabled,
  }) async {
    await (_db.update(_db.userSettings)..where((t) => t.id.equals(id))).write(
      UserSettingsCompanion(
        designTheme: designTheme != null
            ? Value(designTheme)
            : const Value.absent(),
        fontSize:
            fontSize != null ? Value(fontSize) : const Value.absent(),
        notificationEnabled: notificationEnabled != null
            ? Value(notificationEnabled)
            : const Value.absent(),
        streakAlertEnabled: streakAlertEnabled != null
            ? Value(streakAlertEnabled)
            : const Value.absent(),
        weatherAlertEnabled: weatherAlertEnabled != null
            ? Value(weatherAlertEnabled)
            : const Value.absent(),
        gpsCorrectionEnabled: gpsCorrectionEnabled != null
            ? Value(gpsCorrectionEnabled)
            : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}

/// Riverpod プロバイダ
final userSettingsRepositoryProvider =
    Provider<UserSettingsRepository>((ref) {
  return UserSettingsRepository(ref.watch(appDatabaseProvider));
});
