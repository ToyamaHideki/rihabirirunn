/// アプリ全画面のルートパス定数
abstract class AppRoutes {
  // ---- オンボーディング ----
  static const splash = '/splash';
  static const disclaimer = '/disclaimer';
  static const setup = '/setup';
  static const design = '/design';

  // ---- メイン（シェル内タブ） ----
  static const home = '/home';
  static const history = '/history';
  static const statistics = '/statistics';
  static const settings = '/settings';

  // ---- 走行フロー（シェル外・フルスクリーン） ----
  static const routeSetting = '/route-setting';
  static const routePreview = '/route-preview';
  static const conditionPre = '/condition/pre';
  static const activeRun = '/active-run';
  static const runSummary = '/run-summary/:sessionId';
  static const conditionPost = '/condition/post';

  // ---- 履歴サブ画面 ----
  static const runDetail = '/history/:sessionId';

  // ---- 設定サブ画面 ----
  static const modeSettings = '/settings/mode';
  static const bodyInfo = '/settings/body-info';
  static const displaySettings = '/settings/display';
  static const dataManagement = '/settings/data';
  static const trackingSettings = '/settings/tracking';
  static const notificationSettings = '/settings/notifications';
  static const termsOfService = '/settings/terms';
  static const privacyPolicy = '/settings/privacy';
  static const appInfo = '/settings/app-info';

  /// runSummary の実際のパスを生成
  static String runSummaryPath(String sessionId) =>
      '/run-summary/$sessionId';

  /// runDetail の実際のパスを生成
  static String runDetailPath(String sessionId) =>
      '/history/$sessionId';
}
