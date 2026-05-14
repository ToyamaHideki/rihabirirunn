import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../database/database.dart';

/// UserProfile の CRUD 操作を担当するリポジトリ
class UserProfileRepository {
  UserProfileRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// プロフィールを取得（存在しない場合は null）
  Future<UserProfile?> getProfile() {
    return (_db.select(_db.userProfiles)..limit(1)).getSingleOrNull();
  }

  /// プロフィールを新規作成
  Future<void> createProfile({
    required DateTime agreedDisclaimerAt,
    int? age,
    String? rehabTarget,
    double? finalGoalDistance,
    String mode = 'standard',
    double currentTargetDistance = 500.0,
  }) async {
    final now = DateTime.now();
    await _db.into(_db.userProfiles).insert(
          UserProfilesCompanion.insert(
            id: _uuid.v4(),
            agreedDisclaimerAt: agreedDisclaimerAt,
            age: Value(age),
            rehabTarget: Value(rehabTarget),
            finalGoalDistance: Value(finalGoalDistance),
            mode: Value(mode),
            currentTargetDistance: Value(currentTargetDistance),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  /// プロフィールを更新
  Future<void> updateProfile(
    String id, {
    int? age,
    String? rehabTarget,
    double? finalGoalDistance,
    String? mode,
  }) async {
    await (_db.update(_db.userProfiles)..where((t) => t.id.equals(id))).write(
      UserProfilesCompanion(
        age: age != null ? Value(age) : const Value.absent(),
        rehabTarget:
            rehabTarget != null ? Value(rehabTarget) : const Value.absent(),
        finalGoalDistance: finalGoalDistance != null
            ? Value(finalGoalDistance)
            : const Value.absent(),
        mode: mode != null ? Value(mode) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// 目標距離のみ更新（走行完了後に呼び出す）
  Future<void> updateTargetDistance(String id, double newDistance) async {
    await (_db.update(_db.userProfiles)..where((t) => t.id.equals(id))).write(
      UserProfilesCompanion(
        currentTargetDistance: Value(newDistance),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}

/// Riverpod プロバイダ
final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepository(ref.watch(appDatabaseProvider));
});
