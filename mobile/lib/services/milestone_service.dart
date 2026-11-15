import 'package:isar_community/isar.dart';

import '../data/database.dart';
import 'link/link_journal.dart';

import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/app_colors.dart';
import '../data/repositories/recently_played_repository.dart';
import '../l10n/l10n.dart';

/// Coarse grouping a milestone tier belongs to. Drives unit copy and how the
/// current progress value is sourced.
enum MilestoneCategory { songs, hours, dayStreak, uniqueArtists }

/// All milestone tiers, declared ascending within each category and with
/// categories in the order [songs, hours, dayStreak, uniqueArtists]. Both
/// `getNextMilestone` (ascending scan) and the cross-category priority in
/// `checkMilestones` rely on this declaration order.
enum MilestoneType {
  songs100,
  songs500,
  songs1000,
  songs2500,
  songs5000,
  songs10000,
  hours10,
  hours50,
  hours100,
  hours250,
  streak7,
  streak30,
  streak100,
  artists25,
  artists100,
  artists250,
}

extension MilestoneTypeX on MilestoneType {
  String get id => name;

  MilestoneCategory get category {
    return switch (this) {
      MilestoneType.songs100 ||
      MilestoneType.songs500 ||
      MilestoneType.songs1000 ||
      MilestoneType.songs2500 ||
      MilestoneType.songs5000 ||
      MilestoneType.songs10000 => MilestoneCategory.songs,
      MilestoneType.hours10 ||
      MilestoneType.hours50 ||
      MilestoneType.hours100 ||
      MilestoneType.hours250 => MilestoneCategory.hours,
      MilestoneType.streak7 ||
      MilestoneType.streak30 ||
      MilestoneType.streak100 => MilestoneCategory.dayStreak,
      MilestoneType.artists25 ||
      MilestoneType.artists100 ||
      MilestoneType.artists250 => MilestoneCategory.uniqueArtists,
    };
  }

  /// Short lowercase unit used in progress copy ("25 more songs to unlock").
  String get unit => category.unitNoun;

  String get title {
    return switch (this) {
      MilestoneType.songs100 => '100 Songs',
      MilestoneType.songs500 => '500 Songs',
      MilestoneType.songs1000 => '1,000 Songs',
      MilestoneType.songs2500 => '2,500 Songs',
      MilestoneType.songs5000 => '5,000 Songs',
      MilestoneType.songs10000 => '10,000 Songs',
      MilestoneType.hours10 => '10 Hours',
      MilestoneType.hours50 => '50 Hours',
      MilestoneType.hours100 => '100 Hours',
      MilestoneType.hours250 => '250 Hours',
      MilestoneType.streak7 => '7-Day Streak',
      MilestoneType.streak30 => '30-Day Streak',
      MilestoneType.streak100 => '100-Day Streak',
      MilestoneType.artists25 => '25 Artists',
      MilestoneType.artists100 => '100 Artists',
      MilestoneType.artists250 => '250 Artists',
    };
  }

  String get shortLabel {
    return switch (this) {
      MilestoneType.songs100 => '100 songs',
      MilestoneType.songs500 => '500 songs',
      MilestoneType.songs1000 => '1,000 songs',
      MilestoneType.songs2500 => '2,500 songs',
      MilestoneType.songs5000 => '5,000 songs',
      MilestoneType.songs10000 => '10,000 songs',
      MilestoneType.hours10 => '10 hours',
      MilestoneType.hours50 => '50 hours',
      MilestoneType.hours100 => '100 hours',
      MilestoneType.hours250 => '250 hours',
      MilestoneType.streak7 => '7-day streak',
      MilestoneType.streak30 => '30-day streak',
      MilestoneType.streak100 => '100-day streak',
      MilestoneType.artists25 => '25 artists',
      MilestoneType.artists100 => '100 artists',
      MilestoneType.artists250 => '250 artists',
    };
  }

  String get message {
    return switch (this) {
      MilestoneType.songs100 =>
        "You've listened to 100 songs on Hadoo. Here's to many more.",
      MilestoneType.songs500 =>
        "500 songs and counting. Your library is getting a proper workout.",
      MilestoneType.songs1000 => "1,000 songs deep in your Hadoo journey.",
      MilestoneType.songs2500 => "2,500 songs in. You're a Hadoo regular now.",
      MilestoneType.songs5000 =>
        "5,000 songs! That's a library's worth of listening.",
      MilestoneType.songs10000 => "10,000 songs on Hadoo. Legendary status.",
      MilestoneType.hours10 =>
        "You've spent 10 hours with Hadoo. Time flies with great audio.",
      MilestoneType.hours50 =>
        "50 hours on Hadoo. That's some serious listening.",
      MilestoneType.hours100 =>
        "100 hours locked in. You clearly love great audio.",
      MilestoneType.hours250 =>
        "250 hours on Hadoo. You're in the all-time tier.",
      MilestoneType.streak7 =>
        "A 7-day Hadoo streak! Consistency deserves a nod.",
      MilestoneType.streak30 =>
        "30 days of Hadoo in a row. A full month of great audio.",
      MilestoneType.streak100 => "100-day streak. Dedication personified.",
      MilestoneType.artists25 => "You've explored 25 unique artists on Hadoo. Broad taste deserves applause.",
      MilestoneType.artists100 =>
        "100 distinct artists and counting. Your taste keeps widening.",
      MilestoneType.artists250 => "250 unique artists. A true sonic explorer.",
    };
  }

  /// Per-tier accent color. Reuses the five existing gem tints by rank within
  /// each category; the top song tier uses emerald to cap the six-rung ladder.
  Color get tierColor {
    return switch (this) {
      MilestoneType.songs100 => AppColors.milestoneBronze,
      MilestoneType.songs500 => AppColors.milestoneSilver,
      MilestoneType.songs1000 => AppColors.milestoneGold,
      MilestoneType.songs2500 => AppColors.milestoneSapphire,
      MilestoneType.songs5000 => AppColors.milestoneAmethyst,
      MilestoneType.songs10000 => AppColors.milestoneEmerald,
      MilestoneType.hours10 => AppColors.milestoneBronze,
      MilestoneType.hours50 => AppColors.milestoneSilver,
      MilestoneType.hours100 => AppColors.milestoneGold,
      MilestoneType.hours250 => AppColors.milestoneSapphire,
      MilestoneType.streak7 => AppColors.milestoneBronze,
      MilestoneType.streak30 => AppColors.milestoneSilver,
      MilestoneType.streak100 => AppColors.milestoneGold,
      MilestoneType.artists25 => AppColors.milestoneBronze,
      MilestoneType.artists100 => AppColors.milestoneSilver,
      MilestoneType.artists250 => AppColors.milestoneGold,
    };
  }

  /// Per-tier icon (Lucide). Themed per category so tiers stay legible.
  IconData get tierIcon {
    return switch (this) {
      MilestoneType.songs100 => LucideIcons.music,
      MilestoneType.songs500 => LucideIcons.headphones,
      MilestoneType.songs1000 => LucideIcons.disc3,
      MilestoneType.songs2500 => LucideIcons.audioLines,
      MilestoneType.songs5000 => LucideIcons.listMusic,
      MilestoneType.songs10000 => LucideIcons.music4,
      MilestoneType.hours10 => LucideIcons.timer,
      MilestoneType.hours50 => LucideIcons.clock,
      MilestoneType.hours100 => LucideIcons.hourglass,
      MilestoneType.hours250 => LucideIcons.trophy,
      MilestoneType.streak7 => LucideIcons.flame,
      MilestoneType.streak30 => LucideIcons.calendarDays,
      MilestoneType.streak100 => LucideIcons.crown,
      MilestoneType.artists25 => LucideIcons.mic,
      MilestoneType.artists100 => LucideIcons.users,
      MilestoneType.artists250 => LucideIcons.award,
    };
  }

  /// The threshold value this milestone represents.
  int get threshold {
    return switch (this) {
      MilestoneType.songs100 => 100,
      MilestoneType.songs500 => 500,
      MilestoneType.songs1000 => 1000,
      MilestoneType.songs2500 => 2500,
      MilestoneType.songs5000 => 5000,
      MilestoneType.songs10000 => 10000,
      MilestoneType.hours10 => 10,
      MilestoneType.hours50 => 50,
      MilestoneType.hours100 => 100,
      MilestoneType.hours250 => 250,
      MilestoneType.streak7 => 7,
      MilestoneType.streak30 => 30,
      MilestoneType.streak100 => 100,
      MilestoneType.artists25 => 25,
      MilestoneType.artists100 => 100,
      MilestoneType.artists250 => 250,
    };
  }

  /// True for the highest tier in each category — the "endgame" milestones
  /// where the popup won't tease a "next" one.
  bool get isTopTier {
    return switch (this) {
      MilestoneType.songs10000 ||
      MilestoneType.hours250 ||
      MilestoneType.streak100 ||
      MilestoneType.artists250 => true,
      _ => false,
    };
  }
}

extension MilestoneCategoryX on MilestoneCategory {
  String get unitNoun {
    return switch (this) {
      MilestoneCategory.songs => 'songs',
      MilestoneCategory.hours => 'hours',
      MilestoneCategory.dayStreak => 'days',
      MilestoneCategory.uniqueArtists => 'artists',
    };
  }

  String get unitSingular {
    return switch (this) {
      MilestoneCategory.songs => 'song',
      MilestoneCategory.hours => 'hour',
      MilestoneCategory.dayStreak => 'day',
      MilestoneCategory.uniqueArtists => 'artist',
    };
  }

  /// Localized unit for progress copy ("3 more songs to unlock"). Takes the
  /// count so English can pick the singular/plural form.
  String unitLabel(int count) => switch (this) {
    MilestoneCategory.songs => l10n.songUnit(count),
    MilestoneCategory.hours => l10n.hourUnit(count),
    MilestoneCategory.dayStreak => l10n.dayUnit(count),
    MilestoneCategory.uniqueArtists => l10n.artistUnit(count),
  };

  /// Accent color of the highest tier in this category met by [value], or
  /// null when no tier is reached (callers fall back to a neutral accent).
  Color? tierColorFor(int value) {
    Color? color;
    for (final t in MilestoneType.values) {
      if (t.category == this && value >= t.threshold) color = t.tierColor;
    }
    return color;
  }

  /// Number of tiers in this category met by [value]. Drives escalating
  /// highlight intensity for things like long day streaks (0 = none).
  int tierCountFor(int value) {
    var count = 0;
    for (final t in MilestoneType.values) {
      if (t.category == this && value >= t.threshold) count++;
    }
    return count;
  }
}

class MilestoneRecord {
  final MilestoneType type;
  final DateTime achievedAt;

  const MilestoneRecord({required this.type, required this.achievedAt});

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'achievedAt': achievedAt.toIso8601String(),
  };

  factory MilestoneRecord.fromJson(Map<String, dynamic> json) {
    return MilestoneRecord(
      type: MilestoneType.values.firstWhere((e) => e.name == json['type']),
      achievedAt: DateTime.parse(json['achievedAt']),
    );
  }
}

class MilestoneService {
  static final changes = StreamController<void>.broadcast();
  static const _shownMilestonesKey = 'shown_milestones';
  static const _accumulatedListenSecondsKey = 'accumulated_listen_seconds';
  static const _streakCurrentKey = 'streak_current';
  static const _streakLastActiveDayKey = 'streak_last_active_day';
  static const _streakPopupSnoozedUntilKey = 'streak_popup_snoozed_until';

  final RecentlyPlayedRepository? _repository;
  final Future<List<DateTime>> Function()? _activityDaysOverride;
  final DateTime Function() _now;
  final Future<int> Function()? _playCountOverride;
  final Future<int> Function()? _listenSecondsOverride;
  final Future<int> Function()? _dayStreakOverride;
  final Future<int> Function()? _uniqueArtistsOverride;

  /// Tests can inject overrides for any category to bypass Isar-backed
  /// repositories. When an override is supplied the corresponding repository
  /// path is skipped, so unit tests don't need Isar initialized.
  MilestoneService({
    RecentlyPlayedRepository? repository,
    Future<List<DateTime>> Function()? activityDaysOverride,
    DateTime Function()? now,
    Future<int> Function()? playCountOverride,
    Future<int> Function()? listenSecondsOverride,
    Future<int> Function()? dayStreakOverride,
    Future<int> Function()? uniqueArtistsOverride,
  }) : _activityDaysOverride = activityDaysOverride,
       _now = now ?? DateTime.now,
       _repository =
           (playCountOverride == null || uniqueArtistsOverride == null)
           ? (repository ?? RecentlyPlayedRepository())
           : repository,
       _playCountOverride = playCountOverride,
       _listenSecondsOverride = listenSecondsOverride,
       _dayStreakOverride = dayStreakOverride,
       _uniqueArtistsOverride = uniqueArtistsOverride;

  Future<int> _getPlayCount() {
    final override = _playCountOverride;
    if (override != null) return override();
    return _repository!.getHistoryCount();
  }

  Future<int> _getUniqueArtistCount() {
    final override = _uniqueArtistsOverride;
    if (override != null) return override();
    return _repository!.getDistinctArtistCount();
  }

  Future<int> _getListenSeconds() {
    final override = _listenSecondsOverride;
    if (override != null) return override();
    return getAccumulatedListenSeconds();
  }

  Future<int> _getDayStreak() {
    final override = _dayStreakOverride;
    if (override != null) return override();
    return getBestDayStreak();
  }

  /// Exposed for the milestones screen to render live song progress.
  Future<int> getHistoryCount() => _getPlayCount();

  Future<int> getUniqueArtistCount() => _getUniqueArtistCount();

  Future<int> getAccumulatedListenSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    final local = prefs.getInt(_accumulatedListenSecondsKey) ?? 0;
    if (!Database.isInitialized) return local;
    final ownDevice = await LinkJournal.instance.deviceId();
    final imported = await Database.instance.playEventEntitys
        .filter()
        .not()
        .deviceIdEqualTo(ownDevice)
        .findAll();
    // Stable event IDs make repeated syncs idempotent. Own phone events are
    // already included in the local live counter and must not be added twice.
    final remoteMs = imported.fold<int>(
      0,
      (sum, event) => sum + event.msPlayed,
    );
    return local + remoteMs ~/ 1000;
  }

  Future<void> addListenSeconds(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_accumulatedListenSecondsKey) ?? 0;
    await prefs.setInt(_accumulatedListenSecondsKey, current + seconds);
  }

  /// Merge local activity with all paired play events, including desktop
  /// songs not owned on this phone. Multiple plays/devices count one local day.
  Future<({int current, int best})> _dayStreaks() async {
    final prefs = await SharedPreferences.getInstance();
    final now = _now();
    final cutoff = prefs.getInt('streak_history_since') ?? 0;
    final stamps = <DateTime>[];
    if (_activityDaysOverride != null) {
      stamps.addAll(await _activityDaysOverride());
    } else if (Database.isInitialized) {
      stamps.addAll(
        (await Database.instance.playEventEntitys
                .where()
                .playedAtProperty()
                .findAll())
            .map((ms) => DateTime.fromMillisecondsSinceEpoch(ms)),
      );
      stamps.addAll(
        await Database.instance.recentlyPlayedEntitys
            .where()
            .playedAtProperty()
            .findAll(),
      );
    }
    final days = <int>{
      for (final stamp in stamps)
        if (stamp.millisecondsSinceEpoch > 0 &&
            stamp.millisecondsSinceEpoch >= cutoff &&
            !stamp.isAfter(now.add(const Duration(minutes: 5))))
          _ordinal(stamp),
    };
    final stored = prefs.getInt(_streakCurrentKey) ?? 0;
    final key = int.tryParse(prefs.getString(_streakLastActiveDayKey) ?? '');
    if (key != null && stored > 0) {
      final last = _dateFromKey(key);
      if (last != null && !last.isAfter(now)) {
        final ordinal = _ordinal(last);
        for (var n = 0; n < stored.clamp(0, 10000); n++) days.add(ordinal - n);
      }
    }
    final sorted = days.toList()..sort();
    var best = 0, run = 0;
    int? previous;
    for (final day in sorted) {
      run = previous != null && day == previous + 1 ? run + 1 : 1;
      if (run > best) best = run;
      previous = day;
    }
    final today = _ordinal(now);
    var anchor = days.contains(today) ? today : today - 1;
    var current = 0;
    while (days.contains(anchor)) {
      current++;
      anchor--;
    }
    return (
      current: current,
      best: best > (prefs.getInt('streak_best') ?? 0)
          ? best
          : prefs.getInt('streak_best') ?? 0,
    );
  }

  Future<int> getCurrentDayStreak() async => (await _dayStreaks()).current;
  Future<int> getBestDayStreak() async => (await _dayStreaks()).best;

  Future<int> recordActivityDay() async {
    final prefs = await SharedPreferences.getInstance();
    final now = _now();
    final today = _dayKey(now);
    final key = int.tryParse(prefs.getString(_streakLastActiveDayKey) ?? '');
    final last = key == null ? null : _dateFromKey(key);
    final diff = last == null ? null : _ordinal(now) - _ordinal(last);
    final current = prefs.getInt(_streakCurrentKey) ?? 0;
    final next = diff != null && diff <= 0
        ? (current > 0 ? current : 1)
        : diff == 1
        ? current + 1
        : 1;
    final best = prefs.getInt('streak_best') ?? 0;
    await prefs.setInt(
      'streak_best',
      [best, current, next].reduce((a, b) => a > b ? a : b),
    );
    await prefs.setInt(_streakCurrentKey, next);
    await prefs.setString(_streakLastActiveDayKey, today.toString());
    changes.add(null);
    return getCurrentDayStreak();
  }

  static int _ordinal(DateTime t) {
    final local = t.toLocal();
    return DateTime.utc(
          local.year,
          local.month,
          local.day,
        ).millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
  }

  // Keep existing YYYYMMDD preference keys readable; subtract real days instead
  // of YYYYMMDD integers (which broke streaks at month/year boundaries).
  static int _dayKey(DateTime t) {
    final local = t.toLocal();
    return local.year * 10000 + local.month * 100 + local.day;
  }

  static DateTime? _dateFromKey(int key) {
    final y = key ~/ 10000, m = key ~/ 100 % 100, d = key % 100;
    final date = DateTime(y, m, d);
    return date.year == y && date.month == m && date.day == d ? date : null;
  }

  /// Whether the streak popup was snoozed today (until the next calendar day).
  Future<bool> isStreakPopupSnoozed() async {
    final prefs = await SharedPreferences.getInstance();
    final snoozedUntil = prefs.getInt(_streakPopupSnoozedUntilKey);
    if (snoozedUntil == null) return false;
    return snoozedUntil >= _dayKey(DateTime.now());
  }

  /// Snooze the streak popup until the next calendar day.
  Future<void> snoozeStreakPopup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_streakPopupSnoozedUntilKey, _dayKey(DateTime.now()));
  }

  /// Clears all streak-related state: counter, last-active day, popup snooze,
  /// and any shown streak milestones. Used when the user disables streaks.
  Future<void> clearStreakData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('streak_history_since', _now().millisecondsSinceEpoch);
    await prefs.remove('streak_best');
    await prefs.remove(_streakCurrentKey);
    await prefs.remove(_streakLastActiveDayKey);
    await prefs.remove(_streakPopupSnoozedUntilKey);
    final shown = await getShownMilestones();
    final filtered = shown
        .where((r) => r.type.category != MilestoneCategory.dayStreak)
        .toList();
    final raw = jsonEncode(filtered.map((r) => r.toJson()).toList());
    await prefs.setString(_shownMilestonesKey, raw);
  }

  Future<List<MilestoneRecord>> getShownMilestones() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_shownMilestonesKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => MilestoneRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> markMilestoneShown(MilestoneType type) async {
    final prefs = await SharedPreferences.getInstance();
    final shown = await getShownMilestones();
    shown.add(MilestoneRecord(type: type, achievedAt: DateTime.now()));
    final raw = jsonEncode(shown.map((r) => r.toJson()).toList());
    await prefs.setString(_shownMilestonesKey, raw);
    changes.add(null);
  }

  Future<bool> isMilestoneShown(MilestoneType type) async {
    final shown = await getShownMilestones();
    return shown.any(
      (r) =>
          r.type.category == type.category &&
          r.type.threshold >= type.threshold,
    );
  }

  /// Highest reached-but-unshown tier, preferring categories in declaration
  /// order (songs → hours → dayStreak → uniqueArtists) and, within a category,
  /// the highest threshold met.
  Future<MilestoneType?> checkMilestones() async {
    final records = await getShownMilestones();
    final shownSet = {
      for (final type in MilestoneType.values)
        if (records.any(
          (r) =>
              r.type.category == type.category &&
              r.type.threshold >= type.threshold,
        ))
          type,
    };
    final values = await _currentValues();

    for (final category in MilestoneCategory.values) {
      final tiers =
          MilestoneType.values
              .where((t) => t.category == category && !shownSet.contains(t))
              .toList()
            ..sort((a, b) => b.threshold.compareTo(a.threshold));
      for (final type in tiers) {
        if (values[category]! >= type.threshold) return type;
      }
    }
    return null;
  }

  /// Returns the lowest-tier unshown milestone (across all categories, in
  /// declaration order) along with the units still needed to unlock it.
  Future<({MilestoneType? next, int remaining})> getNextMilestone() async {
    final shown = await getShownMilestones();
    final shownSet = {
      for (final type in MilestoneType.values)
        if (shown.any(
          (r) =>
              r.type.category == type.category &&
              r.type.threshold >= type.threshold,
        ))
          type,
    };
    final values = await _currentValues();

    for (final type in MilestoneType.values) {
      if (shownSet.contains(type)) continue;
      final current = values[type.category]!;
      final remaining = type.threshold - current;
      return (next: type, remaining: remaining < 0 ? 0 : remaining);
    }
    return (next: null, remaining: 0);
  }

  Future<Map<MilestoneCategory, int>> _currentValues() async {
    final playCount = await _getPlayCount();
    final listenSeconds = await _getListenSeconds();
    final streak = await _getDayStreak();
    final artists = await _getUniqueArtistCount();
    return {
      MilestoneCategory.songs: playCount,
      MilestoneCategory.hours: listenSeconds ~/ 3600,
      MilestoneCategory.dayStreak: streak,
      MilestoneCategory.uniqueArtists: artists,
    };
  }
}
