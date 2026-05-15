/// ネイティブ (iOS / Android) 向け Drift 接続
///
/// database.dart の条件付きインポートから使用される。
/// Web 環境では connection_web.dart が代わりにインポートされる。
library;

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// SQLite ファイルを documents ディレクトリに作成して返す
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'rihabiri_run.db'));
    return NativeDatabase.createInBackground(file);
  });
}
