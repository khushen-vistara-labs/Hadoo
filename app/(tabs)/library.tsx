import { useMemo, useState } from "react";
import { Pressable, ScrollView, StyleSheet, TextInput, View } from "react-native";

import { CachedArtwork } from "@/components/artwork/CachedArtwork";
import { Button } from "@/components/ui/Button";
import { Screen } from "@/components/ui/Screen";
import { SymbolIcon } from "@/components/ui/SymbolIcon";
import { Text } from "@/components/ui/Text";
import { useTheme } from "@/hooks/useTheme";
import { useLibraryStore } from "@/modules/library/libraryStore";
import { usePlaylistStore } from "@/modules/playlists/playlistStore";
import { navigationService } from "@/services/navigationService";
import { toastService } from "@/services/toastService";
import { formatCount } from "@/utils/formatCount";

const formatUpdatedTime = (updatedAt: number) => {
  const deltaMs = Date.now() - updatedAt;
  const deltaHours = Math.max(Math.floor(deltaMs / (60 * 60 * 1000)), 0);

  if (deltaHours < 1) {
    return "Updated just now";
  }

  if (deltaHours < 24) {
    return `Updated ${deltaHours}h ago`;
  }

  const deltaDays = Math.floor(deltaHours / 24);
  if (deltaDays < 7) {
    return `Updated ${deltaDays}d ago`;
  }

  return `Updated ${Math.floor(deltaDays / 7)}w ago`;
};

export default function LibraryScreen() {
  const theme = useTheme();
  const likedSongs = useLibraryStore((state) => state.likedSongs);
  const recentlyPlayed = useLibraryStore((state) => state.recentlyPlayed);
  const playlists = usePlaylistStore((state) => state.playlists);
  const createPlaylist = usePlaylistStore((state) => state.createPlaylist);
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");

  const orderedPlaylists = useMemo(
    () => [...playlists].sort((left, right) => right.updatedAt - left.updatedAt),
    [playlists],
  );

  const submitPlaylist = () => {
    const playlist = createPlaylist({ title, description });
    if (!playlist) {
      toastService.show("Playlist title cannot be empty.");
      return;
    }

    setTitle("");
    setDescription("");
    toastService.show(`Created ${playlist.title}.`);
    navigationService.push(`/playlist/${playlist.id}`, "Opening playlist…");
  };

  return (
    <Screen>
      <View pointerEvents="none" style={styles.backgroundOrbs}>
        <View style={[styles.orb, styles.orbOne, { backgroundColor: theme.accent }]} />
        <View style={[styles.orb, styles.orbTwo, { backgroundColor: theme.accentAlt }]} />
      </View>

      <View style={styles.header}>
        <Text variant="title">Library</Text>
      </View>

      <View style={styles.statRow}>
        <LibraryStatCard
          icon="heart"
          label="Liked Songs"
          value={likedSongs.length}
          caption="saved"
        />
        <LibraryStatCard
          icon="time"
          label="Recently Played"
          value={recentlyPlayed.length}
          caption="recent"
        />
        <LibraryStatCard
          icon="playlist"
          label="Playlists"
          value={orderedPlaylists.length}
          caption="lists"
        />
      </View>

      <View style={styles.section}>
        <View style={styles.sectionHeader}>
          <Text variant="headline">Playlists</Text>
        </View>

        <View style={styles.playlistList}>
          {orderedPlaylists.length ? (
            orderedPlaylists.map((playlist, index) => (
              <Pressable
                key={playlist.id}
                onPress={() => navigationService.push(`/playlist/${playlist.id}`, "Opening playlist…")}
                style={({ pressed }) => [
                  styles.playlistRow,
                  {
                    backgroundColor: pressed ? `${theme.surfaceAlt}D8` : `${theme.card}D0`,
                    borderColor: pressed ? `${theme.accent}55` : `${theme.border}88`,
                  },
                ]}
              >
                <View style={[styles.rowIndexWrap, { backgroundColor: `${theme.background}C2`, borderColor: `${theme.border}55` }]}>
                  <Text muted style={styles.rowIndex}>
                    {String(index + 1).padStart(2, "0")}
                  </Text>
                </View>
                <CachedArtwork
                  artwork={playlist.artwork}
                  fallbackArtwork={playlist.tracks[0]?.artwork}
                  category="playlist"
                  variant="thumbnail"
                  width={58}
                  height={58}
                  borderRadius={20}
                />
                <View style={styles.playlistMeta}>
                  <Text numberOfLines={1}>{playlist.title}</Text>
                  {playlist.description ? <Text muted numberOfLines={1}>{playlist.description}</Text> : null}
                  <Text muted numberOfLines={1}>
                    {formatCount(playlist.tracks.length, "track")} · {formatUpdatedTime(playlist.updatedAt)}
                  </Text>
                </View>
                <SymbolIcon name="forward" size={18} color={theme.textMuted} />
              </Pressable>
            ))
          ) : (
            <View style={[styles.emptyState, { backgroundColor: `${theme.card}E8`, borderColor: `${theme.border}99` }]}>
              <Text variant="headline">No playlists yet.</Text>
            </View>
          )}
        </View>
      </View>

      <View style={styles.section}>
        <View style={styles.sectionHeader}>
          <Text variant="headline">Create New</Text>
        </View>

        <View style={[styles.createCard, { backgroundColor: `${theme.card}E6`, borderColor: `${theme.border}A8` }]}>
          <TextInput
            value={title}
            onChangeText={setTitle}
            placeholder="Playlist title"
            placeholderTextColor={theme.textMuted}
            style={[styles.input, { color: theme.text, backgroundColor: `${theme.background}BA`, borderColor: `${theme.border}66` }]}
          />
          <TextInput
            value={description}
            onChangeText={setDescription}
            placeholder="Short note (optional)"
            placeholderTextColor={theme.textMuted}
            style={[styles.input, { color: theme.text, backgroundColor: `${theme.background}BA`, borderColor: `${theme.border}66` }]}
          />
          <Button label="Create Playlist" onPress={submitPlaylist} />
        </View>
      </View>

      <View style={styles.utilityGrid}>
        <UtilityCard
          icon="download"
          title="Downloads"
        />
        <UtilityCard
          icon="folder"
          title="Local Files"
        />
      </View>
    </Screen>
  );
}

const LibraryStatCard = ({
  caption,
  icon,
  label,
  value,
}: {
  caption: string;
  icon: "heart" | "time" | "playlist";
  label: string;
  value: number;
}) => {
  const theme = useTheme();

  return (
    <View style={[styles.statCard, { backgroundColor: `${theme.card}D9`, borderColor: `${theme.border}88` }]}>
      <View style={[styles.statIcon, { backgroundColor: `${theme.accent}16` }]}>
        <SymbolIcon name={icon} size={16} color={theme.accent} />
      </View>
      <Text muted style={styles.statLabel}>
        {label}
      </Text>
      <View style={styles.statValueRow}>
        <Text variant="headline">{value}</Text>
        <Text muted>{caption}</Text>
      </View>
    </View>
  );
};

const UtilityCard = ({
  icon,
  title,
}: {
  icon: "download" | "folder";
  title: string;
}) => {
  const theme = useTheme();

  return (
    <View style={[styles.utilityCard, { backgroundColor: `${theme.card}D0`, borderColor: `${theme.border}88` }]}>
      <View style={[styles.utilityIcon, { backgroundColor: `${theme.accentAlt}16` }]}>
        <SymbolIcon name={icon} size={18} color={theme.accentAlt} />
      </View>
      <Text variant="headline">{title}</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  backgroundOrbs: {
    ...StyleSheet.absoluteFillObject,
    overflow: "hidden",
  },
  orb: {
    position: "absolute",
    width: 260,
    height: 260,
    borderRadius: 999,
    opacity: 0.09,
  },
  orbOne: {
    top: -40,
    right: -100,
  },
  orbTwo: {
    top: 260,
    left: -120,
  },
  header: {
    gap: 2,
  },
  statRow: {
    flexDirection: "row",
    gap: 10,
  },
  statCard: {
    flex: 1,
    borderRadius: 24,
    borderWidth: 1,
    padding: 14,
    gap: 10,
  },
  statIcon: {
    width: 34,
    height: 34,
    borderRadius: 999,
    alignItems: "center",
    justifyContent: "center",
  },
  statLabel: {
    fontSize: 12,
  },
  statValueRow: {
    flexDirection: "row",
    alignItems: "baseline",
    gap: 6,
  },
  section: {
    gap: 14,
  },
  sectionHeader: {
    gap: 4,
  },
  playlistList: {
    gap: 10,
  },
  playlistRow: {
    borderWidth: 1,
    borderRadius: 24,
    padding: 12,
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
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
  playlistMeta: {
    flex: 1,
    gap: 4,
  },
  emptyState: {
    borderRadius: 28,
    borderWidth: 1,
    padding: 18,
    gap: 8,
  },
  createCard: {
    borderRadius: 28,
    borderWidth: 1,
    padding: 14,
    gap: 10,
  },
  input: {
    borderWidth: 1,
    borderRadius: 16,
    paddingHorizontal: 14,
    paddingVertical: 12,
  },
  utilityGrid: {
    flexDirection: "row",
    gap: 10,
  },
  utilityCard: {
    flex: 1,
    borderRadius: 26,
    borderWidth: 1,
    padding: 16,
    gap: 10,
  },
  utilityIcon: {
    width: 36,
    height: 36,
    borderRadius: 999,
    alignItems: "center",
    justifyContent: "center",
  },
});
