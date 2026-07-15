import { LinearGradient } from "expo-linear-gradient";
import { useMemo, useState } from "react";
import { Pressable, ScrollView, StyleSheet, TextInput, View } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";

import { CachedArtwork } from "@/components/artwork/CachedArtwork";
import { Button } from "@/components/ui/Button";
import { SymbolIcon } from "@/components/ui/SymbolIcon";
import { Text } from "@/components/ui/Text";
import { useMiniPlayerLayout } from "@/hooks/useMiniPlayerLayout";
import { useTheme } from "@/hooks/useTheme";
import { usePlaylistStore } from "@/modules/playlists/playlistStore";
import { toastService } from "@/services/toastService";
import type { Track } from "@/types/track";
import { formatCount } from "@/utils/formatCount";

type Props = {
  visible: boolean;
  track: Track | null;
  onClose: () => void;
  bottomOffset?: number;
};

const formatUpdatedTime = (updatedAt: number) => {
  const deltaMs = Date.now() - updatedAt;
  const deltaHours = Math.max(Math.floor(deltaMs / (60 * 60 * 1000)), 0);

  if (deltaHours < 1) {
    return "Just now";
  }

  if (deltaHours < 24) {
    return `${deltaHours}h ago`;
  }

  const deltaDays = Math.floor(deltaHours / 24);
  if (deltaDays < 7) {
    return `${deltaDays}d ago`;
  }

  return `${Math.floor(deltaDays / 7)}w ago`;
};

export const AddToPlaylistSheet = ({ visible, track, onClose, bottomOffset = 0 }: Props) => {
  const theme = useTheme();
  const insets = useSafeAreaInsets();
  const { contentBottomSpacing } = useMiniPlayerLayout();
  const playlists = usePlaylistStore((state) => state.playlists);
  const createPlaylist = usePlaylistStore((state) => state.createPlaylist);
  const addTrackToPlaylist = usePlaylistStore((state) => state.addTrackToPlaylist);
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");

  const orderedPlaylists = useMemo(
    () => [...playlists].sort((left, right) => right.updatedAt - left.updatedAt),
    [playlists],
  );

  if (!visible || !track) {
    return null;
  }

  return (
    <View style={styles.overlay}>
      <Pressable style={styles.backdrop} onPress={onClose} />
      <ScrollView
        bounces={false}
        showsVerticalScrollIndicator={false}
        style={[
          styles.sheet,
          {
            backgroundColor: theme.background,
            marginBottom: Math.max(insets.bottom, 8) + Math.max(contentBottomSpacing, bottomOffset),
          },
        ]}
        contentContainerStyle={[styles.sheetContent, { paddingBottom: 24 }]}
      >
        <View style={[styles.handle, { backgroundColor: theme.textMuted }]} />

        <View style={styles.topBar}>
          <Text variant="headline">Add to Playlist</Text>
          <Pressable onPress={onClose} style={[styles.closeButton, { borderColor: `${theme.border}88`, backgroundColor: `${theme.surface}B8` }]}>
            <SymbolIcon name="close" size={16} color={theme.text} />
          </Pressable>
        </View>

        <LinearGradient
          colors={[`${theme.accent}16`, `${theme.accentAlt}12`, `${theme.card}F0`]}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
          style={[styles.trackCard, { borderColor: `${theme.border}99` }]}
        >
          <CachedArtwork artwork={track.artwork} category="track" variant="hero" width={76} height={76} borderRadius={24} />
          <View style={styles.trackMeta}>
            <Text variant="headline" numberOfLines={2}>
              {track.title}
            </Text>
            <Text muted numberOfLines={1}>
              {track.artist}
            </Text>
            {track.album ? (
              <View style={[styles.metaPill, { backgroundColor: `${theme.background}B8`, borderColor: `${theme.border}55` }]}>
                <Text muted numberOfLines={1}>
                  {track.album}
                </Text>
              </View>
            ) : null}
          </View>
        </LinearGradient>

        <View style={styles.section}>
          <Text variant="headline">Playlists</Text>
          <View style={styles.playlistList}>
            {orderedPlaylists.length ? (
              orderedPlaylists.map((playlist, index) => {
                const alreadyAdded = playlist.tracks.some((item) => item.id === track.id);

                return (
                  <Pressable
                    key={playlist.id}
                    disabled={alreadyAdded}
                    onPress={() => {
                      addTrackToPlaylist(playlist.id, track);
                      toastService.show(`Added to ${playlist.title}.`);
                      onClose();
                    }}
                    style={({ pressed }) => [
                      styles.playlistRow,
                      {
                        backgroundColor: alreadyAdded
                          ? `${theme.surfaceAlt}88`
                          : pressed
                            ? `${theme.surfaceAlt}D8`
                            : `${theme.card}D8`,
                        borderColor: alreadyAdded ? `${theme.border}66` : pressed ? `${theme.accent}55` : `${theme.border}88`,
                      },
                    ]}
                  >
                    <View style={[styles.indexWrap, { backgroundColor: `${theme.background}BE`, borderColor: `${theme.border}55` }]}>
                      {alreadyAdded ? (
                        <SymbolIcon name="checkCircle" size={14} color={theme.accent} />
                      ) : (
                        <Text muted style={styles.indexText}>
                          {String(index + 1).padStart(2, "0")}
                        </Text>
                      )}
                    </View>
                    <CachedArtwork
                      artwork={playlist.artwork}
                      fallbackArtwork={playlist.tracks[0]?.artwork}
                      category="playlist"
                      variant="thumbnail"
                      width={54}
                      height={54}
                      borderRadius={18}
                    />
                    <View style={styles.playlistMeta}>
                      <Text numberOfLines={1}>{playlist.title}</Text>
                      {playlist.description ? (
                        <Text muted numberOfLines={1}>
                          {playlist.description}
                        </Text>
                      ) : null}
                      <Text muted numberOfLines={1}>
                        {formatCount(playlist.tracks.length, "track")} · {formatUpdatedTime(playlist.updatedAt)}
                      </Text>
                    </View>
                    <View style={styles.rowRight}>
                      {alreadyAdded ? (
                        <Text style={{ color: theme.accent }}>Added</Text>
                      ) : (
                        <SymbolIcon name="add" size={18} color={theme.textMuted} />
                      )}
                    </View>
                  </Pressable>
                );
              })
            ) : (
              <View style={[styles.emptyState, { backgroundColor: `${theme.card}D8`, borderColor: `${theme.border}88` }]}>
                <Text variant="headline">No playlists</Text>
              </View>
            )}
          </View>
        </View>

        <View style={styles.section}>
          <Text variant="headline">Create New</Text>
          <View style={[styles.createCard, { backgroundColor: `${theme.card}E8`, borderColor: `${theme.border}99` }]}>
            <TextInput
              value={title}
              onChangeText={setTitle}
              placeholder="Playlist title"
              placeholderTextColor={theme.textMuted}
              style={[styles.input, { color: theme.text, backgroundColor: `${theme.background}C2`, borderColor: `${theme.border}66` }]}
            />
            <TextInput
              value={description}
              onChangeText={setDescription}
              placeholder="Description"
              placeholderTextColor={theme.textMuted}
              style={[styles.input, { color: theme.text, backgroundColor: `${theme.background}C2`, borderColor: `${theme.border}66` }]}
            />
            <Button
              label="Create Playlist"
              onPress={() => {
                const playlist = createPlaylist({ title, description, initialTrack: track });
                if (!playlist) {
                  toastService.show("Playlist title cannot be empty.");
                  return;
                }

                setTitle("");
                setDescription("");
                toastService.show(`Created ${playlist.title}.`);
                onClose();
              }}
            />
          </View>
        </View>
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  overlay: {
    ...StyleSheet.absoluteFillObject,
    justifyContent: "flex-end",
  },
  backdrop: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: "rgba(0,0,0,0.42)",
  },
  sheet: {
    flexGrow: 0,
    maxHeight: "78%",
    borderTopLeftRadius: 32,
    borderTopRightRadius: 32,
  },
  sheetContent: {
    paddingHorizontal: 20,
    paddingTop: 16,
    gap: 18,
  },
  handle: {
    alignSelf: "center",
    width: 42,
    height: 5,
    borderRadius: 999,
    opacity: 0.5,
  },
  topBar: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
  },
  closeButton: {
    width: 34,
    height: 34,
    borderRadius: 999,
    borderWidth: 1,
    alignItems: "center",
    justifyContent: "center",
  },
  trackCard: {
    borderRadius: 28,
    borderWidth: 1,
    padding: 16,
    flexDirection: "row",
    gap: 14,
  },
  trackMeta: {
    flex: 1,
    justifyContent: "center",
    gap: 6,
  },
  metaPill: {
    alignSelf: "flex-start",
    maxWidth: "100%",
    borderRadius: 999,
    borderWidth: 1,
    paddingHorizontal: 10,
    paddingVertical: 5,
  },
  section: {
    gap: 10,
  },
  createCard: {
    borderRadius: 24,
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
  playlistList: {
    gap: 10,
  },
  playlistRow: {
    borderWidth: 1,
    borderRadius: 22,
    paddingHorizontal: 12,
    paddingVertical: 12,
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
  },
  indexWrap: {
    width: 34,
    height: 34,
    borderRadius: 999,
    borderWidth: 1,
    alignItems: "center",
    justifyContent: "center",
  },
  indexText: {
    fontSize: 11,
  },
  playlistMeta: {
    flex: 1,
    gap: 4,
  },
  rowRight: {
    minWidth: 32,
    alignItems: "flex-end",
  },
  emptyState: {
    borderRadius: 22,
    borderWidth: 1,
    padding: 16,
  },
});
