/// プラットフォーム別 DB 接続の条件付きエクスポート
///
/// Web  → db_connect_web.dart  (WebDatabase + sql.js)
/// 他   → db_connect_native.dart (drift_flutter の driftDatabase)
export 'db_connect_native.dart' if (dart.library.html) 'db_connect_web.dart';
