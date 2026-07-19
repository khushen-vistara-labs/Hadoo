import { useQuery } from "@tanstack/react-query";
import { router, useLocalSearchParams } from "expo-router";
import { LinearGradient } from "expo-linear-gradient";
import { memo, useMemo, useState } from "react";
import { ActivityIndicator, FlatList, Pressable, ScrollView, StyleSheet, View } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";

import { CachedArtwork } from "@/components/artwork/CachedArtwork";
import { AddToPlaylistSheet } from "@/components/playlists/AddToPlaylistSheet";
import { ProgressBar } from "@/components/ui/ProgressBar";
import { Screen } from "@/components/ui/Screen";
import { SymbolIcon } from "@/components/ui/SymbolIcon";
import { Text } from "@/components/ui/Text";
import { providerLabels } from "@/constants/providers";
import { useMiniPlayerLayout } from "@/hooks/useMiniPlayerLayout";
import { useTheme } from "@/hooks/useTheme";
import { downloadService, type DownloadBatchProgress } from "@/modules/downloads/downloadService";
import { findDownloadForTrack, useDownloadStore } from "@/modules/downloads/downloadStore";
import { playerService } from "@/modules/player/playerService";
import { usePlaylistStore } from "@/modules/playlists/playlistStore";
import { sourceRegistry } from "@/modules/sources/SourceRegistry";
import { buildCanonicalTrackKey } from "@/modules/sources/sourceUtils";
import { navigationService } from "@/services/navigationService";
import { toastService } from "@/services/toastService";
import type { ArtworkLike } from "@/types/artwork";
import type { Playlist } from "@/types/playlist";
import type { MusicProvider } from "@/types/source";
import type { Track } from "@/types/track";
import { formatCount } from "@/utils/formatCount";
import { formatDuration } from "@/utils/formatDuration";

const toParamValue = (value: string | string[] | undefined) => (Array.isArray(value) ? value[0] : value);

type CollectionTrackRowProps = {
  index: number;
  queue: Track[];
  track: Track;
  onLongPress: (track: Track) => void;
};

const CollectionTrackRow = memo(({ index, queue, track, onLongPress }: CollectionTrackRowProps) => {
  const theme = useTheme();
  const isDownloaded = useDownloadStore((state) => Boolean(findDownloadForTrack(track, state.downloads)));
  const rowGlowColors = [`${theme.accent}12`, `${theme.accentAlt}0D`, "transparent"] as const;

  return (
    <Pressable
      onPress={() =>
        playerService.playTrack(track, queue).catch(() => {
          toastService.show("Could not play this track.");
        })
      }
      onLongPress={() => onLongPress(track)}
      delayLongPress={220}
      style={({ pressed }) => [
        styles.row,
        {
          backgroundColor: pressed ? `${theme.surfaceAlt}CC` : "transparent",
          borderColor: pressed ? `${theme.accent}44` : "transparent",
        },
      ]}
    >
      <LinearGradient
        colors={rowGlowColors}
        start={{ x: 0, y: 0.5 }}
        end={{ x: 1, y: 0.5 }}
        style={styles.rowGlow}
      />
      <View style={[styles.rowIndexWrap, { backgroundColor: `${theme.background}B8`, borderColor: `${theme.border}66` }]}>
        <Text muted style={styles.rowIndex}>
          {String(index + 1).padStart(2, "0")}
        </Text>
      </View>
      <CachedArtwork artwork={track.artwork} category="track" variant="thumbnail" width={56} height={56} borderRadius={18} />
      <View style={[styles.rowMeta, { borderBottomColor: `${theme.border}55` }]}>
        <Text numberOfLines={1} style={styles.rowTitle}>
          {track.title}
        </Text>
        <Text muted numberOfLines={1}>
          {track.artist}
        </Text>
        <View style={styles.rowTags}>
          {track.album ? (
            <View style={[styles.tag, { backgroundColor: `${theme.surfaceAlt}99` }]}>
              <Text muted numberOfLines={1} style={styles.tagText}>
                {track.album}
              </Text>
            </View>
          ) : null}
        </View>
      </View>
      <View style={styles.rowSide}>
        {isDownloaded ? <SymbolIcon name="checkCircle" size={16} color={theme.accent} /> : null}
        <Text muted>{formatDuration(track.duration)}</Text>
        <Pressable
          accessibilityLabel={`Options for ${track.title}`}
          hitSlop={8}
          onPress={(event) => {
            event.stopPropagation();
            onLongPress(track);
          }}
          style={[styles.morePill, { backgroundColor: `${theme.surface}A8`, borderColor: `${theme.border}44` }]}
        >
          <SymbolIcon name="menu" size={14} color={theme.textMuted} />
        </Pressable>
      </View>
    </Pressable>
  );
});

CollectionTrackRow.displayName = "CollectionTrackRow";

export default function PlaylistDetailsScreen() {
  const params = useLocalSearchParams<{
    id: string;
    provider?: MusicProvider;
    sourceUrl?: string;
    title?: string;
    subtitle?: string;
  }>();
  const id = toParamValue(params.id);
  const sourceUrl = toParamValue(params.sourceUrl);
  const providerParam = toParamValue(params.provider) as MusicProvider | undefined;
  const fallbackTitle = toParamValue(params.title);
  const fallbackSubtitle = toParamValue(params.subtitle);
  const theme = useTheme();
  const insets = useSafeAreaInsets();
  const { contentBottomSpacing } = useMiniPlayerLayout();
  const [selectedTrack, setSelectedTrack] = useState<Track | null>(null);
  const [playlistTrack, setPlaylistTrack] = useState<Track | null>(null);
  const [playlistDownloadProgress, setPlaylistDownloadProgress] = useState<DownloadBatchProgress>();
  const downloadsById = useDownloadStore((state) => state.downloads);

  const playlist = usePlaylistStore((state) => state.playlists.find((item) => item.id === id));
  const removeTrackFromPlaylist = usePlaylistStore((state) => state.removeTrackFromPlaylist);
  const deletePlaylist = usePlaylistStore((state) => state.deletePlaylist);
  const remoteCollectionQuery = useQuery({
    queryKey: ["remote-collection", providerParam, sourceUrl],
    queryFn: async () => {
      if (!sourceUrl) {
        return undefined;
      }

      return sourceRegistry.importFromUrl(sourceUrl, providerParam ?? "all");
    },
    enabled: !playlist && Boolean(sourceUrl),
  });

  const remoteCollection = remoteCollectionQuery.data?.collection;
  const title = playlist?.title ?? fallbackTitle ?? remoteCollection?.title ?? "Playlist";
  const subtitle = playlist?.description ?? fallbackSubtitle;
  const artwork = (playlist?.artwork ?? remoteCollection?.artwork) as ArtworkLike | undefined;
  const tracks = useMemo(
    () => (playlist?.tracks ?? remoteCollectionQuery.data?.tracks ?? []) as Track[],
    [playlist?.tracks, remoteCollectionQuery.data?.tracks],
  );
  const uniquePlaylistTracks = useMemo(
    () => [...new Map(tracks.map((track) => [buildCanonicalTrackKey(track), track])).values()],
    [tracks],
  );
  const downloadedTrackCount = uniquePlaylistTracks.filter((track) =>
    Boolean(findDownloadForTrack(track, downloadsById)),
  ).length;
  const isPlaylistDownloaded = uniquePlaylistTracks.length > 0 && downloadedTrackCount === uniquePlaylistTracks.length;
  const isRemoteCollection = !playlist && Boolean(sourceUrl);
  const providers = useMemo(
    () => [...new Set(tracks.map((track) => track.provider))],
    [tracks],
  );
  const primaryProvider = providers.length === 1 ? providerLabels[providers[0]] : "Mixed sources";
  const leadArtist = tracks[0]?.artist;
  const heroSubtitle = subtitle ?? leadArtist ?? primaryProvider;

  const handlePlaylistDownload = async () => {
    if (!playlist || playlistDownloadProgress) {
      return;
    }
    if (!uniquePlaylistTracks.length) {
      toastService.show("Add a few tracks before downloading this playlist.");
      return;
    }
    if (isPlaylistDownloaded) {
      navigationService.push("/downloads", "Opening downloads…");
      return;
    }

    try {
      const result = await downloadService.downloadTracks(uniquePlaylistTracks, setPlaylistDownloadProgress);
      if (result.failed) {
        toastService.show(
          `Downloaded ${result.downloaded}; ${result.failed} ${result.failed === 1 ? "track" : "tracks"} failed.`,
        );
      } else if (!result.downloaded) {
        toastService.show("Every track in this playlist is already downloaded.");
      } else {
        toastService.show(
          `Downloaded ${formatCount(result.downloaded, "track")}${result.skipped ? `; skipped ${result.skipped} already saved` : ""}.`,
        );
      }
    } catch {
      toastService.show("Could not finish downloading this playlist.");
    } finally {
      setPlaylistDownloadProgress(undefined);
    }
  };

  if (!playlist && !sourceUrl) {
    return (
      <Screen>
        <Text variant="title">Playlist</Text>
        <Text muted>Playlist not found.</Text>
      </Screen>
    );
  }

  if (isRemoteCollection && remoteCollectionQuery.isLoading) {
    return (
      <Screen scroll={false} contentContainerStyle={styles.screenContent}>
        <View style={styles.centerState}>
          <ActivityIndicator size="small" color={theme.accent} />
          <Text variant="headline">{title}</Text>
          <Text muted>Loading collection…</Text>
        </View>
      </Screen>
    );
  }

  if (isRemoteCollection && (remoteCollectionQuery.isError || !remoteCollectionQuery.data)) {
    return (
      <Screen scroll={false} contentContainerStyle={styles.screenContent}>
        <View style={styles.centerState}>
          <Text variant="headline">{title}</Text>
          <Text muted>Could not load this collection right now.</Text>
        </View>
      </Screen>
    );
  }

  return (
    <Screen scroll={false} contentContainerStyle={styles.screenContent}>
      <View pointerEvents="none" style={styles.backgroundOrbs}>
        <View style={[styles.orb, styles.orbOne, { backgroundColor: theme.accent }]} />
        <View style={[styles.orb, styles.orbTwo, { backgroundColor: theme.accentAlt }]} />
      </View>

      <FlatList
        data={tracks}
        keyExtractor={(track) => `${id}-${track.id}`}
        showsVerticalScrollIndicator={false}
        contentContainerStyle={[
          styles.listContent,
          {
            paddingTop: Math.max(insets.top, 10),
            paddingBottom: styles.listContent.paddingBottom + contentBottomSpacing,
          },
        ]}
        ItemSeparatorComponent={() => <View style={styles.separator} />}
        ListHeaderComponent={
          <CollectionHeader
            artwork={artwork}
            downloadedTrackCount={downloadedTrackCount}
            downloadTargetCount={uniquePlaylistTracks.length}
            downloadProgress={playlistDownloadProgress}
            heroSubtitle={heroSubtitle}
            isLocalPlaylist={Boolean(playlist)}
            onDelete={() => {
              if (!playlist) {
                return;
              }

              deletePlaylist(playlist.id);
              router.back();
            }}
            onPlayAll={() => {
              if (!tracks.length) {
                toastService.show("Add a few tracks before playing this playlist.");
                return;
              }

              void playerService.playTrack(tracks[0], tracks).catch(() => {
                toastService.show("Could not start this collection.");
              });
            }}
            onDownloadAll={() => void handlePlaylistDownload()}
            title={title}
            trackCount={tracks.length}
          />
        }
        ListEmptyComponent={
          <View
            style={[
              styles.emptyState,
              {
                backgroundColor: `${theme.card}E8`,
                borderColor: `${theme.border}99`,
              },
            ]}
          >
            <Text variant="headline">No tracks here yet.</Text>
          </View>
        }
        renderItem={({ item, index }) => (
          <CollectionTrackRow index={index} queue={tracks} track={item} onLongPress={setSelectedTrack} />
        )}
      />

      {selectedTrack ? (
        <TrackDetailsSheet
          playlist={playlist}
          selectedTrack={selectedTrack}
          title={title}
          onAddToPlaylist={(track) => {
            setPlaylistTrack(track);
            setSelectedTrack(null);
          }}
          onClose={() => setSelectedTrack(null)}
          onRemoveFromPlaylist={(track) => {
            if (!playlist) {
              return;
            }

            removeTrackFromPlaylist(playlist.id, track.id);
            setSelectedTrack(null);
            toastService.show(`Removed from ${playlist.title}.`);
          }}
        />
      ) : null}

      <AddToPlaylistSheet
        visible={Boolean(playlistTrack)}
        track={playlistTrack}
        onClose={() => setPlaylistTrack(null)}
        bottomOffset={92}
      />
    </Screen>
  );
}

const CollectionHeader = ({
  artwork,
  downloadedTrackCount,
  downloadTargetCount,
  downloadProgress,
  heroSubtitle,
  isLocalPlaylist,
  onDelete,
  onDownloadAll,
  onPlayAll,
  title,
  trackCount,
}: {
  artwork?: ArtworkLike;
  downloadedTrackCount: number;
  downloadTargetCount: number;
  downloadProgress?: DownloadBatchProgress;
  heroSubtitle?: string;
  isLocalPlaylist: boolean;
  onDelete: () => void;
  onDownloadAll: () => void;
  onPlayAll: () => void;
  title: string;
  trackCount: number;
}) => {
  const theme = useTheme();

  return (
    <View style={styles.header}>
      <Pressable onPress={() => router.back()} style={[styles.backButton, { backgroundColor: `${theme.background}D9`, borderColor: `${theme.border}99` }]}>
        <SymbolIcon name="navBack" size={18} color={theme.text} />
      </Pressable>

      <LinearGradient
        colors={[`${theme.accent}22`, `${theme.accentAlt}18`, `${theme.card}F0`]}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
        style={[styles.heroCard, { borderColor: `${theme.border}D9` }]}
      >
        <View style={styles.heroTop}>
          <CachedArtwork artwork={artwork} category="playlist" variant="hero" width={118} height={118} borderRadius={32} />
          <View style={styles.heroCopy}>
            <Text variant="title" numberOfLines={3} style={styles.heroTitle}>
              {title}
            </Text>
            {heroSubtitle ? (
              <Text muted numberOfLines={2} style={styles.heroSubtitle}>
                {heroSubtitle}
              </Text>
            ) : null}
          </View>
        </View>

        <View style={styles.heroMetaRow}>
          <View style={[styles.metaChip, { backgroundColor: `${theme.background}C7`, borderColor: `${theme.border}66` }]}>
            <Text muted>{formatCount(trackCount, "track")}</Text>
          </View>
          <View style={[styles.metaChip, { backgroundColor: `${theme.background}B0`, borderColor: `${theme.border}55` }]}>
            <Text muted numberOfLines={1}>{heroSubtitle || "Ready to play"}</Text>
          </View>
          {isLocalPlaylist && downloadedTrackCount ? (
            <View style={[styles.metaChip, { backgroundColor: `${theme.accent}16`, borderColor: `${theme.accent}44` }]}>
              <Text style={{ color: theme.accent }}>{downloadedTrackCount} offline</Text>
            </View>
          ) : null}
        </View>

        <View style={styles.heroActions}>
          <Pressable onPress={onPlayAll} style={[styles.playButton, { backgroundColor: theme.accent }]}>
            <SymbolIcon name="play" size={16} color={theme.background} />
            <Text style={{ color: theme.background }}>Play All</Text>
          </Pressable>
          {isLocalPlaylist ? (
            <>
              <Pressable
                disabled={Boolean(downloadProgress)}
                onPress={onDownloadAll}
                style={[
                  styles.downloadButton,
                  {
                    backgroundColor: `${theme.background}C2`,
                    borderColor: downloadedTrackCount === downloadTargetCount && downloadTargetCount > 0 ? `${theme.accent}66` : `${theme.border}88`,
                  },
                ]}
              >
                {downloadProgress ? (
                  <ActivityIndicator size="small" color={theme.accent} />
                ) : (
                  <SymbolIcon
                    name={downloadedTrackCount === downloadTargetCount && downloadTargetCount > 0 ? "checkCircle" : "download"}
                    size={16}
                    color={theme.accent}
                  />
                )}
                <Text style={{ color: theme.accent }}>
                  {downloadProgress
                    ? `${downloadProgress.completed}/${downloadProgress.total}`
                    : downloadedTrackCount === downloadTargetCount && downloadTargetCount > 0
                      ? "Downloaded"
                      : downloadedTrackCount
                        ? "Download Rest"
                        : "Download All"}
                </Text>
              </Pressable>
              <Pressable onPress={onDelete} style={[styles.secondaryAction, { backgroundColor: `${theme.background}C2`, borderColor: `${theme.border}88` }]}>
                <Text muted>Delete</Text>
              </Pressable>
            </>
          ) : null}
        </View>
        {downloadProgress ? (
          <View style={styles.downloadProgress}>
            <ProgressBar
              progress={downloadProgress.total ? downloadProgress.completed / downloadProgress.total : 0}
            />
            <Text muted variant="caption">
              Saving playlist · {downloadProgress.completed} of {downloadProgress.total}
            </Text>
          </View>
        ) : null}
      </LinearGradient>

      <View style={styles.listIntro}>
        <Text variant="headline">Tracks</Text>
      </View>
    </View>
  );
};

const TrackDetailsSheet = ({
  playlist,
  selectedTrack,
  title,
  onAddToPlaylist,
  onClose,
  onRemoveFromPlaylist,
}: {
  playlist?: Playlist;
  selectedTrack: Track;
  title: string;
  onAddToPlaylist: (track: Track) => void;
  onClose: () => void;
  onRemoveFromPlaylist: (track: Track) => void;
}) => {
  const theme = useTheme();
  const insets = useSafeAreaInsets();
  const { contentBottomSpacing } = useMiniPlayerLayout();
  const selectedDownload = useDownloadStore((state) => findDownloadForTrack(selectedTrack, state.downloads));
  const selectedDownloadTask = useDownloadStore((state) => state.tasks[selectedTrack.id]);

  return (
    <View style={styles.overlay}>
      <Pressable style={styles.backdrop} onPress={onClose} />
      <ScrollView
        bounces={false}
        showsVerticalScrollIndicator={false}
        style={[
          styles.detailSheet,
          {
            backgroundColor: theme.background,
            marginBottom: Math.max(insets.bottom, 8) + contentBottomSpacing,
          },
        ]}
        contentContainerStyle={[styles.detailSheetContent, { paddingBottom: 24 }]}
      >
        <View style={[styles.sheetHandle, { backgroundColor: theme.textMuted }]} />
        <View style={styles.detailTopBar}>
          <Text muted variant="caption" style={styles.detailTopTitle}>
            Track Details
          </Text>
          <Pressable onPress={onClose} style={styles.detailCloseButton}>
            <Text style={{ color: theme.accent }}>Close</Text>
          </Pressable>
        </View>
        <View style={styles.detailHeader}>
          <CachedArtwork artwork={selectedTrack.artwork} category="track" variant="thumbnail" width={72} height={72} borderRadius={22} />
          <View style={styles.detailMeta}>
            <Text variant="headline" style={styles.detailTitle}>
              {selectedTrack.title}
            </Text>
            <Text muted>{selectedTrack.artist}</Text>
          </View>
        </View>
        <View style={styles.detailGrid}>
          <View style={[styles.detailPill, { backgroundColor: theme.surface }]}>
            <Text muted variant="caption">
              Provider
            </Text>
            <Text>{providerLabels[selectedTrack.provider]}</Text>
          </View>
          <View style={[styles.detailPill, { backgroundColor: theme.surface }]}>
            <Text muted variant="caption">
              Duration
            </Text>
            <Text>{formatDuration(selectedTrack.duration)}</Text>
          </View>
          <View style={[styles.detailPill, { backgroundColor: theme.surface }]}>
            <Text muted variant="caption">
              Collection
            </Text>
            <Text numberOfLines={1}>{title}</Text>
          </View>
        </View>
        {selectedTrack.album ? (
          <View style={[styles.detailBlock, { backgroundColor: theme.surface, borderColor: `${theme.border}88` }]}>
            <Text muted variant="caption">
              Album
            </Text>
            <Text>{selectedTrack.album}</Text>
          </View>
        ) : null}
        {selectedTrack.sourceUrl ? (
          <View style={[styles.detailBlock, { backgroundColor: theme.surface, borderColor: `${theme.border}88` }]}>
            <Text muted variant="caption">
              Source Link
            </Text>
            <Text numberOfLines={2}>{selectedTrack.sourceUrl}</Text>
          </View>
        ) : null}
        <View style={[styles.detailBlock, { backgroundColor: theme.surface, borderColor: `${theme.border}88` }]}>
          <Text muted variant="caption">
            Actions
          </Text>
          <View style={styles.sheetActionList}>
            <Pressable
              onPress={() => {
                if (selectedDownload || selectedDownloadTask?.status === "queued" || selectedDownloadTask?.status === "downloading" || selectedDownloadTask?.status === "resolving") {
                  onClose();
                  navigationService.push("/downloads", "Opening downloads…");
                  return;
                }
                void downloadService.downloadTrack(selectedTrack).then(
                  () => toastService.show(`Downloaded ${selectedTrack.title}.`),
                  () => toastService.show("Download failed. Check your connection and try again."),
                );
              }}
              style={[styles.sheetActionButton, { borderColor: theme.accent, backgroundColor: `${theme.accent}14` }]}
            >
              <Text style={{ color: theme.accent }}>
                {selectedDownload
                  ? "Manage download"
                  : selectedDownloadTask?.status === "queued"
                    ? `Queued #${selectedDownloadTask.queuePosition ?? 1}`
                    : selectedDownloadTask?.status === "downloading" || selectedDownloadTask?.status === "resolving"
                    ? "Downloading…"
                    : selectedDownloadTask?.status === "failed"
                      ? "Retry download"
                      : "Download"}
              </Text>
            </Pressable>
            <Pressable
              onPress={() => onAddToPlaylist(selectedTrack)}
              style={[styles.sheetActionButton, { borderColor: theme.accent, backgroundColor: `${theme.accent}14` }]}
            >
              <Text style={{ color: theme.accent }}>Add to playlist</Text>
            </Pressable>
            {playlist ? (
              <Pressable
                onPress={() => onRemoveFromPlaylist(selectedTrack)}
                style={[styles.sheetActionButton, { borderColor: `${theme.border}99`, backgroundColor: `${theme.background}B8` }]}
              >
                <Text muted>Remove from this playlist</Text>
              </Pressable>
            ) : null}
          </View>
        </View>
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  screenContent: {
    flex: 1,
    padding: 0,
    gap: 0,
  },
  backgroundOrbs: {
    ...StyleSheet.absoluteFillObject,
    overflow: "hidden",
  },
  orb: {
    position: "absolute",
    width: 300,
    height: 300,
    borderRadius: 999,
    opacity: 0.1,
  },
  orbOne: {
    top: -30,
    right: -110,
  },
  orbTwo: {
    top: 220,
    left: -140,
  },
  centerState: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    gap: 10,
    paddingHorizontal: 28,
  },
  listContent: {
    paddingHorizontal: 20,
    paddingBottom: 120,
  },
  header: {
    gap: 18,
    paddingBottom: 20,
  },
  backButton: {
    width: 42,
    height: 42,
    borderRadius: 999,
    borderWidth: 1,
    alignItems: "center",
    justifyContent: "center",
  },
  heroCard: {
    borderRadius: 34,
    borderWidth: 1,
    padding: 18,
    gap: 16,
    overflow: "hidden",
  },
  heroTop: {
    flexDirection: "row",
    alignItems: "center",
    gap: 16,
  },
  heroCopy: {
    flex: 1,
    gap: 8,
  },
  heroTitle: {
    lineHeight: 31,
  },
  heroSubtitle: {
    maxWidth: "95%",
  },
  heroMetaRow: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 10,
  },
  metaChip: {
    borderRadius: 999,
    borderWidth: 1,
    paddingHorizontal: 12,
    paddingVertical: 7,
  },
  heroActions: {
    flexDirection: "row",
    flexWrap: "wrap",
    alignItems: "center",
    gap: 10,
  },
  playButton: {
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
    borderRadius: 999,
    paddingHorizontal: 18,
    paddingVertical: 12,
  },
  secondaryAction: {
    borderWidth: 1,
    borderRadius: 999,
    paddingHorizontal: 14,
    paddingVertical: 12,
  },
  downloadButton: {
    flexDirection: "row",
    alignItems: "center",
    gap: 7,
    borderWidth: 1,
    borderRadius: 999,
    paddingHorizontal: 14,
    paddingVertical: 12,
  },
  downloadProgress: {
    gap: 2,
  },
  listIntro: {
    gap: 0,
  },
  separator: {
    height: 6,
  },
  emptyState: {
    borderRadius: 28,
    borderWidth: 1,
    padding: 20,
    gap: 10,
  },
  row: {
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
    borderRadius: 22,
    borderWidth: 1,
    paddingHorizontal: 4,
    paddingVertical: 10,
    overflow: "hidden",
  },
  rowGlow: {
    ...StyleSheet.absoluteFillObject,
  },
  rowIndexWrap: {
    width: 34,
    height: 34,
    borderRadius: 999,
    borderWidth: 1,
    alignItems: "center",
    justifyContent: "center",
  },
  rowIndex: {
    fontSize: 11,
  },
  rowMeta: {
    flex: 1,
    gap: 3,
    paddingBottom: 10,
    borderBottomWidth: StyleSheet.hairlineWidth,
  },
  rowTitle: {
    fontSize: 16,
    lineHeight: 21,
  },
  rowTags: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 8,
    marginTop: 2,
  },
  rowSide: {
    alignItems: "flex-end",
    gap: 8,
    paddingBottom: 10,
  },
  morePill: {
    width: 28,
    height: 28,
    borderRadius: 999,
    borderWidth: 1,
    alignItems: "center",
    justifyContent: "center",
  },
  tag: {
    maxWidth: "100%",
    borderRadius: 999,
    paddingHorizontal: 8,
    paddingVertical: 4,
  },
  tagText: {
    fontSize: 11,
  },
  overlay: {
    ...StyleSheet.absoluteFillObject,
    justifyContent: "flex-end",
  },
  backdrop: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: "rgba(0,0,0,0.42)",
  },
  detailSheet: {
    flexGrow: 0,
    borderTopLeftRadius: 30,
    borderTopRightRadius: 30,
    maxHeight: "68%",
  },
  detailSheetContent: {
    paddingHorizontal: 20,
    paddingTop: 16,
    gap: 18,
  },
  sheetHandle: {
    alignSelf: "center",
    width: 42,
    height: 5,
    borderRadius: 999,
    opacity: 0.5,
  },
  detailTopBar: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
  },
  detailTopTitle: {
    letterSpacing: 1.1,
  },
  detailCloseButton: {
    paddingVertical: 4,
  },
  detailHeader: {
    flexDirection: "row",
    alignItems: "center",
    gap: 14,
  },
  detailMeta: {
    flex: 1,
    gap: 4,
  },
  detailTitle: {
    lineHeight: 22,
  },
  detailGrid: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 10,
  },
  detailPill: {
    minWidth: "30%",
    borderRadius: 18,
    paddingHorizontal: 14,
    paddingVertical: 12,
    gap: 4,
  },
  detailBlock: {
    borderRadius: 22,
    borderWidth: 1,
    padding: 16,
    gap: 10,
  },
  sheetActionList: {
    gap: 10,
  },
  sheetActionButton: {
    borderRadius: 16,
    borderWidth: 1,
    paddingHorizontal: 14,
    paddingVertical: 12,
  },
});
