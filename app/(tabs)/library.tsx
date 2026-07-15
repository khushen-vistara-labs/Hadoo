import { router } from "expo-router";
import { useMemo, useState } from "react";
import { Pressable, StyleSheet, TextInput, View } from "react-native";

import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { Screen } from "@/components/ui/Screen";
import { Text } from "@/components/ui/Text";
import { useTheme } from "@/hooks/useTheme";
import { useLibraryStore } from "@/modules/library/libraryStore";
import { usePlaylistStore } from "@/modules/playlists/playlistStore";
import { toastService } from "@/services/toastService";

export default function LibraryScreen() {
  const likedSongs = useLibraryStore((state) => state.likedSongs);
  const recentlyPlayed = useLibraryStore((state) => state.recentlyPlayed);
  const playlists = usePlaylistStore((state) => state.playlists);
  const createPlaylist = usePlaylistStore((state) => state.createPlaylist);
  const theme = useTheme();
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
    router.push(`/playlist/${playlist.id}`);
  };

  return (
    <Screen>
      <Text variant="title">Library</Text>
      <Card>
        <Text variant="headline">Liked Songs</Text>
        <Text muted>{likedSongs.length} saved tracks</Text>
      </Card>
      <Card>
        <Text variant="headline">Playlists</Text>
        <View style={styles.createGroup}>
          <TextInput
            value={title}
            onChangeText={setTitle}
            placeholder="New playlist title"
            placeholderTextColor={theme.textMuted}
            style={[styles.input, { color: theme.text, backgroundColor: theme.surface, borderColor: theme.border }]}
          />
          <TextInput
            value={description}
            onChangeText={setDescription}
            placeholder="Description (optional)"
            placeholderTextColor={theme.textMuted}
            style={[styles.input, { color: theme.text, backgroundColor: theme.surface, borderColor: theme.border }]}
          />
          <Button label="Create Playlist" onPress={submitPlaylist} />
        </View>
        <View style={styles.list}>
          {orderedPlaylists.length ? (
            orderedPlaylists.map((playlist) => (
              <Pressable
                key={playlist.id}
                onPress={() => router.push(`/playlist/${playlist.id}`)}
                style={[styles.playlistRow, { backgroundColor: theme.surface, borderColor: theme.border }]}
              >
                <View style={styles.playlistMeta}>
                  <Text>{playlist.title}</Text>
                  <Text muted numberOfLines={2}>
                    {playlist.description || "No description"}
                  </Text>
                </View>
                <Text muted>{playlist.tracks.length} tracks</Text>
              </Pressable>
            ))
          ) : (
            <Text muted>No playlists yet. Create one to start saving tracks.</Text>
          )}
        </View>
      </Card>
      <Card>
        <Text variant="headline">Recently Played</Text>
        <Text muted>{recentlyPlayed.length} tracks</Text>
      </Card>
      <Card>
        <Text variant="headline">Downloaded / Cached</Text>
        <Text muted>Offline playback will live here.</Text>
      </Card>
      <Card>
        <Text variant="headline">Local Files</Text>
        <Text muted>Your imported files will appear here.</Text>
      </Card>
    </Screen>
  );
}

const styles = StyleSheet.create({
  createGroup: {
    gap: 10,
  },
  input: {
    borderWidth: 1,
    borderRadius: 18,
    paddingHorizontal: 14,
    paddingVertical: 12,
  },
  list: {
    gap: 12,
  },
  playlistRow: {
    borderWidth: 1,
    borderRadius: 18,
    padding: 14,
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
