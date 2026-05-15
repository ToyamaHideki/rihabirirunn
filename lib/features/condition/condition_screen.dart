import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/repositories/condition_log_repository.dart';
import '../../shared/repositories/user_profile_repository.dart';
import '../../shared/router/app_routes.dart';
import '../route_generation/route_preview_args.dart';

// ---------------------------------------------------------------------------
// 部位データ定義
// ---------------------------------------------------------------------------

enum _ShowIn { front, back, both }

class _BodyPartEntry {
  const _BodyPartEntry(this.code, this.label, this.showIn);
  final String code;
  final String label;
  final _ShowIn showIn;
}

const _bodyParts = [
  // 首・上半身
  _BodyPartEntry('neck', '首', _ShowIn.both),
  _BodyPartEntry('chest', '胸', _ShowIn.front),
  _BodyPartEntry('upper_back', '上背部', _ShowIn.back),
  _BodyPartEntry('lower_back', '腰', _ShowIn.both),
  // 肩・腕
  _BodyPartEntry('left_shoulder', '左肩', _ShowIn.both),
  _BodyPartEntry('right_shoulder', '右肩', _ShowIn.both),
  _BodyPartEntry('left_elbow', '左肘', _ShowIn.both),
  _BodyPartEntry('right_elbow', '右肘', _ShowIn.both),
  _BodyPartEntry('left_wrist', '左手首', _ShowIn.front),
  _BodyPartEntry('right_wrist', '右手首', _ShowIn.front),
  // 股関節
  _BodyPartEntry('left_hip', '左股関節', _ShowIn.both),
  _BodyPartEntry('right_hip', '右股関節', _ShowIn.both),
  // 膝・すね
  _BodyPartEntry('left_knee', '左膝', _ShowIn.front),
  _BodyPartEntry('right_knee', '右膝', _ShowIn.front),
  _BodyPartEntry('left_shin', '左すね', _ShowIn.front),
  _BodyPartEntry('right_shin', '右すね', _ShowIn.front),
  // ふくらはぎ・足首・足底
  _BodyPartEntry('left_calf', '左ふくらはぎ', _ShowIn.back),
  _BodyPartEntry('right_calf', '右ふくらはぎ', _ShowIn.back),
  _BodyPartEntry('left_ankle', '左足首', _ShowIn.both),
  _BodyPartEntry('right_ankle', '右足首', _ShowIn.both),
  _BodyPartEntry('left_sole', '左足底', _ShowIn.front),
  _BodyPartEntry('right_sole', '右足底', _ShowIn.front),
];

// ---------------------------------------------------------------------------
// S22 / S32: 体調入力画面
// ---------------------------------------------------------------------------

/// 走行前(S22)・走行後(S32)共通の体調入力画面
///
/// T-3.1.1: 痛みスコアスライダー（0-10、絵文字付き）
/// T-3.1.2: 部位選択タブ（前面 / 背面）
/// T-3.1.3: 部位タップで多重選択 UI
/// T-3.1.4: 自由記述メモ（最大 500 文字）
/// T-3.1.5: スキップ機能（スコア 0 で保存）
/// T-3.1.6: ConditionLog + PainArea DB 保存
class ConditionScreen extends ConsumerStatefulWidget {
  const ConditionScreen({required this.timing, super.key});

  /// 'before' (S22: 走行前) または 'after' (S32: 走行後)
  final String timing;

  @override
  ConsumerState<ConditionScreen> createState() => _ConditionScreenState();
}

class _ConditionScreenState extends ConsumerState<ConditionScreen>
    with SingleTickerProviderStateMixin {
  // ---- UI 状態 ----
  late final TabController _tabController;
  double _painScore = 0;
  final Set<String> _selectedParts = {};
  final _memoController = TextEditingController();
  bool _isSaving = false;

  // ---- GoRouter extra から取得 ----
  /// 走行前(before): ルートプレビュー引数をそのまま activeRun に渡す
  RoutePreviewArgs? _preArgs;

  /// 走行後(after): 走行セッション ID
  String? _postSessionId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // extra の型で前後を判別（初回のみ読む）
    if (_preArgs == null && _postSessionId == null) {
      final extra = GoRouterState.of(context).extra;
      if (widget.timing == 'before' && extra is RoutePreviewArgs) {
        _preArgs = extra;
      } else if (widget.timing == 'after' && extra is String) {
        _postSessionId = extra;
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // 絵文字・ラベル
  // ---------------------------------------------------------------------------

  String get _emoji {
    final s = _painScore.round();
    if (s == 0) return '😊';
    if (s <= 2) return '🙂';
    if (s <= 4) return '😐';
    if (s <= 6) return '😟';
    if (s <= 8) return '😣';
    return '😖';
  }

  String get _scoreLabel {
    final s = _painScore.round();
    if (s == 0) return '痛みなし';
    if (s <= 2) return '軽い痛み';
    if (s <= 4) return 'やや痛い';
    if (s <= 6) return '中程度の痛み';
    if (s <= 8) return 'かなり痛い';
    return '耐えられない痛み';
  }

  // ---------------------------------------------------------------------------
  // T-3.1.5: スキップ / T-3.1.6: 保存
  // ---------------------------------------------------------------------------

  Future<void> _save({bool skip = false}) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final profile =
          await ref.read(userProfileRepositoryProvider).getProfile();
      if (profile != null && mounted) {
        await ref.read(conditionLogRepositoryProvider).saveConditionLog(
              userId: profile.id,
              sessionId:
                  widget.timing == 'after' ? _postSessionId : null,
              timing: widget.timing,
              painScore: skip ? 0 : _painScore.round(),
              memo: skip ? null : _memoController.text,
              selectedBodyParts: skip ? {} : Set.of(_selectedParts),
            );
      }
    } catch (_) {
      // DB エラーは握りつぶしてナビゲーションを続行
    }

    if (!mounted) return;
    _navigate();
  }

  /// 保存後の遷移
  ///
  /// - 走行前: RoutePreviewArgs を extra で渡して ActiveRun へ
  /// - 走行後: ホームへ
  void _navigate() {
    if (widget.timing == 'before') {
      context.push(AppRoutes.activeRun, extra: _preArgs);
    } else {
      context.go(AppRoutes.home);
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final title =
        widget.timing == 'before' ? '走行前の体調' : '走行後の体調';
    final submitLabel =
        widget.timing == 'before' ? '走行を開始する' : '記録を保存する';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        // T-3.1.5: スキップボタン
        actions: [
          TextButton(
            onPressed: _isSaving ? null : () => _save(skip: true),
            child: const Text('スキップ'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- T-3.1.1: 痛みスコアスライダー ----
            _SectionTitle(text: '今の痛みは？'),
            const SizedBox(height: 12),
            _PainScoreSlider(
              value: _painScore,
              emoji: _emoji,
              scoreLabel: _scoreLabel,
              onChanged: (v) => setState(() => _painScore = v),
            ),
            const SizedBox(height: 28),

            // ---- T-3.1.2 / T-3.1.3: 部位選択タブ ----
            _SectionTitle(text: '痛みのある部位'),
            const SizedBox(height: 8),
            _BodyPartSelector(
              tabController: _tabController,
              selectedParts: _selectedParts,
              onToggle: (code) {
                setState(() {
                  if (_selectedParts.contains(code)) {
                    _selectedParts.remove(code);
                  } else {
                    _selectedParts.add(code);
                  }
                });
              },
            ),
            if (_selectedParts.isNotEmpty) ...[
              const SizedBox(height: 8),
              _SelectedPartsSummary(
                selectedParts: _selectedParts,
                colorScheme: colorScheme,
              ),
            ],
            const SizedBox(height: 28),

            // ---- T-3.1.4: メモ ----
            _SectionTitle(text: 'メモ（任意）'),
            const SizedBox(height: 8),
            TextField(
              controller: _memoController,
              maxLength: 500,
              maxLines: 3,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                hintText: '気になることがあれば記入してください',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 32),

            // ---- 次へ / 保存ボタン ----
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : () => _save(),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(submitLabel),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// T-3.1.1: 痛みスコアスライダー
// ---------------------------------------------------------------------------

class _PainScoreSlider extends StatelessWidget {
  const _PainScoreSlider({
    required this.value,
    required this.emoji,
    required this.scoreLabel,
    required this.onChanged,
  });

  final double value;
  final String emoji;
  final String scoreLabel;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final score = value.round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 52)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$score / 10',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(scoreLabel, style: textTheme.bodyMedium),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('0', style: TextStyle(fontSize: 12)),
              Expanded(
                child: Slider(
                  value: value,
                  min: 0,
                  max: 10,
                  divisions: 10,
                  label: '$score',
                  onChanged: onChanged,
                ),
              ),
              const Text('10', style: TextStyle(fontSize: 12)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('無痛',
                  style: Theme.of(context).textTheme.bodySmall),
              Text('最大の痛み',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// T-3.1.2 / T-3.1.3: 部位選択タブ
// ---------------------------------------------------------------------------

class _BodyPartSelector extends StatelessWidget {
  const _BodyPartSelector({
    required this.tabController,
    required this.selectedParts,
    required this.onToggle,
  });

  final TabController tabController;
  final Set<String> selectedParts;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final frontParts = _bodyParts
        .where((p) =>
            p.showIn == _ShowIn.front || p.showIn == _ShowIn.both)
        .toList();
    final backParts = _bodyParts
        .where((p) =>
            p.showIn == _ShowIn.back || p.showIn == _ShowIn.both)
        .toList();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // タブバー
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            child: TabBar(
              controller: tabController,
              tabs: const [
                Tab(text: '前面'),
                Tab(text: '背面'),
              ],
            ),
          ),
          // タブビュー（固定高さ）
          SizedBox(
            height: 220,
            child: TabBarView(
              controller: tabController,
              children: [
                _PartGrid(
                  parts: frontParts,
                  selectedParts: selectedParts,
                  onToggle: onToggle,
                ),
                _PartGrid(
                  parts: backParts,
                  selectedParts: selectedParts,
                  onToggle: onToggle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PartGrid extends StatelessWidget {
  const _PartGrid({
    required this.parts,
    required this.selectedParts,
    required this.onToggle,
  });

  final List<_BodyPartEntry> parts;
  final Set<String> selectedParts;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: parts.map((part) {
          final isSelected = selectedParts.contains(part.code);
          return FilterChip(
            label: Text(part.label),
            selected: isSelected,
            onSelected: (_) => onToggle(part.code),
            showCheckmark: true,
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 選択部位まとめ表示
// ---------------------------------------------------------------------------

class _SelectedPartsSummary extends StatelessWidget {
  const _SelectedPartsSummary({
    required this.selectedParts,
    required this.colorScheme,
  });

  final Set<String> selectedParts;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    // code → label のマップ
    final labelMap = {for (final p in _bodyParts) p.code: p.label};
    final labels =
        selectedParts.map((c) => labelMap[c] ?? c).toList()..sort();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.location_on_rounded,
            size: 16, color: colorScheme.primary),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '選択中: ${labels.join('、')}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 共通: セクションタイトル
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}
