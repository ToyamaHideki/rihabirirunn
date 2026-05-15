import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// T-2.1.6: OS 通知バーへの走行状態表示
///
/// - 走行開始時に常駐通知を表示
/// - GPS 更新ごとに距離・経過時間・ペースをリアルタイム更新
/// - 走行終了時に通知をキャンセル
class NotificationService {
  static const _channelId = 'running_status';
  static const _channelName = '走行中の通知';
  static const _notificationId = 1001;

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// プラグインを初期化する（走行開始時に自動呼び出し）
  Future<void> init() async {
    if (kIsWeb) return; // Web は通知非対応
    if (_initialized) return;

    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );
    _initialized = true;
  }

  /// 走行通知を表示・更新する
  ///
  /// 同一の [_notificationId] で上書きするため、
  /// 初回表示と以降の更新で同じメソッドを使用する。
  Future<void> showRunningNotification({
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;
    await init();

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'リハビリ走行中の距離・時間・ペースを表示します',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,       // スワイプで消せない常駐通知
      autoCancel: false,
      showWhen: false,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );

    await _plugin.show(
      _notificationId,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  /// 走行通知をキャンセルする（走行終了時に呼び出す）
  Future<void> cancelRunningNotification() async {
    if (kIsWeb || !_initialized) return;
    await _plugin.cancel(_notificationId);
  }
}

// ---- Riverpod プロバイダ ----

final notificationServiceProvider = Provider<NotificationService>(
  (_) => NotificationService(),
);
