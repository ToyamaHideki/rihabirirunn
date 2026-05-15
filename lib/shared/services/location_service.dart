import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// 位置情報サービス（T-1.1.2）
///
/// - 権限チェック・リクエスト
/// - 現在地の一発取得
/// - リアルタイムストリーム（走行中追跡用）
class LocationService {
  /// 位置情報権限を確認し、必要なら要求する
  Future<LocationPermission> checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermission.denied;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  /// 権限が有効かどうかを返す
  bool isPermissionGranted(LocationPermission permission) {
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// 現在地を一発取得（地図センタリング用）
  Future<Position?> getCurrentPosition() async {
    try {
      final permission = await checkAndRequestPermission();
      if (!isPermissionGranted(permission)) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  /// リアルタイム位置ストリーム（走行中追跡用）
  /// [distanceFilterMeters]: 最小更新距離（m）。走行中は5m推奨
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilterMeters = 5,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilterMeters,
      ),
    );
  }
}

// ---- Riverpod プロバイダ ----

final locationServiceProvider = Provider<LocationService>(
  (_) => LocationService(),
);

/// 現在地の一発取得プロバイダ（地図の初期センタリング用）
final currentPositionProvider = FutureProvider<Position?>((ref) async {
  return ref.watch(locationServiceProvider).getCurrentPosition();
});

/// 位置情報権限状態プロバイダ
final locationPermissionProvider =
    FutureProvider<LocationPermission>((ref) async {
  return ref.watch(locationServiceProvider).checkAndRequestPermission();
});
