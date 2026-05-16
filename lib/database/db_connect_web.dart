// ignore_for_file: deprecated_member_use
import 'package:drift/drift.dart';
import 'package:drift/web.dart';

/// Web: WebDatabase + sql.js CDN を使用
///
/// WasmDatabase (drift_flutter のデフォルト) は GitHub Pages では
/// drift_worker.js が必要なため動作しない。
/// WebDatabase は sql.js (index.html でロード) を利用した旧実装だが
/// GitHub Pages で追加設定なしに動作し、IndexedDB にデータを永続化する。
QueryExecutor openDriftDatabase() {
  return WebDatabase('rihabiri_run', logStatements: false);
}
