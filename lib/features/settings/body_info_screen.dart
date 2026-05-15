import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../database/database.dart';
import '../../shared/repositories/user_profile_repository.dart';
import '../../shared/widgets/primary_button.dart';

// ---------------------------------------------------------------------------
// S52: 身体情報編集画面
// ---------------------------------------------------------------------------

/// T-4.1.3: 身体情報編集画面
///
/// 年齢・リハビリ目標（自由記述）・最終目標距離を編集し DB を更新する。
/// SetupScreen と同じフィールド構成。
class BodyInfoScreen extends ConsumerStatefulWidget {
  const BodyInfoScreen({super.key});

  @override
  ConsumerState<BodyInfoScreen> createState() => _BodyInfoScreenState();
}

class _BodyInfoScreenState extends ConsumerState<BodyInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _rehabTargetController = TextEditingController();

  /// 最終目標距離（km 単位スライダー、1.0〜21.0km）
  double _finalGoalKm = 3.0;

  UserProfile? _profile;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ageController.dispose();
    _rehabTargetController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final profile =
        await ref.read(userProfileRepositoryProvider).getProfile();
    if (mounted) {
      setState(() {
        _profile = profile;
        if (profile != null) {
          _ageController.text = profile.age?.toString() ?? '';
          _rehabTargetController.text = profile.rehabTarget ?? '';
          _finalGoalKm =
              ((profile.finalGoalDistance ?? 3000.0) / 1000.0).clamp(
                  1.0, 21.0);
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving || _profile == null) return;
    setState(() => _isSaving = true);

    try {
      final ageText = _ageController.text.trim();
      final age = ageText.isNotEmpty ? int.tryParse(ageText) : null;
      final rehabTarget = _rehabTargetController.text.trim();

      await ref.read(userProfileRepositoryProvider).updateProfile(
            _profile!.id,
            age: age,
            rehabTarget: rehabTarget.isNotEmpty ? rehabTarget : null,
            finalGoalDistance: _finalGoalKm * 1000,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('身体情報を保存しました')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存に失敗しました。もう一度お試しください')),
      );
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
        appBar: AppBar(title: const Text('身体情報')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('身体情報'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ---- 年齢 ----
                    Text('年齢（任意）', style: textTheme.labelLarge),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      decoration: InputDecoration(
                        hintText: '例：55',
                        suffixText: '歳',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final n = int.tryParse(v.trim());
                        if (n == null || n < 1 || n > 120) {
                          return '1〜120 の整数を入力してください';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // ---- リハビリ目標・部位 ----
                    Text('リハビリ目標・対象部位（任意）', style: textTheme.labelLarge),
                    const SizedBox(height: 4),
                    Text(
                      'ホーム画面の目標カードに表示されます',
                      style: textTheme.bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _rehabTargetController,
                      maxLength: 100,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: '例：右膝 術後リハビリ中、1km 歩けるようになる',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ---- 最終目標距離 ----
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('最終目標距離', style: textTheme.labelLarge),
                        Text(
                          _finalGoalKm < 1.0
                              ? '${(_finalGoalKm * 1000).round()} m'
                              : '${_finalGoalKm.toStringAsFixed(1)} km',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '最終的に目指したい距離を設定してください',
                      style: textTheme.bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    Slider(
                      value: _finalGoalKm,
                      min: 1.0,
                      max: 21.0,
                      divisions: 200,
                      onChanged: (v) {
                        // 100m 刻みで丸める
                        final rounded =
                            (v * 10).round() / 10.0; // 0.1km単位
                        setState(() => _finalGoalKm = rounded);
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('1.0 km',
                            style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant)),
                        Text('21.0 km',
                            style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: PrimaryButton(
              label: '保存する',
              onPressed: _isSaving ? null : _save,
            ),
          ),
        ],
      ),
    );
  }
}
