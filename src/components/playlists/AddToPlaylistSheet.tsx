import { useMemo, useState } from "react";
import { Pressable, ScrollView, StyleSheet, TextInput, View } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";

import { CachedArtwork } from "@/components/artwork/CachedArtwork";
import { Button } from "@/components/ui/Button";
import { Text } from "@/components/ui/Text";
import { useMiniPlayerLayout } from "@/hooks/useMiniPlayerLayout";
import { useTheme } from "@/hooks/useTheme";
import { usePlaylistStore } from "@/modules/playlists/playlistStore";
import { toastService } from "@/services/toastService";
import type { Track } from "@/types/track";

type Props = {
  visible: boolean;
  track: Track | null;
  onClose: () => void;
  bottomOffset?: number;
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
          <Text muted variant="caption" style={styles.topTitle}>
            Add To Playlist
          </Text>
          <Pressable onPress={onClose} style={styles.closeButton}>
            <Text style={{ color: theme.accent }}>Close</Text>
          </Pressable>
        </View>

        <View style={styles.trackRow}>
          <CachedArtwork artwork={track.artwork} category="track" variant="thumbnail" width={58} height={58} borderRadius={18} />
          <View style={styles.trackMeta}>
            <Text numberOfLines={2}>{track.title}</Text>
            <Text muted numberOfLines={1}>
              {track.artist}
            </Text>
          </View>
        </View>

        <View style={[styles.block, { backgroundColor: theme.surface, borderColor: `${theme.border}88` }]}>
          <Text muted variant="caption">
            Create New
          </Text>
          <TextInput
            value={title}
            onChangeText={setTitle}
            placeholder="Playlist title"
            placeholderTextColor={theme.textMuted}
            style={[styles.input, { color: theme.text, backgroundColor: theme.background, borderColor: theme.border }]}
          />
          <TextInput
            value={description}
            onChangeText={setDescription}
            placeholder="Description (optional)"
            placeholderTextColor={theme.textMuted}
            style={[styles.input, { color: theme.text, backgroundColor: theme.background, borderColor: theme.border }]}
          />
          <Button
            label="Create And Add"
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

        <View style={[styles.block, { backgroundColor: theme.surface, borderColor: `${theme.border}88` }]}>
          <Text muted variant="caption">
            Existing Playlists
          </Text>
          <View style={styles.playlistList}>
            {orderedPlaylists.length ? (
              orderedPlaylists.map((playlist) => {
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
                    style={[
                      styles.playlistRow,
                      {
                        backgroundColor: alreadyAdded ? `${theme.surfaceAlt}88` : theme.background,
                        borderColor: alreadyAdded ? `${theme.border}66` : theme.border,
                      },
                    ]}
                  >
                    <View style={styles.playlistMeta}>
                      <Text>{playlist.title}</Text>
                      <Text muted numberOfLines={1}>
                        {playlist.description || `${playlist.tracks.length} tracks`}
                      </Text>
                    </View>
                    <Text muted>{alreadyAdded ? "Added" : `${playlist.tracks.length}`}</Text>
                  </Pressable>
                );
              })
            ) : (
              <Text muted>No playlists yet. Create one here.</Text>
            )}
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
    maxHeight: "76%",
    borderTopLeftRadius: 30,
    borderTopRightRadius: 30,
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
  topTitle: {
    letterSpacing: 1.1,
  },
  closeButton: {
    paddingVertical: 4,
  },
  trackRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 14,
  },
  trackMeta: {
    flex: 1,
    gap: 4,
  },
  block: {
    borderRadius: 22,
    borderWidth: 1,
    padding: 16,
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
    borderRadius: 16,
    paddingHorizontal: 14,
    paddingVertical: 12,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    gap: 12,
  },
  playlistMeta: {
    flex: 1,
    gap: 4,
  },
});
