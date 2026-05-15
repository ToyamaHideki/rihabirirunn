import 'dart:async';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'location_service.dart';
import 'notification_service.dart';
import 'run_snapshot_service.dart';

// ---------------------------------------------------------------------------
// 走行状態モデル
// ---------------------------------------------------------------------------

/// 走行の進行状態
enum TrackingStatus { idle, tracking, paused, stopped }

/// 走行状態（イミュータブル）
///
/// UI 層はこのクラスをウォッチして走行データを表示する。
class TrackingState {
  const TrackingState({
    this.status = TrackingStatus.idle,
    this.positions = const [],
    this.distanceMeters = 0.0,
    this.elapsedSeconds = 0,
    this.paceSecPerKm = 0,
    this.gpsLost = false,
  });

  /// 走行ステータス
  final TrackingStatus status;

  /// 実績 GPS 座標列（走行軌跡描画・DB 保存に使用）
  final List<LatLng> positions;

  /// 累積距離（m）- T-2.1.3
  final double distanceMeters;

  /// 経過時間（秒）
  final int elapsedSeconds;

  /// 平均ペース（秒/km）- T-2.1.4
  final int paceSecPerKm;

  /// T-2.3.3: GPS 信号ロスト中か（10 秒以上更新なし）
  final bool gpsLost;

  // ---- 便利ゲッター ----

  bool get isTracking => status == TrackingStatus.tracking;
  bool get isPaused => status == TrackingStatus.paused;
  bool get isStopped => status == TrackingStatus.stopped;
  bool get isActive => isTracking || isPaused;

  double get distanceKm => distanceMeters / 1000.0;

  /// 距離の表示文字列（例: "950m" / "1.23km"）
  String get formattedDistance {
    if (distanceMeters < 1000) return '${distanceMeters.round()}m';
    return '${distanceKm.toStringAsFixed(2)}km';
  }

  /// 経過時間の表示文字列（例: "05:30" / "1:02:15"）
  String get formattedElapsed {
    final h = elapsedSeconds ~/ 3600;
    final m = (elapsedSeconds % 3600) ~/ 60;
    final s = elapsedSeconds % 60;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// ペースの表示文字列（例: "6'30\"" / "--'--"）
  String get formattedPace {
    if (paceSecPerKm <= 0) return "--'--\"";
    final m = paceSecPerKm ~/ 60;
    final s = paceSecPerKm % 60;
    return "$m'${s.toString().padLeft(2, '0')}\"";
  }

  TrackingState copyWith({
    TrackingStatus? status,
    List<LatLng>? positions,
    double? distanceMeters,
    int? elapsedSeconds,
    int? paceSecPerKm,
    bool? gpsLost,
  }) =>
      TrackingState(
        status: status ?? this.status,
        positions: positions ?? this.positions,
        distanceMeters: distanceMeters ?? this.distanceMeters,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
        paceSecPerKm: paceSecPerKm ?? this.paceSecPerKm,
        gpsLost: gpsLost ?? this.gpsLost,
      );
}

// ---------------------------------------------------------------------------
// T-2.1: GPS 追跡サービス（StateNotifier）
// ---------------------------------------------------------------------------

/// GPS 追跡を管理する StateNotifier
///
/// T-2.1.1: geolocator 位置情報ストリーム（5m 毎に更新）
/// T-2.1.2: GPS 精度フィルタ（20m 超は除外）
/// T-2.1.3: Haversine 公式による累積距離計算
/// T-2.1.4: 平均ペース算出
/// T-2.1.5: バックグラウンド追跡（Android フォアグラウンドサービス / iOS Background Modes）
/// T-2.1.6: OS 通知バーへ距離・時間・ペースをリアルタイム表示
/// T-2.3.1: 30 秒ごとにスナップショット保存（強制終了対策）
/// T-2.3.3: GPS ロスト検出（10 秒以上更新なし）
class TrackingNotifier extends StateNotifier<TrackingState> {
  TrackingNotifier(
    this._locationService,
    this._notificationService,
    this._snapshotService,
  ) : super(const TrackingState());

  final LocationService _locationService;
  final NotificationService _notificationService;
  final RunSnapshotService _snapshotService;

  StreamSubscription<Position>? _positionSub;
  Timer? _timer;

  // T-2.3.3: GPS ロスト検出用
  DateTime? _lastPositionTime;

  // T-2.3.1: スナップショット保存カウンター（1 カウント = 1 秒）
  int _snapshotTickCounter = 0;
  static const _snapshotIntervalSec = 30;

  // ---- 公開 API ----

  /// 走行を開始する（または一時停止から再開する）
  Future<void> start() async {
    if (state.isTracking) return;

    if (state.isPaused) {
      _resumeInternal();
      return;
    }

    // 権限チェック
    final permission = await _locationService.checkAndRequestPermission();
    if (!_locationService.isPermissionGranted(permission)) return;

    // 状態リセットして開始
    state = const TrackingState(status: TrackingStatus.tracking);
    _lastPositionTime = null;
    _snapshotTickCounter = 0;
    _subscribePositions();
    _startTimer();
    _pushNotification();
  }

  /// 一時停止
  void pause() {
    if (!state.isTracking) return;
    _positionSub?.pause();
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(status: TrackingStatus.paused);
    _pushNotification();
  }

  /// 再開（pause → tracking）
  void resume() {
    if (!state.isPaused) return;
    _resumeInternal();
  }

  /// 走行終了 — 最終の TrackingState を返す（DB 保存用）
  Future<TrackingState> stop() async {
    _positionSub?.cancel();
    _timer?.cancel();
    _positionSub = null;
    _timer = null;
    _lastPositionTime = null;

    final finalState = state.copyWith(status: TrackingStatus.stopped);
    state = finalState;
    await _notificationService.cancelRunningNotification();
    // T-2.3.1: 正常終了時はスナップショットを削除
    await _snapshotService.clear();
    return finalState;
  }

  // ---- 内部処理 ----

  void _resumeInternal() {
    _positionSub?.resume();
    _startTimer();
    state = state.copyWith(status: TrackingStatus.tracking);
    _pushNotification();
  }

  /// T-2.1.1 / T-2.1.5: GPS ストリームを開始する
  void _subscribePositions() {
    _positionSub?.cancel();
    _positionSub = Geolocator.getPositionStream(
      locationSettings: _buildLocationSettings(),
    ).listen(_onPosition, onError: (_) {});
  }

  /// T-2.1.5: プラットフォーム別 LocationSettings
  LocationSettings _buildLocationSettings() {
    // Web はフォアグラウンドのみ対応（ブラウザ Geolocation API）
    if (kIsWeb) {
      return const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      );
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // T-2.1.1: 5m 移動ごとに更新
        // フォアグラウンドサービスで画面オフでも GPS 継続
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'リハビリウォーク',
          notificationText: '走行中です',
          enableWakeLock: true,
          setOngoing: true,
        ),
      );
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // T-2.1.1
        activityType: ActivityType.fitness,
        pauseLocationUpdatesAutomatically: false,
        // バックグラウンドロケーションインジケーターを表示
        showBackgroundLocationIndicator: true,
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );
  }

  /// T-2.1.1 / T-2.1.2 / T-2.1.3 / T-2.1.4 / T-2.3.3: GPS ポジション受信
  void _onPosition(Position pos) {
    if (!state.isTracking) return;

    // T-2.1.2: 精度フィルタ（20m 超は除外）
    if (pos.accuracy > 20) return;

    // T-2.3.3: 最終受信時刻を更新、GPS ロストから回復
    _lastPositionTime = DateTime.now();
    final wasGpsLost = state.gpsLost;

    final newPoint = LatLng(pos.latitude, pos.longitude);
    final newPositions = List<LatLng>.from(state.positions)..add(newPoint);

    // T-2.1.3: Haversine 累積距離
    double added = 0;
    if (newPositions.length >= 2) {
      added = _haversine(
        newPositions[newPositions.length - 2],
        newPoint,
      );
    }
    final newDist = state.distanceMeters + added;

    // T-2.1.4: 平均ペース（100m 以上進んでから算出）
    final pace = newDist >= 100 && state.elapsedSeconds > 0
        ? (state.elapsedSeconds / (newDist / 1000)).round()
        : state.paceSecPerKm;

    if (!mounted) return;
    state = state.copyWith(
      positions: newPositions,
      distanceMeters: newDist,
      paceSecPerKm: pace,
      // T-2.3.3: GPS 回復
      gpsLost: wasGpsLost ? false : state.gpsLost,
    );

    // T-2.1.6: GPS 更新ごとに通知を更新
    _pushNotification();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (!state.isTracking) return;

      // 経過時間を 1 秒進める
      final newElapsed = state.elapsedSeconds + 1;

      // T-2.3.3: GPS ロスト検出（最後の位置更新から 10 秒以上経過）
      bool newGpsLost = state.gpsLost;
      final lastPos = _lastPositionTime;
      if (lastPos != null) {
        newGpsLost =
            DateTime.now().difference(lastPos).inSeconds > 10;
      }

      state = state.copyWith(
        elapsedSeconds: newElapsed,
        gpsLost: newGpsLost,
      );

      // T-2.3.1: 30 秒ごとにスナップショット保存
      _snapshotTickCounter++;
      if (_snapshotTickCounter >= _snapshotIntervalSec) {
        _snapshotTickCounter = 0;
        _snapshotService.save(
          elapsedSeconds: state.elapsedSeconds,
          distanceMeters: state.distanceMeters,
          paceSecPerKm: state.paceSecPerKm,
        );
      }
    });
  }

  /// T-2.1.6: 通知バー更新（fire-and-forget）
  void _pushNotification() {
    if (!state.isActive) return;
    final statusLabel = state.isPaused ? '一時停止中' : '走行中';
    _notificationService.showRunningNotification(
      title: 'リハビリウォーク  $statusLabel',
      body:
          '${state.formattedDistance}  ／  ${state.formattedElapsed}'
          '  ｜  ペース ${state.formattedPace}',
    );
  }

  // ---- Haversine 距離計算 ----

  /// 2点間の距離をメートルで返す（Haversine 公式）
  static double _haversine(LatLng p1, LatLng p2) {
    const r = 6371000.0; // 地球半径（m）
    final lat1 = p1.latitudeInRad;
    final lat2 = p2.latitudeInRad;
    final dLat = lat2 - lat1;
    final dLng = p2.longitudeInRad - p1.longitudeInRad;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) *
            math.sin(dLng / 2) * math.sin(dLng / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _timer?.cancel();
    super.dispose();
  }
}

// ---- Riverpod プロバイダ ----

final trackingNotifierProvider =
    StateNotifierProvider<TrackingNotifier, TrackingState>((ref) {
  return TrackingNotifier(
    ref.watch(locationServiceProvider),
    ref.watch(notificationServiceProvider),
    ref.watch(runSnapshotServiceProvider),
  );
});
