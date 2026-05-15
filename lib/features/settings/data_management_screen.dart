import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/services/data_export_service.dart';
import '../../shared/services/data_import_service.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/primary_button.dart';

// ---------------------------------------------------------------------------
// S54: データ管理画面
// ---------------------------------------------------------------------------

/// T-4.2: データエクスポート／インポート画面
///
/// - エクスポート: 全データを JSON ファイルに書き出し OS 共有シートで配信
/// - インポート: JSON ファイルを選択し、マージまたは上書きで DB に復元
class DataManagementScreen extends ConsumerStatefulWidget {
  const DataManagementScreen({super.key});

  @override
  ConsumerState<DataManagementScreen> createState() =>
      _DataManagementScreenState();
}

class _DataManagementScreenState
    extends ConsumerState<DataManagementScreen> {
  bool _exporting = false;
  bool _importing = false;

  // ---------------------------------------------------------------------------
  // Export
  // ---------------------------------------------------------------------------

  Future<void> _onExport() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      await ref.read(dataExportServiceProvider).exportAndShare();
    } catch (e) {
      if (!mounted) return;
      _showError('エクスポートに失敗しました: $e');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Import
  // ---------------------------------------------------------------------------

  Future<void> _onImport() async {
    if (_importing) return;

    // ファイル選択
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    setState(() => _importing = true);
    try {
      final file = result.files.first;
      // withData: true により全プラットフォーム（Web 含む）で bytes が取得できる
      final bytes = file.bytes;
      if (bytes == null) throw Exception('ファイルを読み込めませんでした');
      final String content = utf8.decode(bytes);

      // パース・バリデーション
      final summary =
          ref.read(dataImportServiceProvider).parseAndValidate(content);

      if (!mounted) return;

      // サマリ確認 + マージ/上書き選択ダイアログ
      final overwrite = await _showImportConfirmDialog(summary);
      if (overwrite == null) return; // キャンセル

      // インポート実行
      final importResult = await ref
          .read(dataImportServiceProvider)
          .importData(summary.rawData, overwrite: overwrite);

      if (!mounted) return;
      _showImportResult(importResult);
    } on FormatException catch (e) {
      if (mounted) _showError(e.message);
    } catch (e) {
      if (mounted) _showError('インポートに失敗しました: $e');
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Dialogs
  // ---------------------------------------------------------------------------

  /// マージ or 上書き を選択させる。null = キャンセル
  Future<bool?> _showImportConfirmDialog(ImportSummary summary) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('データをインポート'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('バックアップから ${summary.sessionCount} 件の走行記録が見つかりました。'),
            const SizedBox(height: 8),
            Text(
              '作成日: ${_fmtDate(summary.exportedAt)}',
              style: Theme.of(ctx)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(ctx).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            const Text('インポート方法を選んでください。'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('マージ'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('上書き'),
          ),
        ],
      ),
    );
  }

  void _showImportResult(ImportResult result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'インポート完了: ${result.importedSessions} 件追加'
          '${result.skippedSessions > 0 ? '、${result.skippedSessions} 件スキップ' : ''}',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  String _fmtDate(DateTime dt) {
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('データ管理'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // ---- エクスポート ----
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.upload_rounded,
                          color: colorScheme.primary, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'データをエクスポート',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '走行記録・体調ログ・設定をまとめて JSON ファイルに書き出します。'
                    '\n機種変更の引き継ぎやバックアップにご利用ください。',
                    style: textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    icon: _exporting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.ios_share_rounded),
                    label: 'エクスポートする',
                    onPressed: _exporting ? null : _onExport,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ---- インポート ----
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.download_rounded,
                          color: colorScheme.secondary, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'データをインポート',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'バックアップ JSON ファイルを選択して、走行記録を復元します。'
                    '\n「マージ」は既存データを保持、「上書き」は全データを置き換えます。',
                    style: textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    icon: _importing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.folder_open_rounded, size: 18),
                    label: const Text('ファイルを選んでインポート'),
                    onPressed: _importing ? null : _onImport,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ---- 注意事項 ----
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: colorScheme.error, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'インポートの「上書き」を選択すると、現在のデータはすべて削除されます。'
                    '\n重要なデータは先にエクスポートしておいてください。',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
