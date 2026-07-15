import { LinearGradient } from "expo-linear-gradient";
import { useMemo, useState } from "react";
import { Pressable, RefreshControl, ScrollView, StyleSheet, View } from "react-native";

import { CachedArtwork } from "@/components/artwork/CachedArtwork";
import { AddToPlaylistSheet } from "@/components/playlists/AddToPlaylistSheet";
import { Screen } from "@/components/ui/Screen";
import { SymbolIcon } from "@/components/ui/SymbolIcon";
import { Text } from "@/components/ui/Text";
import { providerLabels } from "@/constants/providers";
import { useMiniPlayerLayout } from "@/hooks/useMiniPlayerLayout";
import { usePlayer } from "@/hooks/usePlayer";
import { usePersonalizedHome } from "@/hooks/usePersonalizedHome";
import { useTheme } from "@/hooks/useTheme";
import { useLibraryStore } from "@/modules/library/libraryStore";
import { playerService } from "@/modules/player/playerService";
import { usePlaylistStore } from "@/modules/playlists/playlistStore";
import { sourceRegistry } from "@/modules/sources/SourceRegistry";
import { useSettingsStore } from "@/modules/settings/settingsStore";
import { navigationService } from "@/services/navigationService";
import { toastService } from "@/services/toastService";
import type { ArtworkLike } from "@/types/artwork";
import type { HomeSection, MediaItem } from "@/types/home";
import type { MusicProvider } from "@/types/source";
import type { Track } from "@/types/track";
import { formatCount } from "@/utils/formatCount";
import { formatDuration } from "@/utils/formatDuration";

type HeroSlide = {
  id: string;
  eyebrow: string;
  title: string;
  subtitle: string;
  artwork?: ArtworkLike;
  cta: string;
  progress?: number;
  onPress: () => void;
};

type ContinueCardData = {
  title: string;
  subtitle: string;
  artwork?: ArtworkLike;
  cta: string;
  progress: number;
  onPress: () => void;
};

type QuickAction = {
  id: string;
  icon: "moon" | "download" | "settings";
  label: string;
  subtitle?: string;
  onPress: () => void;
};

const chunkTracks = (tracks: Track[], size: number) => {
  const chunks: Track[][] = [];
  for (let index = 0; index < tracks.length; index += size) {
    chunks.push(tracks.slice(index, index + size));
  }
  return chunks;
};

const buildPlayableQueue = (section: HomeSection) =>
  section.items.map((item) => item.track).filter(Boolean) as Track[];

const buildCollectionRoute = (item: MediaItem) => {
  const sourceUrl =
    item.sourceUrl ??
    (item.playlistId ? `https://music.youtube.com/playlist?list=${item.playlistId}` : undefined) ??
    (item.browseId ? `https://music.youtube.com/browse/${item.browseId}` : undefined);

  if (!sourceUrl) {
    return undefined;
  }

  return {
    pathname: "/playlist/[id]" as const,
    params: {
      id: item.id,
      sourceUrl,
      provider: item.provider,
      title: item.title,
      subtitle: item.subtitle,
    },
  };
};

export default function HomeScreen() {
  const theme = useTheme();
  const { currentTrack, progress, duration, isPlaying } = usePlayer();
  const recentlyPlayed = useLibraryStore((state) => state.recentlyPlayed);
  const resumeSession = useLibraryStore((state) => state.resumeSession);
  const likedSongs = useLibraryStore((state) => state.likedSongs);
  const playlists = usePlaylistStore((state) => state.playlists);
  const providerStates = useSettingsStore((state) => state.providerStates);
  const [refreshing, setRefreshing] = useState(false);
  const [playlistTrack, setPlaylistTrack] = useState<Track | null>(null);
  const { contentBottomSpacing } = useMiniPlayerLayout();
  const personalizedHome = usePersonalizedHome();

  const providerHealth = useMemo(
    () =>
      (Object.entries(providerStates) as [MusicProvider, boolean][])
        .filter(([, enabled]) => enabled)
        .map(([provider]) => ({
          provider,
          status: sourceRegistry.getProvider(provider)?.status ?? "disabled",
        })),
    [providerStates],
  );

  const providerWarnings = providerHealth.filter((item) => item.status !== "enabled").length;
  const continueTrack = currentTrack ?? resumeSession?.track;
  const continueProgress = currentTrack ? progress : resumeSession?.position ?? 0;
  const continueDuration = currentTrack ? duration || currentTrack.duration || 0 : resumeSession?.duration || 0;
  const continueRatio =
    continueDuration > 0 ? Math.min(Math.max(continueProgress / continueDuration, 0), 1) : 0;

  const providerSections = useMemo(
    () => personalizedHome.recommendationResult.rankedProviderSections,
    [personalizedHome.recommendationResult.rankedProviderSections],
  );
  const recommendationSection = personalizedHome.recommendationResult.primarySection;
  const recentColumns = chunkTracks(recentlyPlayed.slice(0, 9), 3);
  const recommendationTracks = recommendationSection ? buildPlayableQueue(recommendationSection) : [];
  const recommendationColumns = chunkTracks(recommendationTracks.slice(0, 9), 3);
  const dynamicSections = providerSections.slice(0, 4);

  const playMediaItem = (item: MediaItem, section: HomeSection) => {
    if (item.track) {
      const queue = buildPlayableQueue(section);
      void playerService.playTrack(item.track, queue.length ? queue : [item.track]);
      return;
    }

    const route = buildCollectionRoute(item);
    if (route) {
      navigationService.push(route, "Opening collection…");
      return;
    }

    toastService.show("This collection cannot be opened yet.");
  };

  const continueCard = useMemo<ContinueCardData | undefined>(() => {
    if (!continueTrack) {
      return undefined;
    }

    return {
      title: continueTrack.title,
      subtitle: `${continueTrack.artist} · ${continueDuration ? formatDuration(continueDuration) : "Open player"}`,
      artwork: continueTrack.artwork,
      cta: currentTrack ? (isPlaying ? "Now Playing" : "Resume") : "Resume",
      progress: continueRatio,
      onPress: () => {
        if (currentTrack) {
          navigationService.push("/now-playing", "Opening player…");
          return;
        }

        void playerService.resumeStoredTrack(continueTrack, continueProgress);
      },
    };
  }, [continueDuration, continueProgress, continueRatio, continueTrack, currentTrack, isPlaying]);

  const heroSlides = useMemo<HeroSlide[]>(() => {
    const slides: HeroSlide[] = [];

    providerSections.slice(0, 3).forEach((section, index) => {
      const leadItem = section.items[0];
      if (!leadItem) {
        return;
      }

      slides.push({
        id: `provider-${section.id}-${leadItem.id}`,
        eyebrow: index === 0 ? "Picked for You" : section.title,
        title: leadItem.title,
        subtitle: leadItem.subtitle ?? section.subtitle ?? providerLabels[section.provider],
        artwork: leadItem.artwork,
        cta: leadItem.track ? "Play" : "Open",
        onPress: () => playMediaItem(leadItem, section),
      });
    });

    if (!providerSections.length) {
      slides.push({
        id: "library-fallback",
        eyebrow: "Library",
        title: "Liked Songs",
        subtitle: `${formatCount(likedSongs.length, "saved track")}.`,
        artwork: likedSongs[0]?.artwork ?? recentlyPlayed[0]?.artwork,
        cta: "Open",
        onPress: () => navigationService.push("/library", "Opening library…"),
      });
    }

    return slides.slice(0, 4);
  }, [
    likedSongs,
    providerSections,
    recentlyPlayed,
  ]);

  const quickActions: QuickAction[] = [
    {
      id: "sleep",
      icon: "moon",
      label: "Sleep Timer",
      onPress: () => navigationService.push("/sleep-timer", "Opening sleep timer…"),
    },
    {
      id: "downloads",
      icon: "download",
      label: "Downloads",
      onPress: () => navigationService.push("/library", "Opening library…"),
    },
    {
      id: "sources",
      icon: "settings",
      label: "Sources",
      onPress: () => navigationService.push("/source-settings", "Opening sources…"),
    },
  ];

  const handleRefresh = async () => {
    setRefreshing(true);
    try {
      await Promise.all([
        playerService.syncState(),
        playerService.syncCurrentTrack(),
        personalizedHome.providerQuery.refetch(),
        personalizedHome.seedQuery.refetch(),
      ]);
    } finally {
      setRefreshing(false);
    }
  };

  return (
    <Screen scroll={false}>
      <ScrollView
        contentContainerStyle={[styles.content, { paddingBottom: styles.content.paddingBottom + contentBottomSpacing }]}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={() => void handleRefresh()}
            tintColor={theme.accent}
          />
        }
      >
        <TopDiscoverBar warningCount={providerWarnings} />

        {continueCard ? <ContinueListeningCard card={continueCard} /> : null}

        <QuickActionRow actions={quickActions} />

        <TrackListRail
          title="Recently Played"
          columns={recentColumns}
          onAddToPlaylist={(track) => setPlaylistTrack(track)}
          emptyTitle="Nothing played yet"
          emptyBody="Start playing and your recent tracks will appear here."
        />

        {recommendationSection ? (
          recommendationSection.cardType === "track_list" && recommendationTracks.length ? (
            <TrackListRail
              title={recommendationSection.title}
              subtitle={recommendationSection.subtitle}
              columns={recommendationColumns}
              loading={personalizedHome.providerQuery.isLoading || personalizedHome.seedQuery.isLoading}
              emptyTitle="Recommendations are still taking shape"
              emptyBody="We have your profile, but there are not enough playable matches yet."
            />
          ) : (
            <MediaRail section={recommendationSection} onPressItem={(item) => playMediaItem(item, recommendationSection)} />
          )
        ) : (
          <TrackListRail
            title="Recommended For You"
            columns={[]}
            loading={personalizedHome.providerQuery.isLoading || personalizedHome.seedQuery.isLoading}
            emptyTitle={
              personalizedHome.providerQuery.isError ? "Could not load recommendations" : "No recommendations yet"
            }
            emptyBody={
              personalizedHome.providerQuery.isError
                ? "The active source did not load. Check your source settings or refresh."
                : "We will lean on source shelves until your listening history gets stronger."
            }
          />
        )}

        {heroSlides.length ? (
          <ScrollView
            horizontal
            pagingEnabled
            decelerationRate="fast"
            snapToAlignment="start"
            showsHorizontalScrollIndicator={false}
            contentContainerStyle={styles.heroRail}
          >
            {heroSlides.map((slide) => (
              <HeroCard key={slide.id} slide={slide} />
            ))}
          </ScrollView>
        ) : null}

        {dynamicSections.map((section) =>
          section.cardType === "track_list" ? (
            <TrackListRail
              key={section.id}
              title={section.title}
              subtitle={section.subtitle}
              columns={chunkTracks(buildPlayableQueue(section).slice(0, 9), 3)}
              emptyTitle="No playable tracks in this shelf"
              emptyBody="This section loaded, but there are no playable tracks here yet."
            />
          ) : (
            <MediaRail key={section.id} section={section} onPressItem={(item) => playMediaItem(item, section)} />
          ),
        )}

        <HorizontalInfoRail
          title="Browse Your Space"
          items={[
            {
              id: "playlists-space",
              title: "Playlists",
              detail: `${playlists.length} ${playlists.length === 1 ? "playlist" : "playlists"}`,
              icon: "list",
              onPress: () => navigationService.push("/library", "Opening library…"),
            },
            {
              id: "downloads-space",
              title: "Downloads",
              icon: "download",
              onPress: () => navigationService.push("/library", "Opening library…"),
            },
            {
              id: "liked-space",
              title: "Liked Songs",
              detail: formatCount(likedSongs.length, "saved track"),
              icon: "library",
              onPress: () => navigationService.push("/library", "Opening library…"),
            },
          ]}
        />
      </ScrollView>
      <AddToPlaylistSheet
        visible={Boolean(playlistTrack)}
        track={playlistTrack}
        onClose={() => setPlaylistTrack(null)}
        bottomOffset={92}
      />
    </Screen>
  );
}

const TopDiscoverBar = ({ warningCount }: { warningCount: number }) => {
  const theme = useTheme();

  return (
    <View style={styles.topBar}>
      <View style={styles.topBarCopy}>
        <Text variant="title" style={styles.discoverTitle}>
          Discover
        </Text>
        <Text muted>Your sources, listening history, and picks in one place.</Text>
      </View>

      <View style={styles.topBarActions}>
        <Pressable
          style={[styles.topIconButton, { backgroundColor: theme.surface }]}
          onPress={() => navigationService.push("/source-settings", "Opening sources…")}
        >
          <SymbolIcon name="sparkles" size={18} color={theme.text} />
          {warningCount > 0 ? (
            <View style={[styles.badge, { backgroundColor: theme.accent }]}>
              <Text style={styles.badgeText}>{warningCount > 9 ? "9+" : String(warningCount)}</Text>
            </View>
          ) : null}
        </Pressable>
        <Pressable
          style={[styles.topIconButton, { backgroundColor: theme.surface }]}
          onPress={() => navigationService.push("/sleep-timer", "Opening sleep timer…")}
        >
          <SymbolIcon name="moon" size={18} color={theme.text} />
        </Pressable>
      </View>
    </View>
  );
};

const HeroCard = ({ slide }: { slide: HeroSlide }) => {
  const theme = useTheme();

  return (
    <Pressable onPress={slide.onPress} style={styles.heroSlide}>
      {slide.artwork ? (
        <CachedArtwork
          artwork={slide.artwork}
          category="hero"
          variant="hero"
          width={320}
          height={360}
        />
      ) : (
        <LinearGradient colors={[theme.surfaceAlt, theme.surface, theme.background]} style={styles.heroArtwork}>
          <SymbolIcon name="disc" size={32} color={theme.accent} />
        </LinearGradient>
      )}

      <LinearGradient
        colors={["transparent", "rgba(0,0,0,0.28)", "rgba(0,0,0,0.86)"]}
        style={styles.heroOverlay}
      />

      <View style={styles.heroTextBlock}>
        <Text muted style={styles.heroEyebrow}>
          {slide.eyebrow}
        </Text>
        <Text variant="title" numberOfLines={2} style={styles.heroTitle}>
          {slide.title}
        </Text>
        <Text muted numberOfLines={2} style={styles.heroSubtitle}>
          {slide.subtitle}
        </Text>
        <View style={styles.heroFooter}>
          <View style={[styles.heroCta, { backgroundColor: theme.accent }]}>
            <Text style={styles.heroCtaText}>{slide.cta}</Text>
          </View>
        </View>
      </View>
    </Pressable>
  );
};

const ContinueListeningCard = ({ card }: { card: ContinueCardData }) => {
  const theme = useTheme();

  return (
    <Pressable onPress={card.onPress} style={[styles.continueCard, { backgroundColor: theme.surface }]}>
      <CachedArtwork artwork={card.artwork} category="track" variant="card" width={96} height={96} borderRadius={24} />
      <View style={styles.continueMeta}>
        <Text muted style={styles.heroEyebrow}>
          Continue Listening
        </Text>
        <Text variant="headline" numberOfLines={2} style={styles.continueTitle}>
          {card.title}
        </Text>
        <Text muted numberOfLines={1}>
          {card.subtitle}
        </Text>
        <View style={styles.continueFooter}>
          <View style={[styles.heroCta, { backgroundColor: theme.accent }]}>
            <Text style={styles.heroCtaText}>{card.cta}</Text>
          </View>
          <View style={styles.continueProgressTrack}>
            <View
              style={[
                styles.heroProgressValue,
                { width: `${card.progress * 100}%`, backgroundColor: theme.accent },
              ]}
            />
          </View>
        </View>
      </View>
    </Pressable>
  );
};

const QuickActionRow = ({ actions }: { actions: QuickAction[] }) => {
  const theme = useTheme();

  return (
    <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.quickRail}>
      {actions.map((action) => (
        <Pressable key={action.id} onPress={action.onPress} style={styles.quickItem}>
          <View style={[styles.quickIconWrap, { backgroundColor: theme.surfaceAlt }]}>
            <SymbolIcon name={action.icon} size={18} color={theme.accent} />
          </View>
          <Text>{action.label}</Text>
          {action.subtitle ? (
            <Text muted style={styles.quickSubtitle}>
              {action.subtitle}
            </Text>
          ) : null}
        </Pressable>
      ))}
    </ScrollView>
  );
};

const TrackListRail = ({
  title,
  subtitle,
  columns,
  onAddToPlaylist,
  loading,
  emptyTitle,
  emptyBody,
}: {
  title: string;
  subtitle?: string;
  columns: Track[][];
  onAddToPlaylist?: (track: Track) => void;
  loading?: boolean;
  emptyTitle: string;
  emptyBody: string;
}) => {
  return (
    <View style={styles.section}>
      <SectionHeader title={title} subtitle={subtitle} />
      {loading ? (
        <LoadingRail />
      ) : columns.length ? (
        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.trackColumnRail}>
          {columns.map((tracks, index) => (
            <View key={`${title}-${index}`} style={styles.trackColumn}>
              {tracks.map((track) => (
                <TrackRailRow key={`${title}-${track.id}`} track={track} queue={tracks} onAddToPlaylist={onAddToPlaylist} />
              ))}
            </View>
          ))}
        </ScrollView>
      ) : (
        <EmptyStateLine title={emptyTitle} body={emptyBody} icon="sparkles" />
      )}
    </View>
  );
};

const TrackRailRow = ({ track, queue, onAddToPlaylist }: { track: Track; queue: Track[]; onAddToPlaylist?: (track: Track) => void }) => {
  const theme = useTheme();

  return (
    <Pressable
      onPress={() => void playerService.playTrack(track, queue)}
      style={[styles.trackRailRow, { backgroundColor: theme.surface }]}
    >
      <CachedArtwork artwork={track.artwork} category="track" variant="thumbnail" width={58} height={58} borderRadius={16} />
      <View style={styles.trackRailCopy}>
        <Text numberOfLines={1}>{track.title}</Text>
        <Text muted numberOfLines={1}>
          {track.artist}
        </Text>
      </View>
      <View style={styles.trackRailSide}>
        <Text variant="caption" style={{ color: theme.accent }}>
          {providerLabels[track.provider]}
        </Text>
        <View style={styles.trackRailActions}>
          <Text muted>{formatDuration(track.duration)}</Text>
          {onAddToPlaylist ? (
            <Pressable
              hitSlop={8}
              onPress={(event) => {
                event.stopPropagation();
                onAddToPlaylist(track);
              }}
              style={[styles.trackAddButton, { backgroundColor: theme.surfaceAlt }]}
            >
              <SymbolIcon name="add" size={14} color={theme.accent} />
            </Pressable>
          ) : null}
        </View>
      </View>
    </Pressable>
  );
};

const MediaRail = ({
  section,
  onPressItem,
}: {
  section: HomeSection;
  onPressItem: (item: MediaItem) => void;
}) => {
  return (
    <View style={styles.section}>
      <SectionHeader title={section.title} subtitle={section.subtitle ?? providerLabels[section.provider]} />
      <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.infoRail}>
        {section.items.slice(0, 12).map((item) => (
          <Pressable key={item.id} onPress={() => onPressItem(item)} style={styles.mediaCard}>
            {item.artwork?.url ? (
              <CachedArtwork artwork={item.artwork} category={item.kind === "artist" ? "artist" : item.kind === "album" ? "album" : "playlist"} variant="card" width={172} height={172} borderRadius={22} />
            ) : (
              <View style={styles.mediaArtworkFallback}>
                <SymbolIcon name="disc" size={22} color="#7CFFB2" />
              </View>
            )}
            <Text numberOfLines={2}>{item.title}</Text>
            <Text muted numberOfLines={2}>
              {item.subtitle ?? item.kind}
            </Text>
          </Pressable>
        ))}
      </ScrollView>
    </View>
  );
};

const HorizontalInfoRail = ({
  title,
  subtitle,
  items,
}: {
  title: string;
  subtitle?: string;
  items: {
    id: string;
    title: string;
    detail?: string;
    icon: "download" | "library" | "list";
    onPress: () => void;
  }[];
}) => {
  const theme = useTheme();

  return (
    <View style={styles.section}>
      <SectionHeader title={title} subtitle={subtitle} />
      <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.infoRail}>
        {items.map((item) => (
          <Pressable key={item.id} onPress={item.onPress} style={[styles.infoCard, { backgroundColor: theme.surface }]}>
            <View style={[styles.infoIconWrap, { backgroundColor: theme.surfaceAlt }]}>
              <SymbolIcon name={item.icon} size={18} color={theme.accent} />
            </View>
            <Text variant="headline" numberOfLines={2} style={styles.infoTitle}>
              {item.title}
            </Text>
            {item.detail ? (
              <Text muted numberOfLines={2}>
                {item.detail}
              </Text>
            ) : null}
          </Pressable>
        ))}
      </ScrollView>
    </View>
  );
};

const SectionHeader = ({ title, subtitle }: { title: string; subtitle?: string }) => (
  <View style={styles.sectionHeader}>
    <Text variant="headline">{title}</Text>
    {subtitle ? <Text muted>{subtitle}</Text> : null}
  </View>
);

const EmptyStateLine = ({
  title,
  body,
  icon,
}: {
  title: string;
  body: string;
  icon: "sparkles" | "settings";
}) => {
  const theme = useTheme();

  return (
    <View style={[styles.emptyState, { backgroundColor: theme.surface }]}>
      <View style={[styles.emptyIconWrap, { backgroundColor: theme.surfaceAlt }]}>
        <SymbolIcon name={icon} size={18} color={theme.accent} />
      </View>
      <View style={styles.emptyCopy}>
        <Text>{title}</Text>
        <Text muted>{body}</Text>
      </View>
    </View>
  );
};

const LoadingRail = () => {
  const theme = useTheme();

  return (
    <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.trackColumnRail}>
      {[0, 1].map((column) => (
        <View key={column} style={styles.trackColumn}>
          {[0, 1, 2].map((row) => (
            <View key={row} style={[styles.trackRailRow, { backgroundColor: theme.surface }]}>
              <View style={[styles.trackThumb, { backgroundColor: theme.surfaceAlt }]} />
              <View style={styles.trackRailCopy}>
                <View style={[styles.skeletonLine, { backgroundColor: theme.surfaceAlt, width: "80%" }]} />
                <View style={[styles.skeletonLine, { backgroundColor: theme.surfaceAlt, width: "55%" }]} />
              </View>
            </View>
          ))}
        </View>
      ))}
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  content: {
    gap: 22,
    paddingBottom: 180,
  },
  topBar: {
    flexDirection: "row",
    alignItems: "flex-start",
    justifyContent: "space-between",
    gap: 12,
  },
  topBarCopy: {
    flex: 1,
    gap: 4,
  },
  discoverTitle: {
    fontSize: 38,
  },
  topBarActions: {
    flexDirection: "row",
    alignItems: "center",
    gap: 10,
  },
  topIconButton: {
    width: 42,
    height: 42,
    borderRadius: 21,
    alignItems: "center",
    justifyContent: "center",
  },
  badge: {
    position: "absolute",
    right: -2,
    top: -2,
    minWidth: 18,
    height: 18,
    borderRadius: 9,
    paddingHorizontal: 4,
    alignItems: "center",
    justifyContent: "center",
  },
  badgeText: {
    color: "#081018",
    fontSize: 10,
    fontWeight: "700",
  },
  heroRail: {
    gap: 14,
    paddingRight: 20,
  },
  heroSlide: {
    width: 320,
    height: 360,
    borderRadius: 30,
    overflow: "hidden",
    backgroundColor: "#10141B",
  },
  heroArtwork: {
    width: "100%",
    height: "100%",
    resizeMode: "cover",
    alignItems: "center",
    justifyContent: "center",
  },
  heroOverlay: {
    ...StyleSheet.absoluteFillObject,
  },
  heroTextBlock: {
    position: "absolute",
    left: 18,
    right: 18,
    bottom: 18,
    gap: 8,
  },
  heroEyebrow: {
    letterSpacing: 1,
    fontSize: 11,
    textTransform: "uppercase",
    color: "#D1D7E3",
  },
  heroTitle: {
    color: "#F5F7FB",
    fontSize: 30,
  },
  heroSubtitle: {
    color: "#D1D7E3",
  },
  heroFooter: {
    gap: 12,
    marginTop: 4,
  },
  heroCta: {
    alignSelf: "flex-start",
    borderRadius: 999,
    paddingHorizontal: 14,
    paddingVertical: 9,
  },
  heroCtaText: {
    color: "#081018",
    fontWeight: "700",
  },
  heroProgressTrack: {
    height: 5,
    borderRadius: 999,
    overflow: "hidden",
    backgroundColor: "rgba(255,255,255,0.18)",
  },
  heroProgressValue: {
    height: "100%",
    borderRadius: 999,
  },
  continueCard: {
    minHeight: 128,
    borderRadius: 28,
    padding: 16,
    flexDirection: "row",
    alignItems: "center",
    gap: 14,
  },
  continueMeta: {
    flex: 1,
    gap: 6,
  },
  continueTitle: {
    fontSize: 24,
    lineHeight: 30,
  },
  continueFooter: {
    gap: 10,
    marginTop: 2,
  },
  continueProgressTrack: {
    height: 5,
    borderRadius: 999,
    overflow: "hidden",
    backgroundColor: "rgba(255,255,255,0.12)",
  },
  quickRail: {
    gap: 14,
    paddingRight: 20,
  },
  quickItem: {
    width: 104,
    gap: 10,
  },
  quickIconWrap: {
    width: 54,
    height: 54,
    borderRadius: 27,
    alignItems: "center",
    justifyContent: "center",
  },
  quickSubtitle: {
    fontSize: 12,
    lineHeight: 16,
  },
  section: {
    gap: 12,
  },
  sectionHeader: {
    gap: 4,
  },
  trackColumnRail: {
    gap: 14,
    paddingRight: 20,
  },
  trackColumn: {
    width: 306,
    gap: 10,
  },
  trackRailRow: {
    minHeight: 82,
    borderRadius: 22,
    padding: 12,
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
  },
  trackThumb: {
    width: 58,
    height: 58,
    borderRadius: 16,
  },
  trackRailCopy: {
    flex: 1,
    gap: 4,
    justifyContent: "center",
  },
  trackRailSide: {
    alignItems: "flex-end",
    gap: 6,
  },
  trackRailActions: {
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
  },
  trackAddButton: {
    width: 24,
    height: 24,
    borderRadius: 12,
    alignItems: "center",
    justifyContent: "center",
  },
  infoRail: {
    gap: 14,
    paddingRight: 20,
  },
  infoCard: {
    width: 180,
    minHeight: 170,
    borderRadius: 24,
    padding: 16,
    gap: 14,
  },
  infoIconWrap: {
    width: 44,
    height: 44,
    borderRadius: 22,
    alignItems: "center",
    justifyContent: "center",
  },
  infoTitle: {
    fontSize: 20,
  },
  mediaCard: {
    width: 172,
    gap: 10,
  },
  mediaArtwork: {
    width: 172,
    height: 172,
    borderRadius: 22,
    alignItems: "center",
    justifyContent: "center",
  },
  mediaArtworkFallback: {
    width: 172,
    height: 172,
    borderRadius: 22,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "#142235",
  },
  emptyState: {
    flexDirection: "row",
    alignItems: "flex-start",
    gap: 12,
    borderRadius: 22,
    padding: 14,
  },
  emptyIconWrap: {
    width: 42,
    height: 42,
    borderRadius: 21,
    alignItems: "center",
    justifyContent: "center",
  },
  emptyCopy: {
    flex: 1,
    gap: 4,
  },
  skeletonLine: {
    height: 10,
    borderRadius: 999,
  },
});
