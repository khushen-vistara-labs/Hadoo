import { router } from "expo-router";
import { useMemo } from "react";
import { Alert, FlatList, Pressable, StyleSheet, View } from "react-native";

import { CachedArtwork } from "@/components/artwork/CachedArtwork";
import { CircularDownloadIndicator } from "@/components/downloads/CircularDownloadIndicator";
import { Screen } from "@/components/ui/Screen";
import { SymbolIcon } from "@/components/ui/SymbolIcon";
import { Text } from "@/components/ui/Text";
import { providerLabels } from "@/constants/providers";
import { useMiniPlayerLayout } from "@/hooks/useMiniPlayerLayout";
import { useTheme } from "@/hooks/useTheme";
import { downloadService } from "@/modules/downloads/downloadService";
import { useDownloadStore, type DownloadTask, type DownloadedTrack } from "@/modules/downloads/downloadStore";
import { playerService } from "@/modules/player/playerService";
import { toastService } from "@/services/toastService";
import type { Track } from "@/types/track";

type DownloadRow = {
  id: string;
  track: Track;
  download?: DownloadedTrack;
  task?: DownloadTask;
};

const formatBytes = (bytes: number) => {
  if (bytes < 1024) {
    return `${bytes} B`;
  }
  if (bytes < 1024 * 1024) {
    return `${(bytes / 1024).toFixed(1)} KB`;
  }
  if (bytes < 1024 * 1024 * 1024) {
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
  }
  return `${(bytes / (1024 * 1024 * 1024)).toFixed(1)} GB`;
};

export default function DownloadsScreen() {
  const theme = useTheme();
  const { contentBottomSpacing } = useMiniPlayerLayout();
  const downloadsById = useDownloadStore((state) => state.downloads);
  const tasksById = useDownloadStore((state) => state.tasks);

  const downloads = useMemo(
    () => Object.values(downloadsById).sort((left, right) => right.downloadedAt - left.downloadedAt),
    [downloadsById],
  );
  const rows = useMemo<DownloadRow[]>(() => {
    const activeRows = Object.entries(tasksById)
      .filter(([id]) => !downloadsById[id])
      .map(([id, task]) => ({ id, track: task.track, task }))
      .sort((left, right) => {
        const statusRank = { downloading: 0, resolving: 0, queued: 1, failed: 2 } as const;
        const rankDelta = statusRank[left.task.status] - statusRank[right.task.status];
        return rankDelta || (left.task.queuePosition ?? 0) - (right.task.queuePosition ?? 0);
      });
    return [
      ...activeRows,
      ...downloads.map((download) => ({
        id: download.id,
        track: download.track,
        download,
        task: tasksById[download.id],
      })),
    ];
  }, [downloads, downloadsById, tasksById]);
  const totalBytes = downloads.reduce((sum, download) => sum + download.bytes, 0);
  const queue = downloads.map((download) => download.track);
  const ongoingTasks = Object.values(tasksById).filter((task) => task.status !== "failed");
  const queuedCount = ongoingTasks.filter((task) => task.status === "queued").length;
  const activeCount = ongoingTasks.length - queuedCount;

  return (
    <Screen scroll={false} contentContainerStyle={styles.screenContent}>
      <View pointerEvents="none" style={styles.backgroundOrbs}>
        <View style={[styles.orb, styles.orbOne, { backgroundColor: theme.accent }]} />
        <View style={[styles.orb, styles.orbTwo, { backgroundColor: theme.accentAlt }]} />
      </View>

      <View style={styles.header}>
        <Pressable
          onPress={() => router.back()}
          style={[styles.backButton, { backgroundColor: `${theme.card}D9`, borderColor: `${theme.border}99` }]}
        >
          <SymbolIcon name="navBack" size={18} color={theme.text} />
        </Pressable>
        <View style={styles.headerCopy}>
          <Text muted variant="caption" style={{ color: theme.accent }}>
            OFFLINE LIBRARY
          </Text>
          <Text variant="title">Downloads</Text>
          <Text muted>Saved audio plays from this device before Hadoo tries the network.</Text>
        </View>
      </View>

      <View style={[styles.summaryCard, { backgroundColor: `${theme.card}DC`, borderColor: `${theme.border}99` }]}>
        <View style={[styles.summaryIcon, { backgroundColor: `${theme.accent}18` }]}>
          <SymbolIcon name="download" size={22} color={theme.accent} />
        </View>
        <View style={styles.summaryCopy}>
          <Text variant="headline">{downloads.length} {downloads.length === 1 ? "track" : "tracks"}</Text>
          <Text muted>
            {ongoingTasks.length
              ? `${activeCount} active${queuedCount ? ` · ${queuedCount} queued` : ""}`
              : `${formatBytes(totalBytes)} stored in Hadoo`}
          </Text>
        </View>
      </View>

      <FlatList
        data={rows}
        style={styles.list}
        keyExtractor={(item) => item.id}
        contentContainerStyle={{ paddingBottom: 24 + contentBottomSpacing }}
        showsVerticalScrollIndicator={false}
        ItemSeparatorComponent={() => <View style={styles.separator} />}
        ListEmptyComponent={
          <View style={[styles.emptyState, { backgroundColor: `${theme.card}D0`, borderColor: `${theme.border}88` }]}>
            <View style={[styles.emptyIcon, { backgroundColor: `${theme.accentAlt}16` }]}>
              <SymbolIcon name="download" size={24} color={theme.accentAlt} />
            </View>
            <Text variant="headline">Nothing downloaded yet</Text>
            <Text muted>Open a track’s options and choose Download to keep it available offline.</Text>
          </View>
        }
        renderItem={({ item }) => (
          <DownloadTrackRow
            row={item}
            onPlay={() => {
              const trackQueue = queue.length ? queue : [item.track];
              void playerService.playTrack(item.track, trackQueue).catch(() => {
                toastService.show("Could not play this download.");
              });
            }}
            onRemove={() => {
              const isPending = item.task?.status === "queued" || item.task?.status === "resolving" || item.task?.status === "downloading";
              Alert.alert(
                isPending ? "Cancel download?" : item.task?.status === "failed" ? "Dismiss download?" : "Remove download?",
                isPending
                  ? `Stop downloading “${item.track.title}”?`
                  : item.task?.status === "failed"
                    ? `Dismiss the failed download for “${item.track.title}”?`
                    : `“${item.track.title}” will no longer be available offline.`,
                [
                  { text: "Cancel", style: "cancel" },
                  {
                    text: "Remove",
                    style: "destructive",
                    onPress: () => {
                      void downloadService.removeDownload(item.id).catch(() => {
                        toastService.show("Could not remove this download.");
                      });
                    },
                  },
                ],
              );
            }}
            onRetry={() => {
              void downloadService.downloadTrack(item.track).catch(() => {
                toastService.show("Download failed. Check your connection and try again.");
              });
            }}
          />
        )}
      />
    </Screen>
  );
}

const DownloadTrackRow = ({
  onPlay,
  onRemove,
  onRetry,
  row,
}: {
  onPlay: () => void;
  onRemove: () => void;
  onRetry: () => void;
  row: DownloadRow;
}) => {
  const theme = useTheme();
  const isDownloading = row.task?.status === "resolving" || row.task?.status === "downloading";
  const isQueued = row.task?.status === "queued";
  const isPending = isQueued || isDownloading;
  const isFailed = row.task?.status === "failed";

  return (
    <View style={[styles.trackCard, { backgroundColor: `${theme.card}D9`, borderColor: `${theme.border}88` }]}>
      <Pressable disabled={!row.download} onPress={onPlay} style={styles.trackMain}>
        <CachedArtwork artwork={row.track.artwork} category="track" variant="thumbnail" width={58} height={58} borderRadius={18} />
        <View style={styles.trackMeta}>
          <Text numberOfLines={1}>{row.track.title}</Text>
          <Text muted numberOfLines={1}>{row.track.artist}</Text>
          <Text muted variant="caption" numberOfLines={1}>
            {row.download
              ? `${providerLabels[row.track.provider]} · ${formatBytes(row.download.bytes)} · ${row.download.quality}`
              : isFailed
                ? row.task?.error ?? "Download failed"
                : isQueued
                  ? `Queued · position ${row.task?.queuePosition ?? 1}`
                  : row.task?.status === "resolving"
                    ? "Preparing download…"
                    : row.task?.totalBytes
                      ? `${Math.round(row.task.progress * 100)}% · ${formatBytes(row.task.bytesWritten)}`
                      : "Downloading…"}
          </Text>
        </View>
        {row.download ? (
          <View style={[styles.playButton, { backgroundColor: `${theme.accent}18` }]}>
            <SymbolIcon name="play" size={17} color={theme.accent} />
          </View>
        ) : row.task ? (
          <CircularDownloadIndicator task={row.task} />
        ) : null}
      </Pressable>

      <View style={styles.rowActions}>
        {isFailed ? (
          <Pressable onPress={onRetry} style={[styles.actionButton, { backgroundColor: `${theme.accent}14` }]}>
            <SymbolIcon name="refresh" size={15} color={theme.accent} />
            <Text style={{ color: theme.accent }}>Retry</Text>
          </Pressable>
        ) : null}
        <Pressable onPress={onRemove} style={[styles.actionButton, { backgroundColor: `${theme.surfaceAlt}B8` }]}>
          <Text muted>{isPending ? "Cancel" : isFailed ? "Dismiss" : "Remove"}</Text>
        </Pressable>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  screenContent: {
    flex: 1,
    padding: 20,
    gap: 18,
  },
  backgroundOrbs: {
    ...StyleSheet.absoluteFillObject,
    overflow: "hidden",
  },
  orb: {
    position: "absolute",
    width: 280,
    height: 280,
    borderRadius: 999,
    opacity: 0.09,
  },
  orbOne: {
    top: -80,
    right: -120,
  },
  orbTwo: {
    top: 300,
    left: -150,
  },
  header: {
    flexDirection: "row",
    alignItems: "flex-start",
    gap: 14,
  },
  backButton: {
    width: 42,
    height: 42,
    borderRadius: 999,
    borderWidth: 1,
    alignItems: "center",
    justifyContent: "center",
  },
  headerCopy: {
    flex: 1,
    gap: 5,
  },
  summaryCard: {
    borderRadius: 26,
    borderWidth: 1,
    padding: 16,
    flexDirection: "row",
    alignItems: "center",
    gap: 13,
  },
  summaryIcon: {
    width: 46,
    height: 46,
    borderRadius: 999,
    alignItems: "center",
    justifyContent: "center",
  },
  summaryCopy: {
    flex: 1,
    gap: 3,
  },
  separator: {
    height: 12,
  },
  list: {
    flex: 1,
  },
  emptyState: {
    borderRadius: 28,
    borderWidth: 1,
    padding: 24,
    alignItems: "center",
    gap: 10,
  },
  emptyIcon: {
    width: 50,
    height: 50,
    borderRadius: 999,
    alignItems: "center",
    justifyContent: "center",
  },
  trackCard: {
    borderRadius: 24,
    borderWidth: 1,
    padding: 12,
    gap: 10,
  },
  trackMain: {
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
  },
  trackMeta: {
    flex: 1,
    gap: 4,
  },
  playButton: {
    width: 36,
    height: 36,
    borderRadius: 999,
    alignItems: "center",
    justifyContent: "center",
  },
  rowActions: {
    flexDirection: "row",
    justifyContent: "flex-end",
    gap: 8,
  },
  actionButton: {
    minHeight: 34,
    borderRadius: 999,
    paddingHorizontal: 13,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: 6,
  },
});
