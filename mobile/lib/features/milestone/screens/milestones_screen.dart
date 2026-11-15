import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flick/core/theme/lokal_theme.dart';
import 'package:flick/core/theme/lokal_tokens.dart';
import 'package:flick/providers/providers.dart';
import 'package:flick/services/milestone_service.dart';
import 'package:flick/features/milestone/widgets/milestone_card.dart';
import 'package:flick/features/milestone/widgets/streak_popup.dart';
import 'package:flick/widgets/common/flick_dialog.dart';
import 'package:flick/widgets/lokal/lokal_glass.dart';
import 'package:flick/l10n/l10n.dart';

/// Lokal's listening collection. Earned tiers and calculations come from the
/// existing milestone service; this screen only presents and refreshes them.
class MilestonesScreen extends ConsumerStatefulWidget {
  const MilestonesScreen({super.key});
  @override
  ConsumerState<MilestonesScreen> createState() => _MilestonesScreenState();
}

class _MilestonesScreenState extends ConsumerState<MilestonesScreen> {
  final _service = MilestoneService();
  bool _loading = true, _streaksEnabled = true;
  int _request = 0, _runningStreak = 0;
  Map<MilestoneType, MilestoneRecord> _records = {};
  Map<MilestoneCategory, int> _current = const {};

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final request = ++_request;
    final records = await _service.getShownMilestones();
    final playCount = await _service.getHistoryCount();
    final listenSeconds = await _service.getAccumulatedListenSeconds();
    final runningStreak = await _service.getCurrentDayStreak();
    final streak = await _service.getBestDayStreak();
    final artists = await _service.getUniqueArtistCount();
    if (!mounted || request != _request) return;
    setState(() {
      _runningStreak = runningStreak;
      _records = {for (final record in records) record.type: record};
      _streaksEnabled = ref.read(appPreferencesProvider).streaksEnabled;
      _current = {
        MilestoneCategory.songs: playCount,
        MilestoneCategory.hours: listenSeconds ~/ 3600,
        MilestoneCategory.dayStreak: streak,
        MilestoneCategory.uniqueArtists: artists,
      };
      _loading = false;
    });
  }

  bool _earned(MilestoneType type) =>
      (_current[type.category] ?? 0) >= type.threshold ||
      _records.keys.any(
        (record) =>
            record.category == type.category &&
            record.threshold >= type.threshold,
      );

  @override
  Widget build(BuildContext context) {
    ref.listen(milestoneRevisionProvider, (_, _) {
      if (mounted) _refresh();
    });
    final t = context.lokal;
    final categories = MilestoneCategory.values
        .where(
          (category) =>
              _streaksEnabled || category != MilestoneCategory.dayStreak,
        )
        .toList();
    final available = MilestoneType.values
        .where((type) => categories.contains(type.category))
        .toList();
    final earned = available.where(_earned).length;
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          LokalGlassButton(
                            semanticLabel: l10n.back,
                            onPressed: () => Navigator.of(context).pop(),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: t.text,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            lokalText('YOUR LISTENING'),
                            style: TextStyle(
                              fontFamily: LokalTheme.mono,
                              color: t.muted,
                              fontSize: 11,
                              letterSpacing: 1.8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Text(
                        l10n.milestones,
                        style: TextStyle(
                          fontFamily: LokalTheme.sans,
                          color: t.text,
                          fontSize: 38,
                          height: 1.1,
                          letterSpacing: -1.3,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        lokalText('Every listen leaves a mark.'),
                        style: TextStyle(color: t.muted, fontSize: 15),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: t.surface,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: t.border),
                        ),
                        child: Row(
                          children: [
                            SizedBox.square(
                              dimension: 82,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Positioned.fill(
                                    child: CircularProgressIndicator(
                                      value: available.isEmpty
                                          ? 0
                                          : earned / available.length,
                                      strokeWidth: 5,
                                      strokeCap: StrokeCap.round,
                                      backgroundColor: t.surface3,
                                      color: t.accent,
                                    ),
                                  ),
                                  Icon(
                                    Icons.auto_awesome_rounded,
                                    color: t.accent,
                                    size: 30,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 22),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$earned',
                                    style: TextStyle(
                                      color: t.text,
                                      fontSize: 40,
                                      fontFamily: LokalTheme.sans,
                                      fontWeight: FontWeight.w800,
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  Text(
                                    l10n.unlocked(earned, available.length),
                                    style: TextStyle(
                                      color: t.muted,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_streaksEnabled) ...[
                        const SizedBox(height: 12),
                        Material(
                          color: t.surface,
                          borderRadius: BorderRadius.circular(22),
                          child: InkWell(
                            onTap: _showStreakDialog,
                            borderRadius: BorderRadius.circular(22),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.local_fire_department_rounded,
                                    color: t.accent,
                                    size: 30,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      l10n.currentStreak,
                                      style: TextStyle(
                                        color: t.text,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '$_runningStreak ${l10n.dayUnit(_runningStreak)}',
                                    style: TextStyle(
                                      color: t.accent,
                                      fontFamily: LokalTheme.mono,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (_loading)
                const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                for (final category in categories) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _categoryLabel(category),
                              style: TextStyle(
                                color: t.text,
                                fontFamily: LokalTheme.sans,
                                fontSize: 23,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -.5,
                              ),
                            ),
                          ),
                          Text(
                            '${_current[category] ?? 0}',
                            style: TextStyle(
                              color: t.muted,
                              fontFamily: LokalTheme.mono,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.crossAxisExtent >= 600
                            ? 3
                            : 2;
                        final types = available
                            .where((type) => type.category == category)
                            .toList();
                        final scale = MediaQuery.textScalerOf(context)
                            .scale(1)
                            .clamp(1.0, 2.0);
                        return SliverGrid.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                mainAxisExtent: 214 * scale,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                              ),
                          itemCount: types.length,
                          itemBuilder: (context, index) => _BadgeTile(
                            type: types[index],
                            earned: _earned(types[index]),
                            record: _records[types[index]],
                            current: _current[category] ?? 0,
                            onTap: () => _handleTileTap(
                              types[index],
                              _records[types[index]],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 32 + MediaQuery.paddingOf(context).bottom,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStreakDialog() {
    final streak = _runningStreak;
    if (streak < 1) return;
    showFlickDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: l10n.dayStreak2,
      builder: (context) => StreakPopup(
        streak: streak,
        onSnooze: () => _service.snoozeStreakPopup(),
      ),
    );
  }

  Future<void> _handleTileTap(
    MilestoneType type,
    MilestoneRecord? record,
  ) async {
    if (_earned(type)) {
      await _showCelebration(type, achievedAt: record?.achievedAt);
    } else {
      await _showLockedSheet(type);
    }
  }

  Future<void> _showCelebration(
    MilestoneType type, {
    DateTime? achievedAt,
  }) async {
    final next = await _service.getNextMilestone();
    if (!mounted) return;
    await showFlickDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: l10n.milestone,
      builder: (context) => MilestoneCard(
        milestone: type,
        achievedAt: achievedAt,
        nextMilestone: next.next,
        nextRemaining: next.next == null ? null : next.remaining,
        supportLabel: l10n.close,
        dismissLabel: l10n.done,
      ),
    );
  }

  Future<void> _showLockedSheet(MilestoneType type) async {
    final current = _current[type.category] ?? 0;
    final remaining = (type.threshold - current).clamp(0, type.threshold);
    final unit = type.category.unitLabel(remaining);
    if (!mounted) return;
    await showModalBottomSheet<void>(
      useRootNavigator: true,
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (sheetContext) {
        return _LockedSheet(
          type: type,
          current: current,
          remaining: remaining,
          unit: unit,
        );
      },
    );
  }
}

String _categoryLabel(MilestoneCategory category) => switch (category) {
  MilestoneCategory.songs => l10n.songs14,
  MilestoneCategory.hours => l10n.listeningHours,
  MilestoneCategory.dayStreak => l10n.dayStreak3,
  MilestoneCategory.uniqueArtists => l10n.uniqueArtists,
};

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({
    required this.type,
    required this.record,
    required this.earned,
    required this.current,
    required this.onTap,
  });
  final MilestoneType type;
  final MilestoneRecord? record;
  final bool earned;
  final int current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.lokal;
    return Material(
      color: earned ? t.surface : t.surface2,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: earned ? t.accent.withValues(alpha: .3) : t.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: earned
                          ? t.accent.withValues(alpha: .12)
                          : t.surface3,
                    ),
                    child: Icon(
                      type.tierIcon,
                      color: earned ? t.accent : t.muted,
                      size: 23,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    earned
                        ? Icons.check_circle_rounded
                        : Icons.lock_outline_rounded,
                    size: 16,
                    color: earned ? t.accent : t.muted.withValues(alpha: .5),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                type.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: earned ? t.text : t.muted,
                  fontSize: 18,
                  fontFamily: LokalTheme.sans,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                earned
                    ? record == null
                          ? 'Unlocked'
                          : MaterialLocalizations.of(context)
                                .formatShortDate(record!.achievedAt.toLocal())
                    : '$current / ${type.threshold}',
                style: TextStyle(
                  color: t.muted,
                  fontSize: 11,
                  fontFamily: LokalTheme.mono,
                ),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: earned
                      ? 1
                      : (current / type.threshold).clamp(0.0, 1.0),
                  minHeight: 3,
                  backgroundColor: t.surface3,
                  color: earned ? t.accent : t.muted.withValues(alpha: .5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LockedSheet extends StatelessWidget {
  const _LockedSheet({
    required this.type,
    required this.current,
    required this.remaining,
    required this.unit,
  });
  final MilestoneType type;
  final int current, remaining;
  final String unit;
  @override
  Widget build(BuildContext context) {
    final t = context.lokal;
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: t.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(type.tierIcon, size: 36, color: t.accent),
            const SizedBox(height: 18),
            Text(
              type.title,
              style: TextStyle(
                color: t.text,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(type.message, style: TextStyle(color: t.muted, height: 1.5)),
            const SizedBox(height: 22),
            LinearProgressIndicator(
              value: (current / type.threshold).clamp(0.0, 1.0),
              color: t.accent,
              backgroundColor: t.surface3,
            ),
            const SizedBox(height: 12),
            Text(
              remaining > 0
                  ? l10n.moreToUnlock(remaining, unit)
                  : l10n.youVeHitTheThresholdKeep,
              style: TextStyle(color: t.text),
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.done),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
