import { useLocalSearchParams } from "expo-router";

import { Card } from "@/components/ui/Card";
import { Screen } from "@/components/ui/Screen";
import { Text } from "@/components/ui/Text";
import { mockTracks } from "@/data/mockTracks";
import { usePlaylistStore } from "@/modules/playlists/playlistStore";

export default function PlaylistDetailsScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const playlist = usePlaylistStore((state) => state.playlists.find((item) => item.id === id));

  if (!playlist) {
    return (
      <Screen>
        <Text variant="title">Playlist</Text>
        <Text muted>Playlist not found.</Text>
      </Screen>
    );
  }

  const tracks = mockTracks.filter((track) => playlist.trackIds.includes(track.id));

  return (
    <Screen>
      <Card>
        <Text variant="title">{playlist.title}</Text>
        <Text muted>{playlist.description}</Text>
        <Text muted>{tracks.length} tracks</Text>
      </Card>
      {tracks.map((track) => (
        <Card key={track.id}>
          <Text>{track.title}</Text>
          <Text muted>{track.artist}</Text>
        </Card>
      ))}
    </Screen>
  );
}
