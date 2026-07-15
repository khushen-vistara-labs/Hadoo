import { router, useLocalSearchParams } from "expo-router";
import { Pressable, StyleSheet, View } from "react-native";

import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { Screen } from "@/components/ui/Screen";
import { Text } from "@/components/ui/Text";
import { useTheme } from "@/hooks/useTheme";
import { playerService } from "@/modules/player/playerService";
import { usePlaylistStore } from "@/modules/playlists/playlistStore";
import { toastService } from "@/services/toastService";

export default function PlaylistDetailsScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const playlist = usePlaylistStore((state) => state.playlists.find((item) => item.id === id));
  const removeTrackFromPlaylist = usePlaylistStore((state) => state.removeTrackFromPlaylist);
  const deletePlaylist = usePlaylistStore((state) => state.deletePlaylist);
  const theme = useTheme();

  if (!playlist) {
    return (
      <Screen>
        <Text variant="title">Playlist</Text>
        <Text muted>Playlist not found.</Text>
      </Screen>
    );
  }

  const tracks = playlist.tracks;

  return (
    <Screen>
      <Card>
        <Text variant="title">{playlist.title}</Text>
        {playlist.description ? <Text muted>{playlist.description}</Text> : null}
        <Text muted>{tracks.length} tracks</Text>
        <View style={styles.actions}>
          <Button
            label="Play All"
            onPress={() => {
              if (!tracks.length) {
                toastService.show("Add a few tracks before playing this playlist.");
                return;
              }

              void playerService.playTrack(tracks[0], tracks).catch(() => {
                toastService.show("Could not start this playlist.");
              });
            }}
          />
          <Button
            label="Delete Playlist"
            tone="secondary"
            onPress={() => {
              deletePlaylist(playlist.id);
              router.back();
            }}
          />
        </View>
      </Card>
      {tracks.map((track) => (
        <Card key={`${playlist.id}-${track.id}`} style={[styles.trackCard, { backgroundColor: theme.surface }]}>
          <View style={styles.trackMeta}>
            <Text>{track.title}</Text>
            <Text muted>{track.artist}</Text>
            {track.album ? <Text muted>{track.album}</Text> : null}
          </View>
          <Pressable
            onPress={() => removeTrackFromPlaylist(playlist.id, track.id)}
            style={[styles.removeButton, { borderColor: theme.border, backgroundColor: theme.background }]}
          >
            <Text muted>Remove</Text>
          </Pressable>
        </Card>
      ))}
    </Screen>
  );
}

const styles = StyleSheet.create({
  actions: {
    flexDirection: "row",
    gap: 10,
  },
  trackCard: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    gap: 12,
  },
  trackMeta: {
    flex: 1,
    gap: 4,
  },
  removeButton: {
    borderWidth: 1,
    borderRadius: 14,
    paddingHorizontal: 12,
    paddingVertical: 10,
  },
});
