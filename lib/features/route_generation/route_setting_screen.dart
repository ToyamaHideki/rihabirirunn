import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../database/database.dart';
import '../../shared/models/route_result.dart';
import '../../shared/repositories/saved_route_repository.dart';
import '../../shared/repositories/user_profile_repository.dart';
import '../../shared/router/app_routes.dart';
import '../../shared/services/directions_service.dart';
import '../../shared/services/location_service.dart';
import '../../shared/services/route_generator.dart';
import '../../shared/widgets/app_map.dart';
import '../../shared/widgets/primary_button.dart';
import 'route_preview_args.dart';

// ピンドロップのモード
enum _PinMode { none, departure, destination }

/// S20: ルート設定画面
///
/// T-1.3.1: 距離スライダー（100m〜21km、100m刻み）
/// T-1.3.2: ルート形状選択（周回 / 片道）
/// T-1.3.3: 出発地選択（現在地 / 地図ピン）
/// T-1.3.4: 目的地選択（片道用、地図ピン）
class RouteSettingScreen extends ConsumerStatefulWidget {
  const RouteSettingScreen({super.key});

  @override
  ConsumerState<RouteSettingScreen> createState() =>
      _RouteSettingScreenState();
}

class _RouteSettingScreenState extends ConsumerState<RouteSettingScreen> {
  // ---- 状態 ----
  double _distanceM = 1000.0; // デフォルト 1 km（プロフィール読込前のフォールバック）
  RouteType _routeType = RouteType.circular;
  LatLng? _departure; // null = GPS 現在地を使用
  LatLng? _destination; // 片道用・任意
  _PinMode _pinMode = _PinMode.none;
  bool _isGenerating = false;
  String? _error;

  // ---- 初期データ ----
  String? _userId; // 保存ルート紐付け用
  bool _hasSavedRoutes = false; // 「保存済みルート」ボタン表示制御

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  /// プロフィールから「今日の目標距離」を初期値に設定し、保存ルートの有無を確認
  Future<void> _loadInitialData() async {
    final profile =
        await ref.read(userProfileRepositoryProvider).getProfile();
    if (!mounted) return;
    if (profile == null) return;
    final mostRecent = await ref
        .read(savedRouteRepositoryProvider)
        .getMostRecent(profile.id);
    if (!mounted) return;
    setState(() {
      _userId = profile.id;
      _distanceM = profile.currentTargetDistance.clamp(100.0, 21000.0);
      _hasSavedRoutes = mostRecent != null;
    });
  }

  // ---- 距離フォーマット ----
  String get _distanceLabel {
    if (_distanceM < 1000) return '${_distanceM.toInt()} m';
    final km = _distanceM / 1000;
    return km == km.truncateToDouble()
        ? '${km.toInt()} km'
        : '${km.toStringAsFixed(1)} km';
  }

  // ---- 地図タップ処理（ピンドロップ）----
  void _onMapTap(LatLng point) {
    if (_pinMode == _PinMode.departure) {
      setState(() {
        _departure = point;
        _pinMode = _PinMode.none;
      });
    } else if (_pinMode == _PinMode.destination) {
      setState(() {
        _destination = point;
        _pinMode = _PinMode.none;
      });
    }
  }

  // ---- ルート生成 ----
  Future<void> _generate() async {
    setState(() {
      _isGenerating = true;
      _error = null;
    });

    // 出発地を解決（カスタム or GPS 現在地）
    LatLng? departure = _departure;
    if (departure == null) {
      final pos = ref.read(currentPositionProvider).valueOrNull;
      if (pos == null) {
        setState(() {
          _isGenerating = false;
          _error = '現在地が取得できません。GPS をオンにして再試行してください。';
        });
        return;
      }
      departure = LatLng(pos.latitude, pos.longitude);
    }

    final generator = ref.read(routeGeneratorProvider);
    final bearingOffset = math.Random().nextDouble() * 360;

    RouteGenerationResult result;

    if (_routeType == RouteType.circular) {
      result = await generator.generateCircularRoute(
        start: departure,
        targetDistanceMeters: _distanceM,
        bearingOffsetDeg: bearingOffset,
      );
    } else if (_destination != null) {
      // 片道 + 明示的な目的地 → 直接ルーティング
      try {
        final route = await ref.read(directionsServiceProvider).getRoute(
          [departure, _destination!],
          routeType: RouteType.oneWay,
        );
        result = RouteSuccess(route);
      } on RouteApiException catch (e) {
        result = RouteFailure(errorType: e.type, message: e.message);
      }
    } else {
      result = await generator.generateOneWayRoute(
        start: departure,
        targetDistanceMeters: _distanceM,
        bearingDeg: bearingOffset,
      );
    }

    if (!mounted) return;
    setState(() => _isGenerating = false);

    switch (result) {
      case RouteSuccess(:final route):
        // ③ 生成成功時に保存ルートへ自動追加（失敗しても画面遷移は継続）
        if (_userId != null) {
          try {
            await ref.read(savedRouteRepositoryProvider).saveRoute(
                  userId: _userId!,
                  route: route,
                  targetDistanceMeters: _distanceM,
                  departure: departure,
                  destination: _destination,
                );
          } catch (_) {
            // 保存失敗はサイレント（生成自体は成功している）
          }
        }
        if (!mounted) return;
        context.push(
          AppRoutes.routePreview,
          extra: RoutePreviewArgs(
            routeResult: route,
            distanceMeters: _distanceM,
            routeType: _routeType,
            departure: departure,
            destination: _destination,
          ),
        );
      case RouteFailure():
        setState(() => _error = (result as RouteFailure).userMessage);
    }
  }

  // ---- ③ 保存済みルートから選択 ----

  Future<void> _openSavedRoutesSheet() async {
    final userId = _userId;
    if (userId == null) return;
    final routes = await ref
        .read(savedRouteRepositoryProvider)
        .listRecent(userId, limit: 20);
    if (!mounted) return;
    if (routes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存済みのルートはありません')),
      );
      return;
    }
    final selected = await showModalBottomSheet<SavedRoute>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _SavedRoutesSheet(routes: routes),
    );
    if (selected != null && mounted) {
      _useSavedRoute(selected);
    }
  }

  /// 保存ルートを選択 → プレビュー画面へ
  void _useSavedRoute(SavedRoute saved) {
    final routeResult = SavedRouteRepository.toRouteResult(saved);
    final departure = LatLng(saved.departureLat, saved.departureLng);
    final destination =
        (saved.destinationLat != null && saved.destinationLng != null)
            ? LatLng(saved.destinationLat!, saved.destinationLng!)
            : null;

    // 最終使用日時を更新（並列で fire-and-forget）
    ref.read(savedRouteRepositoryProvider).markUsed(saved.id);

    context.push(
      AppRoutes.routePreview,
      extra: RoutePreviewArgs(
        routeResult: routeResult,
        distanceMeters: saved.targetDistanceM,
        routeType: routeResult.routeType,
        departure: departure,
        destination: destination,
      ),
    );
  }

  // ---- ビルド ----
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // カスタムピンのマーカーレイヤー
    final pinMarkers = <Marker>[
      if (_departure != null)
        Marker(
          point: _departure!,
          width: 36,
          height: 36,
          child: _PinMarker(
            color: Colors.green.shade600,
            label: '出',
          ),
        ),
      if (_destination != null)
        Marker(
          point: _destination!,
          width: 36,
          height: 36,
          child: _PinMarker(
            color: Colors.red.shade600,
            label: '着',
          ),
        ),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.88),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text('ルートを設定', style: textTheme.titleMedium),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // ---- 地図 + 設定パネルの縦分割 ----
          Column(
            children: [
              // 地図エリア（55%）
              Expanded(
                flex: 55,
                child: AppMap(
                  initialZoom: 15.5,
                  showCurrentLocation: true,
                  centerOnLocationUpdate: _departure == null,
                  onTap: _pinMode != _PinMode.none ? _onMapTap : null,
                  layers: pinMarkers.isNotEmpty
                      ? [MarkerLayer(markers: pinMarkers)]
                      : [],
                ),
              ),

              // 設定パネル（45%）
              Expanded(
                flex: 45,
                child: _SettingPanel(
                  distanceM: _distanceM,
                  distanceLabel: _distanceLabel,
                  routeType: _routeType,
                  departure: _departure,
                  destination: _destination,
                  pinMode: _pinMode,
                  isGenerating: _isGenerating,
                  error: _error,
                  hasSavedRoutes: _hasSavedRoutes,
                  remainingRequests:
                      ref.watch(remainingRouteRequestsProvider),
                  onDistanceChanged: (v) => setState(
                      () => _distanceM = (v / 100).round() * 100.0),
                  onRouteTypeChanged: (t) =>
                      setState(() => _routeType = t),
                  onSetDeparturePin: () =>
                      setState(() => _pinMode = _PinMode.departure),
                  onClearDeparture: () =>
                      setState(() => _departure = null),
                  onSetDestinationPin: () =>
                      setState(() => _pinMode = _PinMode.destination),
                  onClearDestination: () =>
                      setState(() => _destination = null),
                  onOpenSavedRoutes: _openSavedRoutesSheet,
                  onGenerate: _isGenerating ? null : _generate,
                ),
              ),
            ],
          ),

          // ---- ピンドロップモード時のバナー ----
          if (_pinMode != _PinMode.none)
            Positioned(
              top: kToolbarHeight + MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                color: colorScheme.inverseSurface,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Icon(Icons.touch_app_rounded,
                          color: colorScheme.onInverseSurface, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _pinMode == _PinMode.departure
                              ? '地図をタップして出発地を選択'
                              : '地図をタップして目的地を選択',
                          style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onInverseSurface),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close,
                            color: colorScheme.onInverseSurface, size: 20),
                        onPressed: () =>
                            setState(() => _pinMode = _PinMode.none),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ---- 生成中ローディングオーバーレイ ----
          if (_isGenerating)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.35),
                child: Center(
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: const Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('ルートを計算中…'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 設定パネルウィジェット
// ---------------------------------------------------------------------------

class _SettingPanel extends StatelessWidget {
  const _SettingPanel({
    required this.distanceM,
    required this.distanceLabel,
    required this.routeType,
    required this.departure,
    required this.destination,
    required this.pinMode,
    required this.isGenerating,
    required this.error,
    required this.hasSavedRoutes,
    required this.remainingRequests,
    required this.onDistanceChanged,
    required this.onRouteTypeChanged,
    required this.onSetDeparturePin,
    required this.onClearDeparture,
    required this.onSetDestinationPin,
    required this.onClearDestination,
    required this.onOpenSavedRoutes,
    required this.onGenerate,
  });

  final double distanceM;
  final String distanceLabel;
  final RouteType routeType;
  final LatLng? departure;
  final LatLng? destination;
  final _PinMode pinMode;
  final bool isGenerating;
  final String? error;
  final bool hasSavedRoutes;
  final int remainingRequests;
  final ValueChanged<double> onDistanceChanged;
  final ValueChanged<RouteType> onRouteTypeChanged;
  final VoidCallback onSetDeparturePin;
  final VoidCallback onClearDeparture;
  final VoidCallback onSetDestinationPin;
  final VoidCallback onClearDestination;
  final VoidCallback onOpenSavedRoutes;
  final VoidCallback? onGenerate;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ハンドルバー
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ---- ③ 保存済みルートから選ぶ ----
            if (hasSavedRoutes)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onOpenSavedRoutes,
                  icon: const Icon(Icons.history_rounded, size: 18),
                  label: const Text('保存済みルート'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: colorScheme.primary,
                  ),
                ),
              ),
            if (hasSavedRoutes) const SizedBox(height: 4),

            // ---- T-1.3.1: 距離スライダー ----
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  distanceLabel,
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '歩行距離',
                  style: textTheme.labelSmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            Slider(
              value: distanceM.clamp(100.0, 21000.0),
              min: 100,
              max: 21000,
              divisions: 209, // 100m 刻み
              onChanged: onDistanceChanged,
            ),
            // プリセットチップ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [500, 1000, 2000, 3000, 5000, 10000].map((m) {
                final selected = (distanceM - m).abs() < 50;
                final label = m < 1000 ? '${m}m' : '${m ~/ 1000}km';
                return _Chip(
                  label: label,
                  selected: selected,
                  onTap: () => onDistanceChanged(m.toDouble()),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),
            Divider(color: colorScheme.outlineVariant),
            const SizedBox(height: 8),

            // ---- T-1.3.2: ルート形状選択 ----
            Text('ルート形状',
                style: textTheme.labelMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 6),
            SegmentedButton<RouteType>(
              segments: RouteType.values
                  .map((t) => ButtonSegment(
                        value: t,
                        label: Text(t.label),
                        icon: Icon(t == RouteType.circular
                            ? Icons.loop_rounded
                            : Icons.arrow_forward_rounded),
                      ))
                  .toList(),
              selected: {routeType},
              onSelectionChanged: (s) => onRouteTypeChanged(s.first),
            ),

            const SizedBox(height: 12),

            // ---- T-1.3.3: 出発地選択 ----
            _LocationRow(
              icon: Icons.trip_origin_rounded,
              iconColor: Colors.green.shade600,
              label: departure == null
                  ? '現在地から出発'
                  : '出発地: (${departure!.latitude.toStringAsFixed(4)}, '
                      '${departure!.longitude.toStringAsFixed(4)})',
              isSet: departure != null,
              onSetPin: onSetDeparturePin,
              onClear: onClearDeparture,
            ),

            // ---- T-1.3.4: 目的地選択（片道のみ）----
            if (routeType == RouteType.oneWay) ...[
              const SizedBox(height: 8),
              _LocationRow(
                icon: Icons.location_on_rounded,
                iconColor: Colors.red.shade600,
                label: destination == null
                    ? '目的地（任意）'
                    : '目的地: (${destination!.latitude.toStringAsFixed(4)}, '
                        '${destination!.longitude.toStringAsFixed(4)})',
                isSet: destination != null,
                onSetPin: onSetDestinationPin,
                onClear: onClearDestination,
                hint: '設定しない場合は指定距離のルートを自動生成します',
              ),
            ],

            const SizedBox(height: 16),

            // ---- エラーメッセージ ----
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded,
                        color: colorScheme.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        error!,
                        style: textTheme.bodySmall
                            ?.copyWith(color: colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ),

            // ---- ルート生成ボタン ----
            PrimaryButton(
              icon: const Icon(Icons.route_rounded),
              label: 'ルートを生成',
              onPressed: onGenerate,
            ),

            // 残り回数表示
            const SizedBox(height: 6),
            Center(
              child: Text(
                '本日の残り生成回数: $remainingRequests 回',
                style: textTheme.labelSmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// サブウィジェット
// ---------------------------------------------------------------------------

class _LocationRow extends StatelessWidget {
  const _LocationRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.isSet,
    required this.onSetPin,
    required this.onClear,
    this.hint,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final bool isSet;
  final VoidCallback onSetPin;
  final VoidCallback onClear;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
              if (hint != null && !isSet)
                Text(
                  hint!,
                  style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant),
                ),
            ],
          ),
        ),
        if (isSet)
          IconButton(
            icon:
                Icon(Icons.close, size: 18, color: colorScheme.onSurface),
            onPressed: onClear,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          )
        else
          TextButton(
            onPressed: onSetPin,
            style:
                TextButton.styleFrom(padding: EdgeInsets.zero),
            child: const Text('地図で設定'),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: selected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.normal,
              ),
        ),
      ),
    );
  }
}

class _PinMarker extends StatelessWidget {
  const _PinMarker({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ③ 保存済みルート選択シート
// ---------------------------------------------------------------------------

class _SavedRoutesSheet extends ConsumerStatefulWidget {
  const _SavedRoutesSheet({required this.routes});

  final List<SavedRoute> routes;

  @override
  ConsumerState<_SavedRoutesSheet> createState() => _SavedRoutesSheetState();
}

class _SavedRoutesSheetState extends ConsumerState<_SavedRoutesSheet> {
  late List<SavedRoute> _routes;

  @override
  void initState() {
    super.initState();
    _routes = List<SavedRoute>.from(widget.routes);
  }

  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.round()}m';
    return '${(meters / 1000).toStringAsFixed(1)}km';
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}/${dt.month}/${dt.day}';
  }

  String _routeLabel(SavedRoute r) {
    if (r.name.isNotEmpty) return r.name;
    final typeLabel = r.routeType == RouteType.oneWay.name ? '片道' : '周回';
    return '$typeLabel ${_formatDistance(r.actualDistanceM)}';
  }

  Future<void> _toggleFavorite(SavedRoute r) async {
    final next = !r.isFavorite;
    await ref
        .read(savedRouteRepositoryProvider)
        .setFavorite(r.id, next);
    if (!mounted) return;
    setState(() {
      final idx = _routes.indexWhere((e) => e.id == r.id);
      if (idx >= 0) {
        _routes[idx] = _routes[idx].copyWith(isFavorite: next);
      }
    });
  }

  Future<void> _delete(SavedRoute r) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ルートを削除しますか？'),
        content: Text('${_routeLabel(r)} を保存済みルートから削除します。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade600),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('削除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(savedRouteRepositoryProvider).delete(r.id);
    if (!mounted) return;
    setState(() => _routes.removeWhere((e) => e.id == r.id));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (ctx, controller) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // ハンドルバー
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // タイトル
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Row(
                children: [
                  Icon(Icons.bookmark_rounded,
                      color: colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text('保存済みルート', style: textTheme.titleMedium),
                  const Spacer(),
                  Text(
                    '${_routes.length} 件',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // リスト
            Expanded(
              child: _routes.isEmpty
                  ? Center(
                      child: Text(
                        '保存済みのルートはありません',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.separated(
                      controller: controller,
                      itemCount: _routes.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (ctx, idx) {
                        final r = _routes[idx];
                        return ListTile(
                          leading: Icon(
                            r.routeType == RouteType.oneWay.name
                                ? Icons.arrow_forward_rounded
                                : Icons.loop_rounded,
                            color: colorScheme.primary,
                          ),
                          title: Text(_routeLabel(r)),
                          subtitle: Text(
                            '${_formatDistance(r.actualDistanceM)} '
                            '・ ${_formatDate(r.lastUsedAt ?? r.createdAt)}',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  r.isFavorite
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  color: r.isFavorite
                                      ? Colors.amber.shade600
                                      : colorScheme.outline,
                                ),
                                tooltip:
                                    r.isFavorite ? 'お気に入り解除' : 'お気に入り',
                                onPressed: () => _toggleFavorite(r),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  color: colorScheme.outline,
                                ),
                                tooltip: '削除',
                                onPressed: () => _delete(r),
                              ),
                            ],
                          ),
                          onTap: () => Navigator.of(context).pop(r),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
