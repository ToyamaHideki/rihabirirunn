import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database.dart';
import '../../shared/repositories/user_profile_repository.dart';
import '../../shared/repositories/user_settings_repository.dart';

// ---------------------------------------------------------------------------
// S56: 計測設定画面（GPS / Map Matching 設定）
// ---------------------------------------------------------------------------

/// T-2.5: 計測設定
///
/// - GPS 軌跡を Mapbox Map Matching API で道路にスナップするかのトグル
/// - 走行終了時に即時補正する方式（リアルタイム補正ではない）
class TrackingSettingsScreen extends ConsumerStatefulWidget {
  const TrackingSettingsScreen({super.key});

  @override
  ConsumerState<TrackingSettingsScreen> createState() =>
      _TrackingSettingsScreenState();
}

class _TrackingSettingsScreenState
    extends ConsumerState<TrackingSettingsScreen> {
  String? _profileId;
  UserSetting? _currentSettings;
  bool _gpsCorrectionEnabled = true;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile =
        await ref.read(userProfileRepositoryProvider).getProfile();
    if (profile == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    final settings = await ref
        .read(userSettingsRepositoryProvider)
        .getByUserId(profile.id);
    if (mounted) {
      setState(() {
        _profileId = profile.id;
        _currentSettings = settings;
        _gpsCorrectionEnabled = settings?.gpsCorrectionEnabled ?? true;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggle(bool value) async {
    if (_isSaving) return;
    setState(() {
      _gpsCorrectionEnabled = value;
      _isSaving = true;
    });
    try {
      final repo = ref.read(userSettingsRepositoryProvider);
      if (_currentSettings != null) {
        await repo.updateSettings(
          _currentSettings!.id,
          gpsCorrectionEnabled: value,
        );
      } else if (_profileId != null) {
        // 設定レコードがまだ存在しない場合は作成
        await repo.createSettings(userId: _profileId!);
        final created = await repo.getByUserId(_profileId!);
        if (created != null) {
          await repo.updateSettings(
            created.id,
            gpsCorrectionEnabled: value,
          );
          if (mounted) {
            setState(() => _currentSettings = created);
          }
        }
      }
    } catch (_) {
      // 失敗時はトグルを戻す
      if (mounted) {
        setState(() => _gpsCorrectionEnabled = !value);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('設定の保存に失敗しました')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('計測設定')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('計測設定'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ---- GPS 補正トグル ----
          SwitchListTile(
            value: _gpsCorrectionEnabled,
            onChanged: _isSaving ? null : _toggle,
            secondary: Icon(
              Icons.alt_route_rounded,
              color: colorScheme.primary,
            ),
            title: const Text('GPS 軌跡を道路に補正'),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '走行終了時に GPS 軌跡を地図上の道に合わせて補正します。'
                '線が道から外れて見える問題を抑えます。',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const Divider(indent: 16, endIndent: 16, height: 24),
          // ---- 説明 ----
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '補正について',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '・補正は Mapbox Map Matching API を使用して走行終了時に一括で行われます。\n'
                  '・通信状況により数秒の処理時間が発生する場合があります。\n'
                  '・補正に失敗した場合は元の GPS データがそのまま保存されます。\n'
                  '・道路ネットワークが整備されていない場所では補正の精度が落ちることがあります。',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.6,
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
