import { router } from "expo-router";
import { Pressable, StyleSheet, View } from "react-native";

import { Card } from "@/components/ui/Card";
import { Screen } from "@/components/ui/Screen";
import { Text } from "@/components/ui/Text";
import { useLibraryStore } from "@/modules/library/libraryStore";
import { usePlaylistStore } from "@/modules/playlists/playlistStore";

export default function LibraryScreen() {
  const likedSongs = useLibraryStore((state) => state.likedSongs);
  const recentlyPlayed = useLibraryStore((state) => state.recentlyPlayed);
  const playlists = usePlaylistStore((state) => state.playlists);

  return (
    <Screen>
      <Text variant="title">Library</Text>
      <Card>
        <Text variant="headline">Liked Songs</Text>
        <Text muted>{likedSongs.length} saved tracks</Text>
      </Card>
      <Card>
        <Text variant="headline">Playlists</Text>
        <View style={styles.list}>
          {playlists.map((playlist) => (
            <Pressable key={playlist.id} onPress={() => router.push(`/playlist/${playlist.id}`)}>
              <Text>{playlist.title}</Text>
              <Text muted>{playlist.description}</Text>
            </Pressable>
          ))}
        </View>
      </Card>
      <Card>
        <Text variant="headline">Recently Played</Text>
        <Text muted>{recentlyPlayed.length} tracks</Text>
      </Card>
      <Card>
        <Text variant="headline">Downloaded / Cached</Text>
        <Text muted>Placeholder for future offline support.</Text>
      </Card>
      <Card>
        <Text variant="headline">Local Files</Text>
        <Text muted>File picking and scanning can be added later.</Text>
      </Card>
    </Screen>
  );
}

const styles = StyleSheet.create({
  list: {
    gap: 12,
  },
});
