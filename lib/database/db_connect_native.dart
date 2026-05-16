import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// iOS / Android / Desktop: drift_flutter の公式ヘルパーを使用
QueryExecutor openDriftDatabase() {
  return driftDatabase(name: 'rihabiri_run');
}
